
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
  local numCops = CountCops()
  TriggerClientEvent('')
end)
