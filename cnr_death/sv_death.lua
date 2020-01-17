
--[[
  Cops and Robbers: Death Scripts (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  08/26/2019

  Handles all death events, and life saving/resurrection type scripting.
--]]

RegisterServerEvent('cnr:death_check')
AddEventHandler('cnr:death_check', function(killer)

  local victim = source
  if killer then 
    if killer ~= victim then
      local isCop = exports['cnr_police']:DutyStatus(killer)
      if not isCop then 
        print("DEBUG - cnr:death_check determined MURDER.")
        exports['cnr_wanted']:WantedPoints(killer, 'murder', true)
      else
        print("DEBUG - cnr:death_check determined JUSTIFIED.")
      end
    else
      print("DEBUG - cnr:death_check determined SUICIDE.")
    end
    TriggerClientEvent('cnr:death_notify', (-1), victim, killer)
  else
    print("DEBUG - cnr:death_check determined ACCIDENTAL.")
  end
  
end)

RegisterServerEvent('cnr:death_noted')
AddEventHandler('cnr:death_noted', function(killer)
  TriggerClientEvent('cnr:death_notify', (-1), source, killer)
end)