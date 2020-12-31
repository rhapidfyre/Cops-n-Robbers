
RegisterNetEvent('cnr:wanted_client')
RegisterNetEvent('cnr:crimes_client')

local prevWanted      = 0
local crimeCar        = {} -- Used to check GTA/Carjacking
local cfreeResources  = {}
local pedTargets      = {}
local lastShot        = 0
local lastAim         = 0
local knownDead       = {}

-- Index weapons that player SHOULD NOT be charged with for aiming
local isSafe = {
  [GetHashKey("WEAPON_UNARMED")] = true,
  [GetHashKey("WEAPON_FIST")] = true,
  [GetHashKey("WEAPON_BALL")] = true,
  [GetHashKey("WEAPON_SNOWBALL")] = true,
  [GetHashKey("WEAPON_TEARGAS")] = true,
  [GetHashKey("WEAPON_JERRYCAN")] = true,
  [GetHashKey("WEAPON_FLARE")] = true,
  [GetHashKey("WEAPON_BZGAS")] = true,
}

--- IsAimCrime()
-- Checks if the weapon being aimed should be a Brandishing Crime
-- @return True if the player SHOULD be charged with Firearm Brandishing
function IsAimCrime(weaponHash)
  if not weaponHash then return false end -- Assume it's a crime
  return isSafe[weaponHash]
end


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
function CrimeList()
  if not CNR.crimes then CNR.crimes = {} end
  return CNR.crimes
end


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
    
      if ply == GetPlayerServerId(PlayerId()) then 
        print("DEBUG - Your Wanted Points have changed - (^3"..wantedPoints.." WP^7).")
      else
        print("DEBUG - Wanted level update received - Player #"..ply.." (^3"..wantedPoints.." WP^7).")
      end
      CNR.wanted[ply] = wantedPoints -- Update wanted list entry
  
    end
  
  end
end)


AddEventHandler('cnr:crimes_client', function(idPlayer, idCrime)
  if not CNR.crimes then CNR.crimes = {} end
  if source ~= "" then
    if not idCrime then idCrime = {} end
    if (not CNR.crimes[idPlayer]) then
      CNR.crimes[idPlayer] = {}
    end
    if (not idCrime[1]) then
      CNR.crimes[idPlayer] = {}
      print("DEBUG - Crimes List Cleared for Player #"..idPlayer)
    else
      local n = #(CNR.crimes[idPlayer])
      CNR.crimes[idPlayer][n] = idCrime
      print("DEBUG - Added crime '"..idCrime.."' to list for Player #"..idPlayer)
    end
  end
end)


--- UpdateWantedStars()
-- Checks to see if the player's wanted points change to adjust the NUI.
-- If they differ from the NUI display, it will update the NUI.
function UpdateWantedStars()

  -- If Wanted Level has changed, do JQuery update
  local myWanted = WantedLevel()
  if myWanted ~= prevWanted then
    print("DEBUG - Wanted level has changed. Updating java.")
    prevWanted = myWanted -- keep track of last wanted level
    
    -- Determine if Stars are Visible
    if myWanted == 0 then SendNUIMessage({nostars = true})
    else SendNUIMessage({stars = myWanted})
    end
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
        TriggerServerEvent('cnr:crime', 'brandish-leo', true)
        Citizen.Wait(1000)
      else
        print("DEBUG - Player is not a cop. Brandish only.")
        TriggerServerEvent('cnr:crime', 'brandish')
        Citizen.Wait(1000)
      end
    else

      TriggerServerEvent('cnr:crime', 'brandish-npc', true)
      Citizen.Wait(1000)

    end
    print("DEBUG - Now tracking Ped #"..target)
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
                local myPos = GetEntityCoords(PlayerPedId())
                print("DEBUG - ^3you killed ^7pedTargets["..i.."]: '"..ped.."'! Removing.")
                table.remove(pedTargets, i)
                TriggerServerEvent('cnr:crime', 'manslaughter')
              else
                print("DEBUG - ^7pedTargets["..i.."]: '"..ped.."' already tracked. Removing.")
                table.remove(pedTargets, i)
              end
            else
              print("DEBUG - pedTargets["..i.."]: '"..ped.."' this player didn't kill them. Removing.")
              table.remove(pedTargets, i)
            end
          end

        -- If at any point the ped is invalid, remove them from this list
        else
          print("DEBUG - pedTargets["..i.."]: '"..ped.."' no longer exists. Removing.")
          table.remove(pedTargets, i)
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
              TriggerServerEvent('cnr:crime', 'discharge')
            end -- was shot seen
            
          end -- cooldown timer
        end -- crime free zone
      end -- is player shooting

    end -- public safety check

  end
end)

