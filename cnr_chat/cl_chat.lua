
--[[
  Cops and Robbers: Clans Script (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  08/19/2019
  
  Handles chat-like functions, such as /r(adio).
  Future scripts will replace the FiveM default chat.
  
  Permission granted solely for the execution of the script as intended by
  the developer.
--]]

RegisterNetEvent('cnr:radio_receive')

TriggerEvent('chat:addTemplate', 'radioMsg', 
  '<font color="#0AF">**<b> [</font>'..'{0}<font color="#0AF">] {1}</b>'..
  '</font><br><font color="#0AF"><b>**</b></font> {2} <font color="#0AF"><b>*</b></font>'
)

TriggerEvent('chat:addTemplate', 'errMsg', 
  '<b><font color="#F00">** ERROR:</font> {0} </b><br>'..
  '<font color="#FF6363">** Reason:</font><font color="#B5B5B5"> {1} </font>'
)

--- ReceiveRadioMessage()
-- Called when a radio message is received. The player sending it has been 
-- verified. The function checks if receive is Law and then displays it.
-- @param name   The player name and Server ID # of sending player
-- @param isDept If true, sends to everyone on Public Safety (dept msg)
-- @param msg    The radio message being received
function ReceiveRadioMessage(isDept, pName, msg, cop, ems, fire)

  local isCop = exports['cnr_police']:DutyStatus()
  --local isEMS = exports['cnr_ems']:DutyStatus()
  --local isFire = exports['cnr_fire']:DutyStatus()
  
  if isCop or isEMS or isFire then 
               local nameColor = "^4"
    if     fire then nameColor = "^1"
    elseif ems  then nameColor = "^6"
    end
    if not isDept then
      -- Receive by same type agency
      if (isCop and cop) or (isEMS and ems) or (isFire and fire) then
        TriggerEvent('chat:addMessage', {templateId = "radioMsg", 
          multiline = true, args = {nameColor.."LAW", pName, msg}
        })
      end
    else
      TriggerEvent('chat:addMessage', {templateId = "radioMsg", 
        multiline = true, args = {"^8ALL", nameColor..pName, msg}
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
  local onDuty = exports['cnr_police']:DutyStatus()
  
  if onDuty then
    -- Ensure an actual message was sent
    if args[1] then 
      local msg = table.concat(args, " ")
      if msg then 
        TriggerServerEvent('cnr:radio_message', msg, isDept)
      end
    else
      if isDept then
        TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
          "/dept", "No message given. Try ^3/dept <message>"
        }})
      else
        TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
          "/radio", "No message given. Try ^3/radio <message>"
        }})
      end
    end
  else
    local cmd = "/radio"
    if isDept then cmd = "/dept"
    else
    end
    TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
      cmd, "You are not on public safety duty."
    }})
  end
end
TriggerEvent('chat:addSuggestion', '/r(adio)', 'Sends a radio message.', {
  {name="message", "The message to be sent to all on duty members."}
})
RegisterCommand('r', SendRadioMessage)
RegisterCommand('radio', SendRadioMessage)

TriggerEvent('chat:addSuggestion', '/d(ept)', 'Sends radio message to all agencies.', {
  {name="message", "The message to be sent to all on duty agencies."}
})
RegisterCommand('d', function(s,a,r) SendRadioMessage(s,a,r,true) end)
RegisterCommand('dept', function(s,a,r) SendRadioMessage(s,a,r,true) end)