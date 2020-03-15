
RegisterNetEvent('cnr:radio_receive')
RegisterNetEvent('cnr:push_notify')


local rolls = 1


RegisterCommand('testchat', function (s, args, r)
  if not args[1] then TriggerEvent('chatMessage', 'boop')
  else
    TriggerEvent('chat:addMessage', {templateId = args[1],
      multiline = true, args = {
        args[2], args[3], args[4]
      }
    })

  end
end)


AddEventHandler('onClientResourceStart', function(rname)
  if rname == GetCurrentResourceName() then
    TriggerEvent('chat:addTemplate', 'sysMsg',
      '<b><font color="#FC0">[NOTICE]</font> '..
      '<font color="#996">{0}</font>'
    )
    TriggerEvent('chat:addTemplate', 'pd_radio',
      '<font color="#0AF">**<b> [</font>'..'{0}<font color="#0AF">] {1}:</b>'..
      '</font> <i>{2}</i> <font color="#0077B3"><b>*</b></font>'
    )
    TriggerEvent('chat:addTemplate', 'fd_radio',
      '<font color="#F66">**<b> [</font>'..'{0}<font color="#F66">] {1}:</b>'..
      '</font> <i>{2}</i> <font color="#FF4D4D"><b>*</b></font>'
    )
    TriggerEvent('chat:addTemplate', 'errMsg',
      '<b><font color="#F00">SYSTEM ERROR</font> ({0}) </b><br>'..
      '<font color="#FF6363">** Response:</font> '..
      '<font color="#B5B5B5">{1}</font>'
    )
    TriggerEvent('chat:addTemplate', 'disp_law',
      '<b><font color="#0BF">[POLICE DISPATCH]</font> '..
      '<font color="#66F">{0}</font>'
    )
    TriggerEvent('chat:addTemplate', 'disp_fire',
      '<b><font color="#F66">[FIRE DISPATCH]</font> '..
      '<font color="#FF4D4D">{0}</font>'
    )
    TriggerEvent('chat:addTemplate', 'cb_radio',
      '<b><font color="#CF6">[CB CH. {0}]</font> '..
      '<font color="#690">** {1}, over. *</font>'
    )
    TriggerEvent('chat:addTemplate', 'cmdMsg',
      '<b><font color="#A00">Invalid Command:</font> '..
      '<font color="#996"> {0} </font>'
    )
  end
end)

--- EXPORT: ChatNotification()
-- Also EVENT 'cnr:chat_notification'
-- Creates a popup blip with icon, title, sub, and msg
-- @param icon The icon path to show
-- @param title The title of popup
-- @param subtitle Subtitle of popup
-- @param message The long message to show
function ChatNotification(icon, title, subtitle, message)

  if not icon     then icon     = "CHAR_LESTER" end
  if not title    then title    = ""            end
  if not subtitle then subtitle = ""            end
  if not message  then message  = ""            end

	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	SetNotificationMessage(icon, icon, false, 2, title, subtitle, "")
	DrawNotification(false, true)
	PlaySoundFrontend(-1, "GOON_PAID_SMALL", "GTAO_Boss_Goons_FM_SoundSet", 0)

  return true

end
RegisterNetEvent('cnr:chat_notification')
AddEventHandler('cnr:chat_notification', ChatNotification)


--- EXPORT: PushNotification()
-- Sends a push notification to the right of the screen
-- @param pType The type of notification (1=Crime, 2=Law, 3=Normal)
-- @param title The title of the notification
-- @param message The message/body of the notification
-- @return Returns table ([1] = False if failed, [2] = if 1, reason)
function PushNotification(pType, title, message)

  if not pType then return {true, "Type not given [1]Crime [2]Law [3]Misc"}
  elseif not title then return {true, "No title given"}
  elseif not message then return {true, "No message given"}
  end

  local htmlTable = {}
  local classInfo = "info-crime"

  if     pType == 2 then classInfo = "info-law"
  elseif pType == 3 then classInfo = "info-civ"
  end

  table.insert(htmlTable,
    '<div class="'..(classInfo)..'" id="roll'..rolls..'"><h5>&#8227;&nbsp;'..
    title..'</h5><p>'..message..
    '</p><div class="'..(classInfo)..'-bar" id="rbar'..rolls..'"></div></div>'
  )

  SendNUIMessage({newRoller = table.concat(htmlTable), idRoller = rolls})
    print("DEBUG - NUI Sent")

  Citizen.CreateThread(function()
    local thisRoll = rolls
    rolls = rolls + 1
    if rolls > 127 then rolls = 1 end -- keep memory use low
    local i = 420
    print("DEBUG - Looping.")
    while i > 0 do
      local t = ((i/420)*100)
      SendNUIMessage({timeRoller = true,
        newWidth = math.floor(t),
        idRoller = thisRoll
      })
      i = i - 1
      Citizen.Wait(1)
    end
    print("DEBUG - Loop Finished")
    SendNUIMessage({timeRoller = true,
      idRoller = thisRoll,
      newWidth = 0
    })
  end)
end
AddEventHandler('cnr:push_notify', PushNotification)


--- ReceiveRadioMessage()
-- Called when a radio message is received. The player sending it has been
-- verified. The function checks if receive is Law and then displays it.
-- @param pName  The player name and Server ID # of sending player
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
    if isDept then cmd = "/dept" end
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