
--[[
  Cops and Robbers: Radar Blips (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  08/12/2019

  This file handles radar blips for players, and radar locations not necessarily
  belonging to any script (random weapon pickups, etc)

  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]
RegisterNetEvent('cnr:police_officer_duty')
RegisterNetEvent('cnr:wanted_client')

local plyBlip = {}
local largeMap = false

Citizen.CreateThread(function()
  while true do
  	Citizen.Wait(1)
  	if IsControlJustReleased(0, 20) then
      largeMap = not largeMap
  	  SetRadarBigmapEnabled(largeMap, false)
  	end
  end
end)


local function CNRBlipColour(blip, wLevel, cLevel)
  if cLevel then
    if cLevel < 2       then SetBlipColour(blip, 12)
    elseif cLevel < 5   then SetBlipColour(blip, 18)
    elseif cLevel < 8   then SetBlipColour(blip, 30)
    elseif cLevel < 10  then SetBlipColour(blip, 42)
    else                     SetBlipColour(blip, 63)
    end     
  else
    if wLevel < 1       then SetBlipColour(blip, 0)
    elseif wLevel < 4   then SetBlipColour(blip, 5)
    elseif wLevel < 7   then SetBlipColour(blip, 44)
    elseif wLevel < 10  then SetBlipColour(blip, 47)
    else                     SetBlipColour(blip, 49)
    end     
  end
end


-- Ensures blips are created for all players
function DrawPlayerBlips()
  Citizen.Wait(3000)
  local temp = GetActivePlayers()
  for _,ply in ipairs (temp) do
    if ply ~= PlayerId() then
      local blip = GetBlipFromEntity(GetPlayerPed(ply))
      if DoesBlipExist(blip) then
        print("DEBUG - Removed existing blip for Player #"..GetPlayerServerId(ply))
        RemoveBlip(blip)
      end
    end
  end 
  while true do
    local plys = GetActivePlayers()
    for _,ply in ipairs (plys) do
      if ply ~= PlayerId() then
      
        local ped    = GetPlayerPed(ply)
        local exists = GetBlipFromEntity(ped)
        
        if not DoesBlipExist(exists) then
          local blip = AddBlipForEntity(ped)
          local svid = GetPlayerServerId(ply)
          SetBlipAsFriendly(blip, true)
          SetBlipSprite(blip, 1)
          local wLevel = exports['cnr_wanted']:WantedLevel(svid)
          print("DEBUG - wLevel = "..wLevel)
          local cLevel = exports['cnr_police']:DutyStatus(svid)
          print("DEBUG - cLevel = "..tostring(cLevel))
          CNRBlipColour(blip, wLevel, cLevel)
          SetBlipColour(blip, 0)
          SetBlipScale(blip, 0.8)
          print("DEBUG - Created blip for Player #"..svid)
        end
      end
    end
    Citizen.Wait(1000)
  end
end


AddEventHandler('cnr:wanted_client', function(ply)
  local client = GetPlayerFromServerId(ply)
  local wLevel = exports['cnr_wanted']:WantedLevel(ply)
  local blip = GetBlipFromEntity(GetPlayerPed(client))
  if DoesBlipExist(blip) then
    CNRBlipColour(blip, wLevel, cLevel)
  end
end)


AddEventHandler('cnr:police_officer_duty', function(ply, onDuty, cLevel)
  local client = GetPlayerFromServerId(ply)
  local blip   = GetBlipFromEntity(GetPlayerPed(client))
  if onDuty then
    CNRBlipColour(blip, wLevel, cLevel)
  else
    SetBlipColour(plyBlip[client], 0)
  end
end)


-- Starts functions / loops upon script load
Citizen.CreateThread(DrawPlayerBlips)




