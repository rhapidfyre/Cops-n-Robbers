
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
local wanted    = {}
local crimeCar  = {} -- Used to check GTA/Carjacking
local isCop     = false
local cfreeResources = {}

AddEventHandler('cnr:crimefree', function(enabled, resname)

  if enabled then
    cfreeResources[#cfreeResources + 1] = resname

  else
    local i = 0
    for k,v in pairs(cfreeResources) do
      if v == resname then i = k end
    end
    if i > 0 then table.remove(cfreeResources, i) end
  end

  if enabled then print("DEBUG - Crime Reporting: OFF"); SendNUIMessage({crimeoff = true})
  else
    if #cfreeResources > 0 then
      print("DEBUG - Error: A resource is holding up the crime free zone. Unable to disable.")
    else
      print("DEBUG - Crime Reporting: ON");
      SendNUIMessage({crimeon = true})
    end
  end
end)


-- Networking
RegisterNetEvent('cnr:wanted_list') -- Updates 'wanted' table with server table
RegisterNetEvent('cnr:wanted_client')
RegisterNetEvent('cnr:wanted_crimelist')
RegisterNetEvent('cnr:police_officer_duty')
RegisterNetEvent('cnr:wanted_enter_vehicle')  -- Player entered illegal veh
RegisterNetEvent('cnr:wanted_check_vehicle')  -- Checks if player has rt to veh


TriggerEvent('chat:addTemplate', 'crimeMsg',
  '<font color="#F80"><b>CRIME COMMITTED:</b></font> {0}'
)


TriggerEvent('chat:addTemplate', 'levelMsg',
  '<font color="#F80"><b>WANTED LEVEL:</b></font> {0} - ({1})'
)


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
  end
  return (math.floor((wanted[ply])/10) + 1)

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
    
    -- Remove flag after 30 seconds
    Citizen.CreateThread(function()
      Citizen.Wait(30000)
      if DoesEntityExist(target) then 
        DecorSetBool(target, "AimCrime", false)
      end
    end)
    
    local myPos = GetEntityCoords(PlayerPedId())
    if IsPedAPlayer(target) then
      if exports['cnr_police']:DutyStatus(target) then
        print("DEBUG - Player IS a cop. Brandish on an LEO")
        TriggerServerEvent('cnr:wanted_points', 'brandish-leo', true,
          exports['cnrobbers']:GetFullZoneName(GetNameOfZone(myPos)),
          myPos, true -- ignore 911
        )
        Citizen.Wait(1000)
      else
        print("DEBUG - Player is not a cop. Brandish only.")
        TriggerServerEvent('cnr:wanted_points', 'brandish', true,
          exports['cnrobbers']:GetFullZoneName(GetNameOfZone(myPos)),
          myPos
        )
        Citizen.Wait(1000)
      end
    else
        
        --[[
      local myPos         = GetEntityCoords(PlayerPedId())
      local stName, cross = GetStreetNameAtCoord(myPos.x, myPos.y, myPos.z)
      local zn            = GetNameOfZone(myPos.x, myPos.y, myPos.z)
      local r1            = GetStreetNameFromHashKey(stName)
        
      print("DEBUG - ("..stName..") "..r1.." @ "..zn)  
        ]]
      TriggerServerEvent('cnr:wanted_points', 'brandish-npc', true,
          exports['cnrobbers']:GetFullZoneName(GetNameOfZone(myPos)),
          myPos, true -- ignore 911
      )
      Citizen.Wait(1000)
    end
  end
end


--- NotCopLoops()
-- Runs loops if the player is not a cop. Terminates if they go onto cop duty
-- Used to detect crimes that civilians can commit when off duty.
local looping  = false
local lastShot = 0
local lastAim  = 0
function NotCopLoops()
  if not looping then
    looping = true

    -- An intense Wait(0) loop for immediate actions (aiming, shooting, etc)
    Citizen.CreateThread(function()
      while not isCop do
        local ped = PlayerPedId()
        local isCop = exports['cnr_police']:DutyStatus()
        -- Aiming/Shooting Crimes
        if not isCop then -- Ignore if player is a cop
          if IsPlayerFreeAiming(PlayerId()) then
            if IsAimCrime(GetSelectedPedWeapon(PlayerPedId())) then
              if not exports['cnr_ammunation']:InsideGunRange() then
                local _, aimTarget = GetEntityPlayerIsFreeAimingAt(PlayerId())
                if DoesEntityExist(aimTarget) then
                  if IsEntityAPed(aimTarget) then
                    local dist = #(GetEntityCoords(ped) -
                                   GetEntityCoords(aimTarget)
                    )
                    if dist < 120.0 then
                      if HasEntityClearLosToEntity(ped, aimTarget, 17) then
                        if lastAim < GetGameTimer() then
                          lastAim = GetGameTimer() + 12000
                          IsPlayerAimingAtCop(aimTarget)
                        end
                      end
                    end
                  end
                end
              end
            end
          end
        end
        
        -- Shooting a firearm near peds and someone can see it
        if IsPedShooting(ped) and not isCop then
          if not exports['cnr_ammunation']:InsideGunRange() then
            if lastShot < GetGameTimer() then
              local wasShotSeen = false
              local thisPos = GetEntityCoords(ped)
              for peds in exports['cnrobbers']:EnumeratePeds() do
                if not IsPedAPlayer(peds) then
                  if #(thisPos - GetEntityCoords(peds)) < 40.0 then
                    if HasEntityClearLosToEntity(peds, ped, 17) then
                      wasShotSeen = true
                    end
                  end
                end
              end
              if wasShotSeen then
                lastShot = GetGameTimer() + 12000
                TriggerServerEvent('cnr:wanted_points', 'discharge', true,
                  exports['cnrobbers']:GetFullZoneName(GetNameOfZone(myPos)),
                  myPos
                )
              end
            end
          end
        end
        Citizen.Wait(0)

      end
      looping = false
    end)

    -- A less intensive loop for simple checks that don't require each frame
    -- Did someone die, and did you kill them? etc...
    Citizen.CreateThread(function()
      while not isCop do

        -- Killing a Ped or Player
        for peds in exports['cnrobbers']:EnumeratePeds() do
          if IsPedDeadOrDying(peds) and not IsPedAPlayer(peds) then

            -- This dead ped doesn't have a decor set
            if not DecorExistOn(peds, "KillCrime") then
              DecorRegister("KillCrime", 2)
              DecorRegister("idKiller", 3)
            end

            -- If the killing crime hasn't been ran yet
            if not DecorGetBool(peds, "KillCrime") then
              local killer = GetPedSourceOfDeath(peds)
              if killer then
                if IsEntityAPed(killer) then
                  DecorSetInt(peds, "idKiller", killer)
                end
              end
              if DecorGetInt(peds, "idKiller") == PlayerPedId() then
                DecorSetBool(peds, "KillCrime", true)
                local myPos = GetEntityCoords(PlayerPedId())
                TriggerServerEvent('cnr:wanted_points', 'manslaughter', true,
                  exports['cnrobbers']:GetFullZoneName(GetNameOfZone(myPos)),
                  myPos
                )
              end
            end
          end
        end

        Citizen.Wait(1000)
      end
    end)
  end
