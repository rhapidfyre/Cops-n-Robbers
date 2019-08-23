
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

local prison = {
  center = vector3(1703.42, 2575.01,45.5647),
  limit  = 240.0,
}

local jTimes = {
  [1] =  0, [2] =  0, [3] =  0, [4]  =  5, [5]  =  15, [6] = 30,
  [7] = 60, [8] = 70, [9] = 82, [10] = 95, [11] = 120
}

local jails = {
  [1] = {pos = vector3(460.932,-995.249,24.9149), h =   0.0},
  [2] = {pos = vector3(459.699,-993.791,24.9149), h = 270.0},
  [3] = {pos = vector3(461.135,-999.337,24.9149), h =   0.0},
  [4] = {pos = vector3(457.936,-997.366,24.9149), h = 276.0},
  [5] = {pos = vector3(457.769,-1001.57,24.9149), h = 272.0},
  [6] = {pos = vector3(461.152,-1002.78,24.9149), h = 352.0}
}

local prisons = {
  [1] = {pos = vector3(1673.48,2519.38,45.5649), h = 210.0},
  [2] = {pos = vector3(1703.32,2476.27,45.8249), h =  50.0},
  [3] = {pos = vector3(1721.58,2500.63,45.6413), h = 100.0},
  [4] = {pos = vector3(1636.22,2565.08,45.5649), h = 165.0},
  [5] = {pos = vector3(1729.40,2562.80,45.5649), h = 170.0}
}

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
        jails[math.random(#jails)],
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





