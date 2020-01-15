
--[[
  Cops and Robbers: Death Scripts (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  08/26/2019

  Handles all death events, and life saving/resurrection type scripting.
--]]

RegisterServerEvent(GetCurrentResourceName() .. ':SendDeathMessage')
AddEventHandler(GetCurrentResourceName() .. ':SendDeathMessage', function(Victim, Killer, DeathReasonVictim, DeathReasonOthers, DeathReasonKiller) --Sends the Death Message to every client
	TriggerClientEvent(GetCurrentResourceName() .. ':PrintDeathMessage', -1, Victim, Killer, DeathReasonVictim, DeathReasonOthers, DeathReasonKiller)
end)