end


AddEventHandler('cnr:wanted_enter_vehicle', function(veh)
  if crimeCar.v then
    if veh == crimeCar.v then
      print("DEBUG - Player broke into the vehicle!")
      -- Occupied: Carjacking (more serious crime)
      local myPos = GetEntityCoords(PlayerPedId())
      if crimeCar.d then
        if IsPedAPlayer(crimeCar.d) then
          TriggerServerEvent('cnr:wanted_points', 'carjack', true,
            exports['cnrobbers']:GetFullZoneName(GetNameOfZone(myPos)),
            myPos
          )
        else
          TriggerServerEvent('cnr:wanted_points', 'carjack-npc', true,
            exports['cnrobbers']:GetFullZoneName(GetNameOfZone(myPos)),
            myPos, true -- ignore 911
          )
        end
      -- Unoccupied: GTA
      else
        -- DEBUG - Add check later to see if vehicle is owned
        TriggerServerEvent('cnr:wanted_points', 'gta-npc', true,
          exports['cnrobbers']:GetFullZoneName(GetNameOfZone(myPos)),
          myPos
        )
      end
      crimeCar = {}
    end
  end
end)


--- EXPORT: HasRightsToVehicle
-- Checks if local player has a right to the vehicle
-- @param veh The local vehicle ID
-- @return True if the vehicle has a right to use this vehicle; False if not
function HasRightsToVehicle(veh)
  if IsEntityAVehicle(veh) then
    local vName = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
    -- Vehicle is an emergency vehicle
    if GetVehicleClass(veh) == 18 or eVehicle[vName] then
      if exports['cnr_police']:DutyStatus() then
        return true
      else return false
      end
    -- Vehicle is *NOT* an emergency vehicle
    else
      if DecorExistOn(veh, "idOwner") then
        if DecorGetInt(veh, "idOwner") == PlayerPedId() then return true
        else return false -- Player is not the owner
        end
      else return false -- Vehicle does not have a player owned
      end
    end
  else return false -- Entity isn't a vehicle
  end
end


AddEventHandler('cnr:wanted_check_vehicle', function(veh)
  local hasRight = HasRightsToVehicle(veh)
  print("DEBUG - Player has rights to vehicle? ["..tostring(hasRight).."]")
  if not hasRight then
    if IsEntityAVehicle(veh) then
      local lockStatus = GetVehicleDoorLockStatus(veh)
      local driver     = GetPedInVehicleSeat(veh, (-1))
      -- Breaking into a car is only a crime if it's locked
      if lockStatus ~= 0 and lockStatus ~= 1 then
        if driver > 0 then crimeCar.d = driver end
        print("DEBUG - Player is breaking into a car.")
        crimeCar.v = veh
      -- Or if the vehicle is being driven
      elseif driver > 0 then
        crimeCar.d = driver
        crimeCar.v = veh
        print("DEBUG - Car is not locked.")
      end
    end
  end
end)


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