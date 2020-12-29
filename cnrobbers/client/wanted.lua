
RegisterNetEvent('cnr:wanted_client')

local crimeCar        = {} -- Used to check GTA/Carjacking
local cfreeResources  = {}
local pedTargets      = {}
local lastShot        = 0


-- This should be moved server-side
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
  
  if #cfreeResources > 0 then 
    SendNUIMessage({crimeoff = true})
    print("One or more resources are declaring the player is in a Crime Free Zone.")
  else
    SendNUIMessage({crimeon = true})
    print("The player is no longer in any Crime Free Zones.");
  end
  
end)


-- Returns true if any resource is reporting the player in a Crime Free Zone
-- A Crime Free Zone is any location where crimes are not reported
-- i.e: Aiming, shooting, jacking a car, etc.
function CrimeFreeZone()
  return (#cfreeResources > 1)
end


--- EXPORT: CrimeList()
-- Returns a list of crime codes the player has committed
-- @return A table (list form) of crimes
function CrimeList() return CNR.crimes end


--- EVENT: 'wanted_client'
-- Used to synchronize wanted players with the client
AddEventHandler('cnr:wanted_client', function(ply, wantedPoints)

  if source ~= "" then

    -- If 'ply' is a table, it's a list of ALL wanted players from the server
    if type(ply) == "table" then
      print("Received wanted list from server (^3ATOMIC^7).")
      CNR.wanted = ply
      
    elseif type(ply) == "number" then
  
      -- If no wanted points or player is given, assume or return
      if not ply then return 0 end
      if not wantedPoints then wantedPoints = 0 end
    
      -- If no wanted table entry, create one.
      if not CNR.wanted[ply] then CNR.wanted[ply] = 0 end
    
      print("Wanted level update received - Player #"..ply.." (^3"..wantedPoints.."^7).")
      CNR.wanted[ply] = wantedPoints -- Update wanted list entry
  
    end
  
  end
end)


--- EXPORT GetWanteds()
-- Returns the table of wanted players
-- @return table The list of wanteds (KEY: Server ID, VAL: Wanted Points)
function GetWanteds() return CNR.wanted end


--- EXPORT WantedLevel()
-- Returns the wanted level of the player for easier calculation
-- @param ply Server ID, if provided. Local client if not provided.
-- @return The wanted level based on current wanted points
function WantedLevel(ply)

  -- If ply not given, return 0
  if not ply then ply = GetPlayerServerId(PlayerId()) end
  if not CNR.wanted[ply] then CNR.wanted[ply] = 0 end -- Create entry if not exists

  if     CNR.wanted[ply] <   1 then return  0
  elseif CNR.wanted[ply] > 100 then return 11
  end
  return (math.ceil((CNR.wanted[ply])/10))

end


--- UpdateWantedStars()
-- Checks to see if the player's wanted points change to adjust the NUI.
-- If they differ from the NUI display, it will update the NUI.
function UpdateWantedStars()

  local prevWanted = 0
  local tickCount  = 0
  
  while true do
    local myWanted = WantedLevel()

    -- Wanted Level has changed
    if myWanted ~= prevWanted then
      prevWanted = myWanted -- change to reflect it
      tickCount  = 0      -- Restart flash if changes again during flash

    else
      -- Make it flash, end on the solid version
      if tickCount < 10 then            tickCount = tickCount + 1
        if myWanted == 0 then           SendNUIMessage({nostars = true})
        else
          -- Normal version (light saturation)
          if tickCount % 2 == 0 then    SendNUIMessage({stars = myWanted})
          else
            -- Performs the flash (dark saturation)
            if     myWanted > 10 then   SendNUIMessage({stars = "c"})
            elseif myWanted >  5 then   SendNUIMessage({stars = "b"})
            else                        SendNUIMessage({stars = "a"})
            end
          end
        end
      end
    end
    Wait(600)
  end
  
end


function CheckBrandishing(target)

  -- Setting decors helps this script from flooding the server with
  -- unnecessary networking events.
  if not DecorExistOn(target, "AimCrime") then DecorRegister("AimCrime", 2) end
  if not DecorGetBool(target, "AimCrime") then

    -- Remove flag after 60 seconds
    DecorSetBool(target, "AimCrime", true)
    Citizen.CreateThread(function()
      Citizen.Wait(60000)
      if DoesEntityExist(target) then
        DecorSetBool(target, "AimCrime", false)
      end
    end)

    local myPos = GetEntityCoords(PlayerPedId())
    if IsPedAPlayer(target) then
      if IsPolice(target) then
        print("DEBUG - Player IS a cop. Brandish on an LEO")
        TriggerServerEvent('cnr:crime', 'brandish-leo', true,
          GetFullZoneName(GetNameOfZone(myPos)),
          myPos, true -- ignore 911
        )
        Citizen.Wait(1000)
      else
        print("DEBUG - Player is not a cop. Brandish only.")
        TriggerServerEvent('cnr:crime', 'brandish', true,
          GetFullZoneName(GetNameOfZone(myPos)),
          myPos
        )
        Citizen.Wait(1000)
      end
    else

      TriggerServerEvent('cnr:crime', 'brandish-npc', true,
          GetFullZoneName(GetNameOfZone(myPos)),
          myPos, true -- ignore 911
      )
      Citizen.Wait(1000)

    end
    pedTargets[#pedTargets + 1] = target
  end
end


-- Loops through peds the player has targeted to check for death
Citizen.CreateThread(function()
  while true do
    if #pedTargets > 0 then
      for i = #pedTargets, 1, (-1) do
        local ped = pedTargets[i]
        if DoesEntityExist(ped) then

          -- Handles Manslaughter Detection - Murder is handled by the server
          -- Manslaughter = NPC, Murder = Player
          if IsPedDeadOrDying(ped) and (not IsPedAPlayer(ped)) then
            if GetPedSourceOfDeath(ped) == PlayerPedId() then
              if not knownDead[ped] then
                knownDead[ped] = true
                TriggerServerEvent('cnr:crime', 'manslaughter', true,
                  GetFullZoneName(GetNameOfZone(GetEntityCoords(PlayerPedId())))
                )
              end
            end
          end

        -- If at any point the ped is invalid, remove them from this list
        else table.remove(pedTargets, i)
        end
      end
    end
    Citizen.Wait(10)
  end
end)


-- Loops through actions taken by the player
Citizen.CreateThread(function()
  while true do
  
    Citizen.Wait(10)
    local ped = PlayerPedId()

    -- Player is Public Safety
    if DutyStatus() then


    -- Not Public Safety
    else

      -- Aiming Crimes (Also handles death detection internally of NPCs)
      if IsPlayerFreeAiming(PlayerId()) then
        if not IsAimCrime(GetSelectedPedWeapon(PlayerPedId())) then
          if not CrimeFreeZone() then
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
                      CheckBrandishing(aimTarget)
                    end
                  end -- Clear LOS
                end -- Distance Reasonable
              end -- Entity is a Player
            end -- Entity exists
          end -- In a Crime Free Zone
        end -- IsAimCrime()
      end -- IsPlayerFreeAiming()

      -- Shooting Crimes / Firearm Discharge
      if IsPedShooting(ped) and not DutyStatus() then
        if not CrimeFreeZone() then
          if lastShot < GetGameTimer() then
          
            local wasShotSeen = false
            local thisPos = GetEntityCoords(ped)
            
            for peds in EnumeratePeds() do
              if not IsPedAPlayer(peds) then
                if #(thisPos - GetEntityCoords(peds)) < 40.0 then
                  if HasEntityClearLosToEntity(peds, ped, 17) then
                    wasShotSeen = true
                  end
                end
              end
            end -- enumerate peds
            
            if wasShotSeen then
              lastShot = GetGameTimer() + 30000
              local myPos = GetEntityCoords(PlayerPedId())
              TriggerServerEvent('cnr:crime', 'discharge', true,
                GetFullZoneName(GetNameOfZone(myPos)),
                myPos
              )
            end -- was shot seen
            
          end -- cooldown timer
        end -- crime free zone
      end -- is player shooting

    end -- public safety check

  end
end)

