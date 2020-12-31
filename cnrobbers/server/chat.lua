
urls = {
  -- Game Status Feed
  [1] = "https://discordapp.com/api/webhooks/793859671257513986/ypzgANsqReWQY9t3r1Rwdv5lLH1tKDR55d9bQRq07NMWhYEj11LtbUG8MwF3XVZn5Nh8",
  -- Basically emergencies and 911 calls
  [2] = "https://discordapp.com/api/webhooks/793859872323797012/1r5H-reeYfYCtVpd3d1YFUe6pxe6S4Vm9j6Es4aiAFBq0aUNaY1FPaES5rBFsiLpz4zv",
  -- Police Duty Status
  [3] = "https://discordapp.com/api/webhooks/793859872323797012/1r5H-reeYfYCtVpd3d1YFUe6pxe6S4Vm9j6Es4aiAFBq0aUNaY1FPaES5rBFsiLpz4zv",
  -- Server Chat
  [4] = "https://discordapp.com/api/webhooks/793859671257513986/ypzgANsqReWQY9t3r1Rwdv5lLH1tKDR55d9bQRq07NMWhYEj11LtbUG8MwF3XVZn5Nh8",
  -- Admin Stuff
  [5] = "https://discordapp.com/api/webhooks/793860025554436136/tCAFPHMzhuhSYUlVqpg-qA3ufa-xgM6iX0lNlQ2WW12xwoSEPuYFM5BotjcjWpELDaSR",
  -- Wanted Messages
  [6] = "https://discordapp.com/api/webhooks/793860124880011296/FfwnrPSd7Ap7bNTYsQ1npqUnQxhwibNGvzV8tR7T4bqVhxi_fxxTkbBmRrWB48RSPVrV",
}


--- DiscordFeed()
-- Sends a message to the Discord Webhook for the Server Feed
function DiscordFeed(color, name, message, footer, classification)

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
  PerformHttpRequest(urls[1],
    function(err, text, headers) end, 'POST',
    json.encode({username = "5M:CNR Monitor", embeds = embed}),
    {['Content-Type'] = 'application/json' }
  )

end
AddEventHandler('cnr:discord', DiscordFeed)
AddEventHandler('cnr:feed', DiscordFeed)


-- Sends all chat messages to the Server Terminal & Discord Feed
AddEventHandler('chatMessage', function(ply, name, message)
  CancelEvent()
  if message then
  
    if string.len(message) > 212 and exports['southland']:AdminLevel(ply) < 1 then
      message = string.sub(message, 0, 212) .. "..."
      TriggerClientEvent('chat:addMessage', ply, {templateId = 'sysMsg', args = {
        "^1Your message was too long and has been trimmed."
      }})
    end
  
    PerformHttpRequest(urls[4],
      function(err, text, headers) end, 'POST',
      json.encode({
        username = "Game Monitor",
        content  = "**"..name.."**: "..message
      }),
      { ['Content-Type'] = 'application/json' }
    )
    ConsolePrint(
      '(CHAT) ^6'..tostring(name)..' ('..tostring(src)..'): ^7"'..tostring(message)..'"'
    )
  end
end)


--- SendRadioMessage()
-- Sends a radio message to all players.
AddEventHandler('cnr:radio_message', function(msg, isDept)
  local ply   = source
  local isCop = DutyStatus(ply)
  if isCop then
    local pName = GetPlayerName(ply)
    TriggerClientEvent('cnr:radio_receive', (-1),
      isDept, pName.." ("..ply..")", msg, isCop
    )
  else
    if isDept then
      TriggerClientEvent('chat:addMessage', ply, {templateId = "errMsg",
        args = {"/dept", "Must be on Public Safety Duty."
      }})
    else
      TriggerClientEvent('chat:addMessage', ply, {templateId = "errMsg",
        args = {"/radio", "Must be on Public Safety Duty."
      }})
    end
  end
end)

