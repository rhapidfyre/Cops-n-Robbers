
--[[
  Cops and Robbers: Wanted Script - Client Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/19/2019
  
  This file contains all information that will be stored, used, and
  manipulated by any CNR scripts in the gamemode. For example, a
  player's level will be stored in this file and then retrieved using
  an export; Rather than making individual SQL queries each time.
--]]

local crimeList = {} -- List of crimes player committed since last innocent
local wanted = {}
local isCop = false

-- DEBUG -
RegisterCommand('wanted', function(s, a, r)
  if a[1] then
    Wait(800)
    if tonumber(a[1]) ~= 0 then
      TriggerServerEvent('cnr:wanted_points', 'carjack', "MANUAL ENTRY")
    else
      TriggerServerEvent('cnr:wanted_points', 'jailed', "MANUAL CLEAR")
    end
  else
    local ply = GetPlayerServerId(PlayerId())
    TriggerEvent('chatMessage', "^1Wanted Level: ^7"..(wanted[ply]))
  end
end)


-- Networking
RegisterNetEvent('cnr:wanted_list') -- Updates 'wanted' table with server table
RegisterNetEvent('cnr:wanted_client')
RegisterNetEvent('cnr:wanted_crimelist')
RegisterNetEvent('cnr:police_officer_duty')


TriggerEvent('chat:addTemplate', 'crimeMsg',
  '<font color="#F80"><b>CRIME COMMITTED:</b></font> {0}'
)


TriggerEvent('chat:addTemplate', 'levelMsg',
  '<font color="#F80"><b>WANTED LEVEL:</b></font> {0} - ({1})'
)


local marked = {}  -- Table of killed peds ([Ped_Id] = true)


--- EXPORT: CrimeList()
-- Returns a list of crime codes the player has committed
-- @return A table (list form) of crimes
function CrimeList()
  return crimeList
end


--- EVENT: 'crime_list
-- List of crimes the player has committed
AddEventHandler('cnr:wanted_crimelist', function(clist)
  crimeList = clist
end)


--- EVENT: 'wanted_list'
-- Received by server; Entire wanted list with key-value pair (Line 19)
-- @param warrant_list The table of wanted persons ([Server_Id] = Points)
AddEventHandler('cnr:wanted_list', function(warrant_list)
  wanted = warrant_list
end)


--- EVENT: 'wanted_client'
-- Updates the wanted points for a single given client
-- Triggers client events 'is_wanted', 'is_clear', 'is_most_wanted' accordingly
-- @param ply The server ID
-- @param wps The wanted points value
RegisterNetEvent('cnr:wanted_client')
AddEventHandler('cnr:wanted_client', function(ply, wp)

  -- If no wanted points or player is given, assume or return
  if not wp  then wp = 0     end
  if not ply then return 0   end
  
  -- If the player being passed is the local client, check for events
  if ply == GetPlayerServerId(PlayerId()) then 
    
    -- If no wanted table entry, create one.
    if not wanted[ply] then wanted[ply] = 0
    end
    
    -- If player goes innocent -> wanted or vice versa, trigger event
    if     wanted[ply] == 0 and wp  > 0 then TriggerEvent('cnr:is_wanted')
    elseif wanted[ply]  > 0 and wp <= 0 then
      TriggerEvent('cnr:is_clear')
      crimeList = {}
    end
    
    -- If player was not most wanted, and will be, trigger 'is_most_wanted'
    if wanted[ply] < mw and wp > mw then TriggerEvent('cnr:is_most_wanted')
    end
    
  end
  
  wanted[ply] = wp -- Update wanted list entry
end)


--- EXPORT GetWanteds()
-- Returns the table of wanted players
-- @return table The list of wanteds (KEY: Server ID, VAL: Wanted Points)
function GetWanteds() return wanted end


--- EXPORT WantedLevel()
-- Returns the wanted level of the player for easier calculation
-- @param ply Server ID, if provided. Local client if not provided.
-- @return The wanted level based on current wanted points
function WantedLevel(ply)

  -- If ply not given, return 0
  if not ply         then ply = GetPlayerServerId(PlayerId()) end
  if not wanted[ply] then wanted[ply] = 0 end -- Create entry if not exists
  
  if     wanted[ply] <   1 then return  0
  elseif wanted[ply] > 100 then return 11
  else                           return (math.floor((wanted[ply])/10) + 1)
  end
  return 0
  
end


