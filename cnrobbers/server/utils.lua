

-- This should be the Discord Webhook URL for sending game feed messages
local webhook = ""


--- DiscordFeed()
-- Sends a message to the Discord Webhook for the Server Feed
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
  PerformHttpRequest(webhook,
    function(err, text, headers) end, 'POST',
    json.encode({username = "5M:CNR Monitor", embeds = embed}),
    {['Content-Type'] = 'application/json' }
  )

end
AddEventHandler('cnr:discord', DiscordMessage)
AddEventHandler('cnr:feed', DiscordMessage)


--- ConsolePrint()
-- Nicely formatted console print with timestamp
-- @param msg The message to be displayed
function ConsolePrint(msg)
  if msg then
    local dt = os.date("%H:%M", os.time())
    print("[CNR "..dt.."] ^7"..(msg).."^7")
  end
end
AddEventHandler('cnr:print', ConsolePrint)
AddEventHandler('cnr:cprint', ConsolePrint)