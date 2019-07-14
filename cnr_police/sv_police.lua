
--[[
  Cops and Robbers: Law Enforcement Scripts (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  07/12/2019
  
  This file handles all server-sided law enforcement functionality in the game
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

local cops    = {}
local dropCop = {}

function CountCops()
  local n = 0
  for k,v in pairs(cops) do
    if v then 
      n = n + 1
      print("DEBUG - Counted +1 Cops")
    end
  end
  return n
end

RegisterServerEvent('cnr:police_status')
AddEventHandler('cnr:police_status', function(onDuty)
  cops[source] = onDuty
  local numCops = CountCops()
  local dt      = os.date("%H:%M:%S", os.time())
  if numCops < 1 then
    print("[CNR "..dt.."] There are no cops on duty.")
  elseif numCops == 1 then
    print("[CNR "..dt.."] There is now 1 cop on duty.")
  else
    print("[CNR "..dt.."] There are now "..numCops.." cops on duty.")
  end
end)

RegisterServerEvent('cnr:client_loaded')
AddEventHandler('cnr:client_loaded', function()
  local ply = source
  local uid = exports['cnr_charcreate']:GetUniqueId(ply)
  for k,v in pairs(dropCop) do 
    if v == uid then 
      TriggerClientEvent('cnr:police_reduty', source)
      TriggerClientEvent('chat:addMessage', {
        color = {255,180,40},
        multiline = true,
        args = {"SERVER", "You were on duty when you logged out, "..
                          "so your duty status has been restored."}
      })
    end
  end
end)

-- Adds player to dropped cops table, so their duty status
-- can be returned if they come back within 10 minutes
AddEventHandler('playerDropped', function()
  local ply = source
  local uid = exports['cnr_charcreate']:GetUniqueId(ply)
  if cops[ply] then 
    cops[ply] = nil
    dropCop[#dropCop + 1] = uid
    Citizen.CreateThread(function()
      Citizen.Wait(600000)
      for k,v in pairs (dropCop) do 
        if v == uid then
          dropCop[uid] = nil
        end
      end
    end)
  end
end)