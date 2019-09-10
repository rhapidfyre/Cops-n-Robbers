
--[[
  Cops and Robbers: Chat Script (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  08/19/2019
  
  Handles chat-like functions, such as /r(adio).
  Future scripts will replace the FiveM default chat.
  
  Permission granted solely for the execution of the script as intended by
  the developer.
--]]

local urls = {
  feed = "https://discordapp.com/api/webhooks/614207378791071744/ZG1quo6TI-WiJwDEKwXDvyMA0mZAgEtlAb9_ruM8l5tqS_IJO6ZAgBi8wSv8SokHTkL0",
  emg  = "https://discordapp.com/api/webhooks/614209606511493147/RanDk3hsVsi39FrUuldoCxZtF4qAvy6BTPGB3dbJfMZXTTwoelWahTIJzbFIetKUlorN"
}

function DiscordMessage(color, name, message, footer, copMessage)
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
  if name == "" then embed["title"] = "" end
  local discordApp = urls.feed
  if copMessage then discordApp = urls.emg end
  print("[DISCORD]: {1:"..
    tostring(color).."} {2:"..
    tostring(name).."} {3:"..
    tostring(message).."} {4:"..
    tostring(footer).."} {5:"..
    tostring(discordApp)
  )
  PerformHttpRequest(discordApp,
    function(err, text, headers) end,
    'POST',
    json.encode({username = "Game Monitor", embeds = embed}),
    {['Content-Type'] = 'application/json' }
  )
end
RegisterServerEvent('_chat:messageEntered')
RegisterServerEvent('cnr:radio_message')

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