--- UpdateWantedStars()
-- Checks to see if the player's wanted points change to adjust the NUI.
-- If they differ from the NUI display, it will update the NUI.
function UpdateWantedStars()
  local prevWanted = 0
  local tickCount  = 0
  while true do 
    local myWanted =  WantedLevel(GetPlayerServerId(PlayerId()))
    
    -- Wanted Level has changed
    if myWanted ~= prevWanted then 
      prevWanted = myWanted -- change to reflect it
      tickCount  = 0      -- Restart flash if changes again during flash
      
    else
      -- Make it flash, end on the solid version
      if tickCount < 10 then          tickCount = tickCount + 1
        if myWanted == 0 then           SendNUIMessage({nostars = true})
        else
          -- Normal version (light saturation)
          if tickCount % 2 == 0 then  SendNUIMessage({stars = myWanted})
          else
            -- Performs the flash (dark saturation)
            if     myWanted > 10 then   SendNUIMessage({stars = "c"})
            elseif myWanted >  5 then   SendNUIMessage({stars = "b"})
            else                      SendNUIMessage({stars = "a"})
            end
          end
        end
      end
    end
    Wait(600)
  end
end


function IsPlayerAimingAtCop(target)
  if not DecorExistOn(target, "AimCrime") then DecorRegister("AimCrime", 2) end
  if not DecorGetBool(target, "AimCrime") then
    DecorSetBool(target, "AimCrime", true)
    if exports['cnr_police']:DutyStatus(target) then 
      TriggerServerEvent('cnr:wanted_points', 'brandish-leo')
      Citizen.Wait(1000)
    else
      TriggerServerEvent('cnr:wanted_points', 'brandish')
      Citizen.Wait(1000)
    end
  end
end


--- NotCopLoops()
-- Runs loops if the player is not a cop. Terminates if they go onto cop duty
-- Used to detect crimes that civilians can commit when off duty.
local looping  = false
local lastShot = 0
function NotCopLoops()
  if not looping then 
    looping = true
    
    -- An intense Wait(0) loop for immediate actions (aiming, shooting, etc)
    Citizen.CreateThread(function()
      while not isCop do 
        local ped = PlayerPedId()
        
        -- Aiming/Shooting Crimes
        if IsPlayerFreeAiming(PlayerId()) then 
          local isAiming, aimTarget = GetEntityPlayerIsFreeAimingAt(ped)
          if aimTarget then 
            if IsEntityAPed(target) then
              if IsPedAPlayer(target) then
                local dist = #(GetEntityCoords(ped) - 
                               GetEntityCoords(GetPlayerPed(target))
                )
                if dist < 120.0 then
                  if HasEntityClearLosToEntity(ped, GetPlayerPed(target), 17) then
                    IsPlayerAimingAtCop(aimTarget)
                  end
                end
              end
            end
          end
        end
        
        -- Shooting a firearm near peds and someone can see it
        if IsPedShooting(ped) then
          if lastShot < GetGameTimer() then
            local wasShotSeen = false
            for peds in exports['cnrobbers']:EnumeratePeds() do
              if not IsPedAPlayer(peds) then
                if #(GetEntityCoords(ped) - GetEntityCoords(peds)) < 200.0 then 
                  if HasEntityClearLosToEntity(peds, ped, 17) then 
                    wasShotSeen = true
                  end
                end
              end
            end
            if wasShotSeen then 
              lastShot = GetGameTimer() + 30000
              TriggerServerEvent('cnr:wanted_points', 'discharge')
            end
          end
        end
        
      
        Citizen.Wait(0)
      end
      looping = false
    end)
    
    -- A less intensive loop for simple checks
    -- Did someone die? Was a car stolen? etc...
    Citizen.CreateThread(function()
      while not isCop do 
          
        -- Breaking into a vehicle
        
        
        -- Killing a Ped NPC
        for peds in exports['cnrobbers']:EnumeratePeds() do 
          if not IsPedAPlayer(peds) then 
            if IsPedDeadOrDying(peds) then
              if not DecorExistOn(peds, "KillCrime") then 
                DecorRegister("KillCrime", 2)
                DecorRegister("idKiller", 3)
              end
              if not DecorGetBool(peds, "KillCrime") then
                local killer = GetPedSourceOfDeath(peds)
                -- DEBUG - Need to add a check of whether player ran over ped
                if killer then 
                  if IsEntityAPed(killer) then 
                    DecorSetInt(peds, "idKiller", killer)
                  end
                end
                DecorSetBool(peds, "KillCrime", true)
                if DecorGetInt(peds, "idKiller") == PlayerPedId() then 
                  TriggerServerEvent('cnr:wanted_points', 'manslaughter')
                end
              end
            end
          end
        end
        Citizen.Wait(1000)      
      end
    end)
  end
end


AddEventHandler('cnr:police_officer_duty', function(ply, onDuty)
  if ply == GetPlayerServerId(PlayerId()) then
    isCop = onDuty
    if not onDuty then NotCopLoops() end
  end
end)


Citizen.CreateThread(function()
  Citizen.CreateThread(UpdateWantedStars)
  Citizen.CreateThread(NotCopLoops)
end)