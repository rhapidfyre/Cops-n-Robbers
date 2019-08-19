
--[[
  Cops and Robbers: Clans Script (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  08/19/2019
  
  Handles chat-like functions, such as /r(adio).
  Future scripts will replace the FiveM default chat.
  
  Permission granted solely for the execution of the script as intended by
  the developer.
--]]

RegisterNetEvent('')

local channels = {
  [1] = "Los Santos PD", [2] = "LS Sheriff", [3] = "Blaine Sheriff",
  [4] = "Highway Patrol", [5] = "Park Rangers",
  [6] = "USAF Police", [7] = "FBI"
}

--- ReceiveRadioMessage()
-- Called when a radio message is received. The player sending it has been 
-- verified. The function checks if receive is Law and then displays it.
-- @param name   The player name and Server ID # of sending player
-- @param agency The agency number. If zero, always received (dept-wide message)
-- @param msg    The radio message being received
function ReceiveRadioMessage(name, agency, msg)
  if exports['cnr_police']:DutyStatus() then 
    if agency > 0 then 
      TriggerClientEvent('chat:addMessage', {
        multiline = true, args = {"^7(/r) ^3"..name.. " , 
          channels[agency].." Radio", msg
        }
      })
    else
      TriggerClientEvent('chat:addMessage', {
        multiline = true, args = {"^7(/d) ^3"..name.., 
          "Agency-Wide Communication", msg
        }
      })
      end
  else print("DEBUG - Received a radio message, but you're not on duty.")
  end
end
AddEventHandler('cnr:radio_receive', ReceiveRadioMessage)


--- EXPORT: SendRadioMessage()
-- Attempts to send a radio command to faction
-- Used by law enforcement agencies to send a message.
-- @param source Ignored
-- @param args   A table of each entry between spaces
-- @param raw    The entire message typed including the /r(adio) portion
-- @param isDept (Opt) If true/given, sends message to all agencies.
function SendRadioMessage(source, args, raw, isDept)
  -- Ensure player is a police officer / LEO
  local myAgency = exports['cnr_police']:DutyAgency()
  if myAgency > 0 then
    -- Ensure an actual message was sent
    if args[1] then 
      if msg then 
        local msg = table.concat(args, " ")
        TriggerServerEvent('cnr:radio_message', msg, myAgency)
      end
    else
      TriggerClientEvent('chat:addMessage', {args = {
        "ERROR", "^1Blank message received. (^3/r(radio) <Message>^1)."
      }})
    end
  else
    TriggerClientEvent('chat:addMessage', {args = {
      "ERROR", "^1What Radio? You're not on Law Enforcement duty."
    }})
  end
end
TriggerEvent('chat:addSuggestion', '/r(adio)', 'Sends a radio message.', {
  {name="message", "The message to be sent to all on duty members."
})
RegisterCommand('r', SendRadioMessage)
RegisterCommand('radio', SendRadioMessage)

TriggerEvent('chat:addSuggestion', '/d(ept)', 'Sends radio message to all agencies.', {
  {name="message", "The message to be sent to all on duty agencies."
})
RegisterCommand('d', function(s,a,r) SendRadioMessage(s,a,r,true) end)
RegisterCommand('dept', function(s,a,r) SendRadioMessage(s,a,r,true) end)