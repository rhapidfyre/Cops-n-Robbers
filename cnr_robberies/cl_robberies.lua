
--[[
  Cops and Robbers: Convenience Robberies (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  07/19/2019
  
  This file contains the functionality to rob stores. This is not for heists,
  bank robberies, or other major events, but rather for holding up gas stations,
  bars, nightclubs, and similar.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

RegisterNetEvent('cnr:robbery_lock_status')
RegisterNetEvent('cnr:robbery_locks')
RegisterNetEvent('cnr:robbery_drops')
RegisterNetEvent('cnr:zone_change') -- If zone changes, change dropoffs

local isRobbing = false
local takeDrops = {}
local hasBag    = false


RegisterCommand('.debug2', function(s,a,r)
  TaskStartScenarioInPlace(PlayerPedId(), tostring(a[1]), 0, true)
end)

RegisterCommand('.debug', function(s,a,r)
  local dict = tostring(a[1])
  local anim = tostring(a[2])
  local flag = tonumber(a[3])
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do
    Wait(10)
  end
  TaskPlayAnim(PlayerPedId(), dict, anim, 8.0, 1.0, (-1), flag, 0, 0, 0, 0)
end)

RegisterCommand('.stopanim', function()
  ClearPedTasksImmediately(PlayerPedId())
  ClearPedSecondaryTask(PlayerPedId())
end)

function SpawnStoreClerk(n)
  if n then
  if rob[n] then
  if rob[n].spawn then 
    if not rob[n].clerk then 
      local i        = clerkModels[math.random(#clerkModels)]
      local mdl      = GetHashKey(i)
      local loadTime = GetGameTimer() + 5000
      RequestModel(mdl)
      while not HasModelLoaded(mdl) do
        Wait(10)
        if GetGameTimer() > loadTime then 
          print("DEBUG - Failed to load ped model ("..tostring(i)..")")
          break
        end
      end
      rob[n].clerk = CreatePed(PED_TYPE_MISSION,mdl,rob[n].spawn,rob[n].h,0,0)
      Citizen.CreateThread(function()
        while rob[n].clerk do 
          if not DoesEntityExist(rob[n].clerk) then
            print("DEBUG - Clerk ceased to exist.")
            rob[n].clerk = nil
            Citizen.Wait(30000)
          else
            if IsPedDeadOrDying(rob[n].clerk) then
              print("DEBUG - Ped died.")
              Citizen.Wait(30000)
              rob[n].clerk = nil
            elseif #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(rob[n].clerk)) > 500.0 then 
              print("DEBUG - Too far away. Clerk despawned.")
              DeletePed(rob[n].clerk)
              rob[n].clerk = nil
            end
          end
          Citizen.Wait(1000)
        end
      end)
      return true
    end
  else print("DEBUG - No spawn point exists.")
  end
  else print("DEBUG - No such store exists ("..n..").")
  end
  else print("DEBUG - No 'n' given.")
  end
  return false
end


function StartRobbery(n)
  local attack = false
  local take = 0
  TriggerServerEvent('cnr:robbery_send_lock', n)
  exports['cnrobbers']:WantedPoints(30, "Brandishing a Firearm (417 PC)")
  rob[n].lockout = true
  Citizen.CreateThread(function()
    while isRobbing do 
      SetBlockingOfNonTemporaryEvents(rob[n].clerk, true)
      Citizen.Wait(0)
    end
    Wait(10)
    if not attack then
      TaskReactAndFleePed(rob[n].clerk, PlayerPedId())
    end
  end)
  local dict = "random@mugging3"
  RequestAnimDict(dict)
  while not HasAnimDictLoaded(dict) do Wait(1) end
  TaskPlayAnim(rob[n].clerk, dict, "handsup_standing_base", 8.0, 1.0, 2000, 2, 1.0, 0, 0, 0)
  Citizen.Wait(2000)
  local dct2 = "random@shop_robbery"
  RequestAnimDict(dct2)
  while not HasAnimDictLoaded(dct2) do Wait(1) end
  local choice = math.random(1, 100) > 90
  if choice then
    attack = true
    GiveWeaponToPed(rob[n].clerk, GetHashKey("WEAPON_PISTOL50"), 24, true, true)
    TaskPlayAnim(rob[n].clerk, dct2, "robbery_action_a", 8.0, 1.0, 1200, 0, 1.0, 0, 0, 0)
    Citizen.Wait(800)
    isRobbing = false
    TaskCombatPed(rob[n].clerk, PlayerPedId(), 0, 16)
  else
    TaskPlayAnim(rob[n].clerk, dct2, "robbery_action_f", 8.0, 1.0, (-1), 3, 1.0, 0, 0, 0)
    local maxTime = GetGameTimer() + 9800
    while IsPlayerFreeAiming(PlayerId()) do 
      take = take + math.random(5,30)
      if GetGameTimer() > maxTime then 
        break
      end
      Wait(100)
    end
    exports['cnrobbers']:WantedPoints(50, "Armed Robbery (211 PC)")
    if take > 0 then 
      print("DEBUG - Robbery Take: $"..take)
      hasBag = true
      SetPedComponentVariation(PlayerPedId(), 5, bagDraw, 0, 0)
    end
    isRobbing = false
    TriggerServerEvent('cnr:robbery_take', take)
  end
end


function CreateRobberyClerks()
  print("DEBUG - Creating clerks and checking for robbery.")
  Citizen.CreateThread(function()
    while true do 
      local ped   = PlayerPedId()
      local myPos = GetEntityCoords(PlayerPedId())
      for k,v in pairs(rob) do 
        if not v.clerk then 
          if #(myPos - v.stand) < 100.0 then
            if SpawnStoreClerk(k) then print("DEBUG - Successful.")
            else print("DEBUG - Failed to create clerk for store #"..k)
            end
          end
        end
      end
      if not isRobbing then
        local isAim, ent = GetEntityPlayerIsFreeAimingAt(PlayerId())
        if isAim and IsEntityAPed(ent) then 
          for k,v in pairs(rob) do
            if not v.lockout then
              if ent == v.clerk then 
                isRobbing = true
                StartRobbery(k)
              end
            else
              TriggerEvent('chat:addMessage', {args = {
                "COOLDOWN", "Recently Robbed - The register is empty!"
              }})
              Citizen.Wait(5000)
            end
          end
        end
      end
      if takeDrops[1] then
        for k,v in pairs (takeDrops) do 
          if #(myPos - (v.pos)) < 2.25 then 
            TriggerServerEvent('cnr:robbery_dropped')
            SetPedComponentVariation(PlayerPedId(), 5, 0, 0, 0)
            DestroyDropSpots()
          end
        end
      end
      Citizen.Wait(10)
    end
  end)
end
AddEventHandler('cnr:loaded', CreateRobberyClerks)
RegisterCommand('dbugrob', CreateRobberyClerks)

--- EVENT cnr:robbery_lock_status
-- Tells the client that a lock status for store (n) has changed
AddEventHandler('cnr:robbery_lock_status', function(n, lockStatus)
  rob[n].lockout = true
end)

--- EVENT cnr:robbery_locks 
-- Tells the client the lock status of all robbery events
-- Received when loaded into the game
AddEventHandler('cnr:robbery_locks', function(locks)
  for k,v in pairs (locks) do 
    rob[k].lockout = v
  end
end)

function DestroyDropSpots()
  for k,v in pairs (takeDrops) do 
    if DoesBlipExist(v.blip) then 
      RemoveBlip(v.blip)
    end
  end
  takeDrops = {}
end

--- EVENT cnr:robbery_drops
-- Tells the client that they have robbery take that can be dropped off
-- Creates blips
function OfferDropSpots(giveBag)

  -- Only update blips if the player has a robbery bag 
  if hasBag then
  
    -- Ensure they don't have drop offers already
    DestroyDropSpots()
  
    -- If bool passed, spawn bag
    if giveBag then SetPedComponentVariation(PlayerPedId(), 5, bagDraw, 0, 0) end
    
    local z        = exports['cnrobbers']:GetActiveZone()
    print("DEBUG - Current Active Zone: "..z)
    local eligible = dropSpots[z]
    
    while #takeDrops < 4 do
      local n = math.random(#eligible)
      takeDrops[#takeDrops + 1] = {pos = table.remove(eligible, n)}
      print("DEBUG - Inserted 1 Drop Point @ X:"..
        takeDrops[#takeDrops].pos.x..", Y:"..
        takeDrops[#takeDrops].pos.y..", Z:"..
        takeDrops[#takeDrops].pos.z
      )
      Wait(0)
    end
    
    for k,v in pairs(takeDrops) do 
      v.blip = AddBlipForCoord(v.pos.x, v.pos.y, v.pos.z)
      SetBlipSprite(v.blip, 431)
      SetBlipColour(v.blip, 11)
      SetBlipDisplay(v.blip, 2)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Money Laundering")
      EndTextCommandSetBlipName(v.blip)
      print("DEBUG - Blip created for takeDrops #"..k..".")
    end
  end
end
AddEventHandler('cnr:robbery_drops', function()
  OfferDropSpots(true)
end)

AddEventHandler('cnr:zone_change', function()
  DestroyDropSpots()
  OfferDropSpots()
end)


