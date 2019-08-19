
--[[
  Cops and Robbers: Chat Script (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  08/19/2019
  
  Handles chat-like functions, such as /r(adio).
  Future scripts will replace the FiveM default chat.
  
  Permission granted solely for the execution of the script as intended by
  the developer.
--]]

RegisterServerEvent('cnr:radio_message')

--- SendRadioMessage()
-- Sends a radio message to all players.
AddEventHandler('cnr:radio_message', function(msg, agency)
  local ply   = source
  local pName = GetPlayerName(ply)
  TriggerClientEvent('cnr:radio_receive', (-1), pName.." ["..ply.."]",
    agency, msg
  )
end)