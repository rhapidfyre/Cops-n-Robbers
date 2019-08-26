
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
RegisterNetEvent('cnr:police_reduty')


local isCop          = false  -- True if player is on cop duty
local ignoreDuty     = false  -- Disables cop duty point
local cam            = nil
local transition     = false
local enteringCopCar = false
local prevClothes    = {}
local myAgency       = 0

local forcedutyEnabled = true


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


--- EXPORT: DutyAgency()
-- Returns the agency the player is working for
-- @return The agency value; 0 means off duty.
function DutyAgency()
  return myAgency
end

-- Wanted Point weights for certain actions
local wp = {
  attempt = 10, -- Atempt to Steal Public Safety
  carjack = 50, -- Carjack public safety
  gta     = 40  -- Steal Public Safety Vehicle
}


--- EXPORT: DutyStatus()
-- Returns whether the player is on cop duty
-- DEBUG - Obsolete? (Use DutyAgency() > 0 ??)
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
local oldModel = 0 -- DEBUG - Remove this when going back to MP models
function BeginCopDuty(st)
  print("DEBUG - Beginning cop duty @ station #"..st)
  local c  = depts[st]
  local wanted = exports['cnr_wanted']:GetWanteds()
  local ply = GetPlayerServerId(PlayerId())
  if not wanted[ply] then wanted[ply] = 0 end
  if wanted[ply] < 1 then
    print("DEBUG - Starting duty assignments.")
    transition = true
    print("DEBUG - Doing camera.")
    PoliceCamera(c)
    print("DEBUG - Setting duty variables")
    isCop = true
    print("DEBUG - Setting clothes.")
    --[[
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
    end]]
    
    -- DEBUG - Using Ped Model System
    oldModel = GetEntityModel(PlayerPedId())
    print(oldModel)
    local newModel = GetHashKey('s_m_y_cop_01')
    RequestModel(newModel)
    while not HasModelLoaded(newModel) do Wait(1) end
    SetPlayerModel(PlayerId(), newModel)
    SetModelAsNoLongerNeeded(newModel)
  
    print("DEBUG - Clothes set.")
    TriggerServerEvent('cnr:police_status', true)
    TriggerEvent('cnr:police_duty', true)
    print("DEBUG - Event(s) Triggered.")
    TaskGoToCoordAnyMeans(PlayerPedId(), c.walkTo, 1.0, 0, 0, 786603, 0)
    print("DEBUG - Walking to exit.")
    PoliceLoadout(true)
    print("DEBUG - Loadout Given.")
    Citizen.Wait(4800)
    print("DEBUG - ChatNotification().")
    exports['cnrobbers']:ChatNotification(
      "CHAR_CALL911", "Police Duty", "~g~Start of Watch",
      "You are now on Law Enforcement duty."
    )
    print("DEBUG - myAgency["..tostring(c.agency).."]")
    myAgency = c.agency
    PoliceDutyLoops()
  else
    TriggerEvent('chat:addMessage', {
      args = {"^1You cannot go on police duty while wanted!"}
    })
    TriggerEvent('chat:addMessage', {
      args = {"^1WANTED LEVEL: ^7"..(wanted[GetPlayerServerId(PlayerId())])}
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
  --[[
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
  end]]
  
  -- DEBUG - Using Ped Model System
  oldModel = GetEntityModel(PlayerPedId())
  print(oldModel)
  local newModel = GetHashKey('s_m_y_cop_01')
  RequestModel(newModel)
  while not HasModelLoaded(newModel) do Wait(1) end
  SetPlayerModel(PlayerId(), newModel)
  SetModelAsNoLongerNeeded(newModel)
    
  TriggerServerEvent('cnr:police_status', true)
  TriggerEvent('cnr:police_duty', true)
  PoliceLoadout(true)
  PoliceDutyLoops()
  Citizen.Wait(1000)
  transition = false
  exports['cnrobbers']:ChatNotification(
    "CHAR_CALL911", "Police Duty", "~y~Restarting Watch",
    "You are now on Law Enforcement duty."
  )
end
RegisterNetEvent('cnr:police_reduty')
AddEventHandler('cnr:police_reduty', Reduty)
-- DEBUG - /forceduty
RegisterCommand('forceduty', function()
  if forcedutyEnabled then 
    if not isCop then Reduty()
    else
      TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
        "Already on Law Enforcement duty!"
      }})
    end
  end
end)


--- EndCopDuty()
-- Sets a civilian to be a police officer
-- Checks if player is wanted before going on duty
function EndCopDuty(st)
  local c = depts[st]
  transition = true
  myAgency   = 0
  PoliceCamera(c)
  --[[
  for k,v in pairs (prevClothes) do
    SetPedComponentVariation(PlayerPedId(),k, v.draw, v.text, 2)
  end]]
  
  -- DEBUG - Using Ped Model System
  RequestModel(oldModel)
  while not HasModelLoaded(oldModel) do Wait(1) end
  SetPlayerModel(PlayerId(), oldModel)
  SetModelAsNoLongerNeeded(oldModel)
    
  TriggerServerEvent('cnr:police_status', false)
  TriggerEvent('cnr:police_duty', false)
  TaskGoToCoordAnyMeans(PlayerPedId(), c.walkTo, 1.0, 0, 0, 786603, 0)
  Citizen.Wait(4800)
  exports['cnrobbers']:ChatNotification(
    "CHAR_CALL911", "Police Duty", "~r~End of Watch",
    "You are no longer on Law Enforcement duty."
  )
  PoliceLoadout(false)
  isCop      = false
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


