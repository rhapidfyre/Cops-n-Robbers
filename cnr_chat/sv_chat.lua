
function DiscordMessage(color, name, message, footer, classification)

  local embed = {
    {
      ["color"] = color,
      ["title"] = "**"..name.."**",
      ["description"] = message,
      ["footer"] = {
        ["text"] = footer,
      },
    }
  }

  if name == "" then embed[1]["title"] = "" end
  if not classification then classification = 1 end

  -- Sends the message to the Discord API for dispatch
  PerformHttpRequest(urls[classification],
    function(err, text, headers) end, 'POST',
    json.encode({username = "5M:CNR Monitor", embeds = embed}),
    {['Content-Type'] = 'application/json' }
  )

end
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('cnr:radio_message')

AddEventHandler('chatMessage', function(msgClient, name, message)
  PerformHttpRequest(urls[4],
    function(err, text, headers) end, 'POST',
    json.encode({
      username = "5M:CNR Monitor",
      content  = "**"..name.."**: "..message
    }),
    { ['Content-Type'] = 'application/json' }
  )
end)

-- From base chat resource
AddEventHandler('_chat:messageEntered', function(author, color, message)
  local ply = source
  if not message or not author then return 0 end
  exports['cnrobbers']:ConsolePrint(
    '^6'..tostring(author)..' ('..tostring(ply)..'): ^7"'..tostring(message)..'"'
  )
end)

--- SendRadioMessage()
-- Sends a radio message to all players.
AddEventHandler('cnr:radio_message', function(msg, isDept)
  local ply   = source
  local isCop = exports['cnr_police']:DutyStatus(ply)
  --local isEMS  = exports['cnr_ems']:DutyStatus(ply)
  --local isFire = exports['cnr_fire']:DutyStatus(ply)
  if isCop or isEMS or isFire then
    local pName = GetPlayerName(ply)
    print("DEBUG - Radio Message ("..pName.."): "..msg)
    TriggerClientEvent('cnr:radio_receive', (-1), isDept, pName.." ("..ply..")",
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