
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
AddEventHandler('cnr:radio_message', function(msg, isDept)
  local ply   = source
  local isCop = exports['cnr_police']:DutyStatus(ply)
  --local isEMS  = exports['cnr_ems']:DutyStatus(ply)
  --local isFire = exports['cnr_fire']:DutyStatus(ply)
  if isCop or isEMS or isFire then
    local pName = GetPlayerName(ply)
    TriggerClientEvent('cnr:radio_receive', (-1), isDept, pName.." ["..ply.."]:",
      msg, isCop, isEMS, isFire
    )
  else
    if isDept then
      TriggerClientEvent('chat:addMessage', ply, {templateId = "errMsg",
        args = {"/dept",
        "Must be on Public Safety Duty."
      }})
    else
      TriggerClientEvent('chat:addMessage', ply, {templateId = "errMsg",
        args = {"/radio",
        "Must be on Public Safety Duty."
      }})
    end
  end
end)