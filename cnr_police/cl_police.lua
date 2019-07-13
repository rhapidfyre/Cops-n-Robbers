
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
local prevClothes = {}

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
    for k,v in pairs (copUniform) do
      SetPedComponentVariation(PlayerPedId(),k, v.draw, v.text, 2)
    end
  else
    TriggerEvent('chat:addMessage', {
      args = {"^1You cannot go on police duty while wanted!"}
    })
    Citizen.Wait(5000)
  end
  TaskGoToCoordAnyMeans(PlayerPedId(), c.walkTo, 1.0, 0, 0, 786603, 0)
  Citizen.Wait(4800)
  if wp < 1 then
    exports['cnrobbers']:ChatNotification(
      "CHAR_CALL911", "Police Duty", "~g~Start of Watch",
      "You are now on Law Enforcement duty."
    )
    PoliceDutyLoops()
  end
  ignoreDuty = false
  transition = false
end


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
  TaskGoToCoordAnyMeans(PlayerPedId(), c.walkTo, 1.0, 0, 0, 786603, 0)
  Citizen.Wait(4800)
  exports['cnrobbers']:ChatNotification(
    "CHAR_CALL911", "Police Duty", "~r~End of Watch",
    "You are no longer on Law Enforcement duty."
  )
  OffDutyLoops()
  ignoreDuty = false
  transition = false
end


function OffDutyLoops()
  Citizen.CreateThread(function()
    while not isCop do
      Citizen.Wait(0)
    end
  end)
end

function PoliceDutyLoops()
  Citizen.CreateThread(function()
    while isCop do 
      Citizen.Wait(0)
    end
  end)
end

Citizen.CreateThread(function()
  Citizen.Wait(2000)
  OffDutyLoops()
end)

Citizen.CreateThread(function()
  while true do 
    local myPos = GetEntityCoords(PlayerPedId())
    if not ignoreDuty then
      for k,v in pairs(depts) do
        if #(myPos - v.duty) < 2.1 then
          if isCop then EndCopDuty(k)
          else BeginCopDuty(k)
          end
        end
      end
    end
    Citizen.Wait(100)
  end
end