--- ImprisonClient()
-- Sends the given ID (or closest player) to prison if they are Wanted
function ImprisonClient(client)
  if isCop then
    print("DEBUG - Try to jail client.")
    if not client then
      client = exports['cnrobbers']:GetClosestPlayer()
      print("DEBUG - Imprisoning nearest client.")
    end
    local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(client)))
    if dist < 2.0 then
      print("DEBUG - Trying to imprison "..GetPlayerName(client))
      TriggerServerEvent('cnr:prison_sendto', GetPlayerServerId(client))
    else
      TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
        "Too far away, get closer!"
      }})
    end
  else
    TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
      "You are not on Law Enforcement duty!"
    }})
  end
end
RegisterCommand('jail', ImprisonClient)
RegisterCommand('prison', ImprisonClient)
RegisterCommand('ticket', ImprisonClient)


-- DEBUG - ctr is used to determine if B was pressed twice to upgrade alarm to emergent
-- I need to find a better way to implement this later.
local ctr = 1
local lastRequest = 0
function PoliceDutyLoops()
  print("DEBUG - PoliceDutyLoops()")
  Citizen.CreateThread(function()
    while isCop do 
      if IsControlJustPressed(0, 75) then UnlockPoliceCarDoor() -- F
      
      elseif IsControlJustPressed(0, 29) and GetLastInputMethod(2) then -- B
        if lastRequest < GetGameTimer() then
          lastRequest = GetGameTimer() + 30000
          RequestBackup(true)
        end
        
      elseif IsControlJustPressed(0, 288) then
        print("DEBUG - ImprisonClient() [F1]")
        ImprisonClient() -- F1
      
      end
      Citizen.Wait(0)
    end
  end)
end


Citizen.CreateThread(function()
  while true do 
    if not ignoreDuty and not transition then
      local myPos = GetEntityCoords(PlayerPedId())
      for i = 1, #depts do
        if #(myPos - (depts[i].duty)) < 2.1 then
          ignoreDuty = true
          if isCop then EndCopDuty(i)
          else BeginCopDuty(i)
          end
        end
        Citizen.Wait(100)
      end
    end
    Citizen.Wait(1)
  end
end)



--[[
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
]]





Citizen.CreateThread(function()
	while true do
		for i = 1, 14 do EnableDispatchService(i, false) end
		SetPlayerWantedLevel(PlayerId(), 0, false)
		SetPlayerWantedLevelNow(PlayerId(), false)
		SetPlayerWantedLevelNoDrop(PlayerId(), 0, false)
		Wait(0)
	end
end)

local restricted = {
  ["RHINO"] = true,
}
Citizen.CreateThread(function()
  while true do 
    Wait(0)

    --[[ Stops cops from dropping weapons
    for ped in exports['southland']:EnumeratePeds() do 
      if ped then 
        if ped > 0 then
          SetPedDropsWeaponsWhenDead(ped, false)
        end
      end
      Citizen.Wait(100)
    end]]

    -- If player gets in a restricted vehicle, delete it
    local vehc = GetVehiclePedIsTryingToEnter(PlayerPedId())
    if vehc > 0 then
      local mdl = GetDisplayNameFromVehicleModel(GetEntityModel(vehc))
      if restricted[mdl] then
        if true then --exports['ham']:MyAdminLevel() < 4 then
          TaskLeaveVehicle(PlayerPedId(), vehc, 16)
        end
      end
      Citizen.Wait(1000)
    end
  end
end)

Citizen.CreateThread(function()
  -- Removes air traffic
  local scenes = {
    world = {
      "WORLD_VEHICLE_MILITARY_PLANES_SMALL",
      "WORLD_VEHICLE_MILITARY_PLANES_BIG"
    },
    groups = {
      2017590552, -- LSX Traffic
      2141866469, -- Sandy Shores Air Traffic
      1409640232, -- Grapeseed Air Traffic
      "ng_planes", -- Airborne Air Traffic
    },
    planes = {
      "SHAMAL", "LUXOR", "LUXOR2", "JET", "LAZER", "TITAN",
      "BARRACKS", "BARRACKS2", "CRUSADER", "RHINO", "AIRTUG", "RIPLEY"
    }
  }
  while true do
    for _, sctyp in next, (scenes.world) do
      SetScenarioTypeEnabled(sctyp, false)
    end
    for _, scgrp in next, (scenes.groups) do
      SetScenarioGroupEnabled(scgrp, false)
    end
    for _, model in next, (scenes.planes) do
      SetVehicleModelIsSuppressed(GetHashKey(model), true)
    end
    Citizen.Wait(10000)
  end
end)
