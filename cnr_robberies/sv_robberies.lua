
--[[
  Cops and Robbers: Convenience Robberies (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  07/19/2019
  
  This file contains the functionality to rob stores. This is not for heists,
  bank robberies, or other major events, but rather for holding up gas stations,
  bars, nightclubs, and similar.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

RegisterServerEvent('cnr:robbery_send_lock')  -- Lock/Unlock Robbery Event
RegisterServerEvent('cnr:robbery_take')       -- The cash won from the robbery
RegisterServerEvent('cnr:client_loaded')      -- Called when the char enters


--- EVENT cnr:robbery_take
-- Called when a player finishes a robbery
-- @param cashTake The amount the player successfully robbed
AddEventHandler('cnr:robbery_take', function(cashTake)

end)


AddEventHandler('cnr:robbery_send_lock', function(storeNumber, lockStatus)
  rob[storeNumber] = lockStatus
  TriggerClientEvent('cnr:robbery_lock_status', (-1), storeNumber, lockStatus)
end)


AddEventHandler('cnr:client_loaded', function()
  local ply = source
  local lockouts = {}
  for k,v in pairs (rob) do 
    lockouts[k] = v.lockout
  end
  TriggerClientEvent('cnr:robbery_locks', ply, lockouts)
end)