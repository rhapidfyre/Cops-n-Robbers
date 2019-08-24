
--[[
  Cops and Robbers: Law Enforcement - Jail/Prison Scripts (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  08/22/2019
  
  This file handles all the functionality to jailing players, releasing players,
  as well as prison functionality for prisoners and police officers.
  
  Also handles tickets/citations.
--]]

RegisterServerEvent('cnr:police_imprison')
RegisterServerEvent('cnr:police_jail')
RegisterServerEvent('cnr:police_release')
RegisterServerEvent('cnr:police_ticket')
RegisterServerEvent('cnr:prison_break')     -- Starts the prison break event

local inmate   = {}
local prisoner = {}


-- Where key is the wanted level
local ticketPrice = {
  [1] = function() return (math.random(1000,3000)) end
  [2] = function() return (math.random(2250,5000)) end
  [3] = function() return (math.random(4000,9000)) end
  [4] = function() return (math.random(6000,12000)) end
}


function ImprisonClient(ply, cop)
  if ply and cop then 
    local wantedLevel = exports['cnr_wanted']:WantedLevel(ply)
    -- Wanted Level 6 + goes to Prison
    if wantedLevel > 5 then 
      -- Send client to prison vector
      TriggerClientEvent('cnr:prison_client', ply, cop,
        prisons[math.random(#prisons)], prison, jTimes[wantedLevel]   
      )
    
    -- Wanted Level 4 and 5 goes to Jail
    elseif wantedLevel > 3 then 
      TriggerClientEvent('cnr:jail_client', ply, cop,
        jails[math.random(#jails)], jTimes[wantedLevel]
      )
      
    elseif wantedLevel > 0 then 
      local tCost = ticketPrice[wantedLevel]
      TriggerClientEvent('cnr:ticket_client', ply, cop, tCost)
      TriggerClientEvent('chat:addMessage', cop, {args={
        "^2You have issued ^7"..GetPlayerName(ply).." ^2a ticket "..
        "for ^7$"..tCost.."^2.\nWait to see if they pay the fine..."
      }})
    
    else 
      TriggerClientEvent('chat:addMessage', cop, { args = {
        "^1Player #"..ply.." is not wanted!"
      }})
      return 0 -- Return as to not run the WantedLevel() export below
    end
    exports['cnr_wanted']:WantedLevel(ply, 'jailed')
  end
end





