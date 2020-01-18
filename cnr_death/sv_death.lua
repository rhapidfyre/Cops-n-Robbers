
--[[
  Cops and Robbers: Death Scripts (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  08/26/2019

  Handles all death events, and life saving/resurrection type scripting.
--]]


-- Check if the death was a crime, and then notify the players
RegisterServerEvent('cnr:death_check')
AddEventHandler('cnr:death_check', function(killer)

  local victim = source
  local dMessage = GetPlayerName(victim).." died"
  if killer then
    if killer ~= victim then
      local isCop = exports['cnr_police']:DutyStatus(killer)
      if not isCop then
        print("DEBUG - cnr:death_check determined MURDER.")
        dMessage = GetPlayerName(killer).." killed "..GetPlayerName(victim)
        exports['cnr_wanted']:WantedPoints(killer, 'murder', true)
        local uid = exports['cnrobbers']:UniqueId(killer)
        if killer then
          exports['ghmattimysql']:execute(
            "UPDATE characters SET kills = kills + 1 WHERE idUnique = @uid",
            {['uid'] = uid}
          )
        end
      else
        dMessage = GetPlayerName(killer).." neutralized "..GetPlayerName(victim)
        print("DEBUG - cnr:death_check determined JUSTIFIED.")
      end
    else
      dMessage = GetPlayerName(victim).." killed themselves."
      print("DEBUG - cnr:death_check determined SUICIDE.")
    end
    TriggerClientEvent('cnr:death_notify', (-1), victim, killer)
  end
  exports['cnrobbers']:ConsolePrint(dMessage)
  exports['cnr_chat']:DiscordMessage(9807270, dMessage, "", "")
end)

-- Just note the death and notify the players
RegisterServerEvent('cnr:death_noted')
AddEventHandler('cnr:death_noted', function(killer)
  local dMessage = GetPlayerName(victim).." died"
  exports['cnrobbers']:ConsolePrint(dMessage)
  exports['cnr_chat']:DiscordMessage(9807270, dMessage, "", "")
  TriggerClientEvent('cnr:death_notify', (-1), source, killer)
end)

RegisterServerEvent('cnr:player_death')
AddEventHandler('cnr:player_death', function()
  local client = source
  local uid    = exports['cnrobbers']:UniqueId(client)
  exports['ghmattimysql']:execute(
    "UPDATE characters SET deaths = deaths + 1 WHERE idUnique = @uid",
    {['uid'] = uid}
  )
end)