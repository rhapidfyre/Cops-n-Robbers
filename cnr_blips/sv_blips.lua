
--[[
  Cops and Robbers: Radar Blips (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  08/12/2019

  This file handles radar blips for players, and radar locations not necessarily
  belonging to any script (random weapon pickups, etc)

  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

local cops = {}

RegisterServerEvent('cnr:police_status')
AddEventHandler('cnr:police_status', function(onDuty)
  cops[source] = onDuty
  local numCops = exports['cnr_police']:CountCops()
  TriggerClientEvent('')
  local dt      = os.date("%H:%M:%S", os.time())
  if numCops < 1 then
    print("[CNR "..dt.."] There are no cops on duty.")
  elseif numCops == 1 then
    print("[CNR "..dt.."] There is now 1 cop on duty.")
  else
    print("[CNR "..dt.."] There are now "..numCops.." cops on duty.")
  end
end)
