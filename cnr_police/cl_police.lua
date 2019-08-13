
--[[
  Cops and Robbers: Law Enforcement Scripts (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  07/12/2019
  
  This file handles all client-sided law enforcement functionality in the game
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]


RegisterNetEvent('cnr:dispatch') -- Receives a dispatch broadcast from Server
RegisterNetEvent('cnr:police_blip_backup') -- Changes blip settings on backup request


local isCop          = false  -- True if player is on cop duty
local ignoreDuty     = false  -- Disables cop duty point
local cam            = nil
local transition     = false
local enteringCopCar = false
local prevClothes    = {}


function DispatchMessage(title, msg)
  TriggerEvent('chat:addMessage', {
    color = {0,180,255}, multiline = true, args = {
      "DISPATCH", "^3"..title.."\n^5"..msg
    }
  })
end

function DispatchNotification(title, msg)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	SetNotificationMessage("CHAR_CALL911", "CHAR_CALL911", 0, 1, "Regional 9-1-1", "~y~"..title)
	DrawNotification(false, true)
	PlaySoundFrontend(-1, "GOON_PAID_SMALL", "GTAO_Boss_Goons_FM_SoundSet", 0)
  return true
end

function DispatchBlip(x,y,z,title)
  if not title then title = "911" end
  local callBlip = AddBlipForCoord(x,y,z)
  SetBlipSprite(callBlip, 526)
  SetBlipColour(callBlip, 1)
  SetBlipScale(callBlip, 0.78)
  SetBlipDisplay(callBlip, 2)
  SetBlipFlashes(callBlip, true)
  SetBlipFlashTimer(callBlip, 3000)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString(title)
  EndTextCommandSetBlipName(callBlip)
  Citizen.CreateThread(function()
    Citizen.Wait(60000)
    if DoesBlipExist(callBlip) then RemoveBlip(callBlip) end
  end)
end

RegisterCommand('disp', function()
  SendDispatch("Silent Alarm", "LTD Gasoline", "Grove Street", -46.9504, -1758.19, 29.421)
end)

--- EXPORT: DispatchMessage()
-- Sends a message to on duty cop as dispatch
function SendDispatch(title, place, area, x, y, z)
  if isCop then 
    if x and y and z then
      if not title then title = "9-1-1" end
      if not place then place = "Cell Phone 911" end
      if not area then area   = "Unknown Area" end
      DispatchMessage(title, place.." ("..area..")")
      DispatchNotification(title, place.."~n~"..area)
      DispatchBlip(x, y, z, title)
    end
  end
end
AddEventHandler('cnr:dispatch', SendDispatch)


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


function RequestBackup(emergent)
  local pos    = GetEntityCoords(PlayerPedId())
  local myArea = exports['cnrobbers']:GetFullZoneName(GetNameOfZone(pos.x,pos.y,pos.z))
  if emergent then 
    TriggerServerEvent('cnr:police_backup', true, "Backup Request",
      "^1Immediate Need", myArea, pos.x, pos.y, pos.z      
    )
  else
    TriggerServerEvent('cnr:police_backup', false, "Backup Request",
      "^3Urgent Need", myArea, pos.x, pos.y, pos.z      
    )
  end
end


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
  SetCamParams(cam, c.exitcam.x, c.exitcam.y, c.exitcam.z,
    c.caminfo.erotx, c.caminfo.eroty, c.caminfo.erotz, c.caminfo.efov
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

-- DEBUG - ctr is used to determine if B was pressed twice to upgrade alarm to emergent
-- I need to find a better way to implement this later.
local ctr = 1
local lastRequest = 0
function PoliceDutyLoops()
  Citizen.CreateThread(function()
    while isCop do 
      if IsControlJustPressed(0, 75) then -- F
        UnlockPoliceCarDoor()
      elseif IsControlJustPressed(0, 29) and GetLastInputMethod(2) then -- B
        if lastRequest < GetGameTimer() then
          lastRequest = GetGameTimer() + 30000
          RequestBackup(true)
        end
      end
      Citizen.Wait(1)
    end
  end)
end


AddEventHandler('cnr:client_loaded', function()
  Citizen.Wait(5000)
  while true do 
    if not ignoreDuty then
      local myPos = GetEntityCoords(PlayerPedId())
      for i = 1, #depts do
        if #(myPos - (depts[i].duty)) < 2.1 then
          --[[if isCop then EndCopDuty(i)
          else BeginCopDuty(i)
          end]]
        end
        Citizen.Wait(10)
      end
    end
    Citizen.Wait(10)
  end
end)


local backupBlips = {}
AddEventHandler('cnr:police_blip_backup', function(ply)
  local plys = exports['cnrobbers']:GetPlayers()
  for k,v in pairs (plys) do 
    if GetPlayerFromServerId(ply) == v then 
      if DoesBlipExist(v) then 
        
      else
      
      end
    end
  end
end)