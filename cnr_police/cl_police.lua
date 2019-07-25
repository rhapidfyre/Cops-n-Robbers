
--[[
  Cops and Robbers: Law Enforcement Scripts (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  07/12/2019
  
  This file handles all client-sided law enforcement functionality in the game
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

local isCop       = false  -- True if player is on cop duty
local ignoreDuty  = false  -- Disables cop duty point
local cam         = nil
local transition  = false
local enteringCopCar = false
local prevClothes = {}

-- Wanted Point weights for certain actions
local wp = {
  attempt = 10, -- Atempt to Steal Public Safety
  carjack = 50, -- Carjack public safety
  gta     = 40  -- Steal Public Safety Vehicle
}

--- EXPORT: DutyStatus()
-- Returns whether the player is on cop duty
-- @return True if on cop duty, false if not
function DutyStatus()
  return isCop
end

-- DEBUG -
RegisterCommand('cset', function(s,a,r)
  SetPedComponentVariation(PlayerPedId(),
    tonumber(a[1]), tonumber(a[2]), tonumber(a[3]), 2
  )
end)
RegisterCommand('nextitem', function(s,a,r)
  local slotNumber = tonumber(a[1])
  local i = GetPedDrawableVariation(PlayerPedId(), slotNumber)
  SetPedComponentVariation(PlayerPedId(), slotNumber, i+1, 0, 0)
  print("DEBUG - Slot ["..slotNumber.."] Current item #"..i+1)
end)
RegisterCommand('previtem', function(s,a,r)
  local slotNumber = tonumber(a[1])
  local i = GetPedDrawableVariation(PlayerPedId(), slotNumber)
  SetPedComponentVariation(PlayerPedId(), slotNumber, i-1, 0, 0)
  print("DEBUG - Slot ["..slotNumber.."] Current item #"..i-1)
end)

--- PoliceLoadout()
-- Toggles the usage of police equipment
-- DEBUG - Change later to compensate for player-owned weapons
function PoliceLoadout(toggle)
  local ped = PlayerPedId()
  RemoveAllPedWeapons(ped)
  if toggle then -- Give police weapons
    GiveWeaponToPed(ped, GetHashKey("WEAPON_STUNGUN"), 1, true, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_NIGHTSTICK"), 1, true, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 200, true, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_CARBINERIFLE"), 200, true, false)
  else -- Give owned weapons
    
  end
end

--- PoliceCamera()
-- Operates the camera when toggling duty
function PoliceCamera(c)
  if not DoesCamExist(cam) then
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
  end
  SetCamActive(cam, true)
  RenderScriptCams(true, true, 500, true, true)
  SetCamParams(cam,
    c.camview.x, c.camview.y, c.camview.z,
    c.caminfo.rotx, c.caminfo.roty, c.caminfo.rotz,
    c.caminfo.fov
  )
  Citizen.CreateThread(function()
    while transition do 
      HideHudAndRadarThisFrame()
      Citizen.Wait(0)
    end
  end)
  if c.leave then 
    SetEntityCoords(PlayerPedId(), c.leave)
  end
  Citizen.Wait(3000)
  DoScreenFadeOut(400)
  Citizen.Wait(600)
  SetCamParams(cam,
    c.exitcam.x, c.exitcam.y, c.exitcam.z,
    c.caminfo.erotx, c.caminfo.eroty, c.caminfo.erotz,
    c.caminfo.efov
  )
  Citizen.Wait(1000)
  DoScreenFadeIn(1000)
  Citizen.Wait(200)
  Citizen.CreateThread(function()
    Citizen.Wait(4600)
    SetCamActive(cam, false)
    RenderScriptCams(false, true, 500, true, true)
    cam = nil
  end)
end


--- BeginCopDuty()
-- Sets a civilian to be a police officer
-- Checks if player is wanted before going on duty
function BeginCopDuty(st)
  local c  = depts[st]
  local wp = exports['cnrobbers']:WantedPoints()
  ignoreDuty = true
  if wp < 1 then 
    transition = true
    PoliceCamera(c)
    isCop = true
    prevClothes = {
      [3]  = {draw = GetPedDrawableVariation(PlayerPedId(), 3),
              text = GetPedTextureVariation(PlayerPedId(), 3)},
      [4]  = {draw = GetPedDrawableVariation(PlayerPedId(), 4),
              text = GetPedTextureVariation(PlayerPedId(), 4)},
      [6]  = {draw = GetPedDrawableVariation(PlayerPedId(), 6),
              text = GetPedTextureVariation(PlayerPedId(), 6)},
      [8]  = {draw = GetPedDrawableVariation(PlayerPedId(), 8),
              text = GetPedTextureVariation(PlayerPedId(), 8)},
      [11] = {draw = GetPedDrawableVariation(PlayerPedId(), 11),
              text = GetPedTextureVariation(PlayerPedId(), 11)},
    }
    for k,v in pairs (copUniform[GetEntityModel(PlayerPedId())]) do
      SetPedComponentVariation(PlayerPedId(),k, v.draw, v.text, 2)
    end
    TriggerServerEvent('cnr:police_status', true)
    TriggerEvent('cnr:police_duty', true)
    TaskGoToCoordAnyMeans(PlayerPedId(), c.walkTo, 1.0, 0, 0, 786603, 0)
    PoliceLoadout(true)
    Citizen.Wait(4800)
    exports['cnrobbers']:ChatNotification(
      "CHAR_CALL911", "Police Duty", "~g~Start of Watch",
      "You are now on Law Enforcement duty."
    )
    PoliceDutyLoops()
  else
    TriggerEvent('chat:addMessage', {
      args = {"^1You cannot go on police duty while wanted!"}
    })
    Citizen.Wait(12000)
  end
  ignoreDuty = false
  transition = false
end


--- Reduty()
-- Called if the player just needs a uniform and loadout
function Reduty()
  transition = true
  isCop      = true
  prevClothes = {
    [3]  = {draw = GetPedDrawableVariation(PlayerPedId(), 3),
            text = GetPedTextureVariation(PlayerPedId(), 3)},
    [4]  = {draw = GetPedDrawableVariation(PlayerPedId(), 4),
            text = GetPedTextureVariation(PlayerPedId(), 4)},
    [6]  = {draw = GetPedDrawableVariation(PlayerPedId(), 6),
            text = GetPedTextureVariation(PlayerPedId(), 6)},
    [8]  = {draw = GetPedDrawableVariation(PlayerPedId(), 8),
            text = GetPedTextureVariation(PlayerPedId(), 8)},
    [11] = {draw = GetPedDrawableVariation(PlayerPedId(), 11),
            text = GetPedTextureVariation(PlayerPedId(), 11)},
  }
  for k,v in pairs (copUniform[GetEntityModel(PlayerPedId())]) do
    SetPedComponentVariation(PlayerPedId(),k, v.draw, v.text, 2)
  end
  TriggerServerEvent('cnr:police_status', true)
  TriggerEvent('cnr:police_duty', true)
  PoliceLoadout(true)
  Citizen.Wait(3000)
  transition = false
end
RegisterNetEvent('cnr:police_reduty')
AddEventHandler('cnr:police_reduty', Reduty)


--- EndCopDuty()
-- Sets a civilian to be a police officer
-- Checks if player is wanted before going on duty
function EndCopDuty(st)
  local c = depts[st]
  ignoreDuty = true
  transition = true
  PoliceCamera(c)
  isCop = false
  for k,v in pairs (prevClothes) do
    SetPedComponentVariation(PlayerPedId(),k, v.draw, v.text, 2)
  end
  TriggerServerEvent('cnr:police_status', false)
  TriggerEvent('cnr:police_duty', false)
  TaskGoToCoordAnyMeans(PlayerPedId(), c.walkTo, 1.0, 0, 0, 786603, 0)
  Citizen.Wait(4800)
  exports['cnrobbers']:ChatNotification(
    "CHAR_CALL911", "Police Duty", "~r~End of Watch",
    "You are no longer on Law Enforcement duty."
  )
  OffDutyLoops()
  PoliceLoadout(false)
  ignoreDuty = false
  transition = false
end


function UnlockPoliceCarDoor()
  local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
  if veh > 0 then 
    local mdl = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
    if policeCar[mdl] then
      if GetVehicleDoorLockStatus(veh) > 0 then 
        if isCop then 
          SetVehicleDoorsLocked(veh, 0)
          SetVehicleNeedsToBeHotwired(veh, false)
          Citizen.CreateThread(function()
            Citizen.Wait(6000)
            if GetVehiclePedIsIn(PlayerPedId()) ~= veh then 
              SetVehicleDoorsLocked(veh, 2)
              SetVehicleNeedsToBeHotwired(veh, true)
            end
          end)
        end
      end
    end
  end
end


function PoliceDutyLoops()
  Citizen.CreateThread(function()
    while isCop do 
      if IsControlJustPressed(0, 75) then -- F
        UnlockPoliceCarDoor()
      end
      Citizen.Wait(1)
    end
  end)
end

Citizen.CreateThread(function()
  while true do 
    local myPos = GetEntityCoords(PlayerPedId())
    if not ignoreDuty then
      for i = 1, #depts do
        if #(myPos - (depts[i].duty)) < 2.1 then
          if isCop then EndCopDuty(i)
          else BeginCopDuty(i)
          end
        end
        Citizen.Wait(1)
      end
    end
    Citizen.Wait(10)
  end
end)