
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

local inmates   = {}
local prisoner  = {}    -- Used if player is in big boy jail
local serveTime = {}
local tickets   = {}


-- Where key is the wanted level
local ticketPrice = {
  [1] = function() return (math.random(1000,3000)) end
  [2] = function() return (math.random(2250,5000)) end
  [3] = function() return (math.random(4000,9000)) end
  [4] = function() return (math.random(6000,12000)) end
}


function CalculateTime(ply)
  local n = 0
  for k,v in pairs(exports['cnr_wanted']:CrimeList(ply)) do
    n = n + exports['cnr_wanted']:GetCrimeTime(v)
  end
  if n > 120 then   return 120
  elseif n < 5 then return 5
  else              return n
  end
  return 5
end


--- ReleaseFugitive()
-- Removes all traces of player inmate/prison info from tables
-- Also triggers prison_release event
function ReleaseFugitive(ply)

  local uid = exports['cnrobbers']:UniqueId(ply)
  
  for k,v in pairs (inmates) do 
    if v == ply then table.remove(inmates, k) end
  end
  
  TriggerClientEvent('cnr:prison_release', ply, prisoners[ply])
  
  if serveTime[ply] then serveTime[ply] = nil end
  if prisoner[k]    then prisoner[k]    = nil end
  
  -- SQL: Remove inmate record
  exports['ghmattimysql']:execute(
    "DELETE FROM inmates WHERE idUnique = @uid",
    {['uid'] = uid},
    function() end
  )
  
  cprint(
    GetPlayerName(k).." has served their debt to society, "..
    "and has been ^2released^7."
  )
  
end


function ImprisonClient(ply, cop)
  if ply and cop then 
  
    local wantedLevel = exports['cnr_wanted']:WantedLevel(ply)
    local uid         = exports['cnrobbers']:UniqueId(ply)
    
    -- Jail / Prison
    if wantedLevel > 3 then 
      serveTime[ply]        = CalculateTime(ply) * 60
      inmates[#inmates + 1] = ply
      if wantedLevel > 5 then
        prisoner[ply] = true
        cprint("^4"..GetPlayerName(ply)..
          " has been sent to prison for "..serveTime[ply].." minutes!"
        )
      else
        cprint("^4"..GetPlayerName(ply)..
          " has been sent to jail for "..serveTime[ply].." minutes!"
        )
      end
      InmateTimer() -- Starts the inmate timer, if not running
      TriggerClientEvent('cnr:police_imprison', ply,
        cop, serveTime[ply], prisoner[ply]
      )
    
    -- Ticket
    elseif wantedLevel > 0 then 
      tickets[ply] = ticketPrice[wantedLevel]
      TriggerClientEvent('cnr:ticket_client', ply,
        cop, tickets[ply]
      )
      TriggerClientEvent('chat:addMessage', cop, {args={
        "^2You have issued ^7"..GetPlayerName(ply).." ^2a ticket "..
        "for ^7$"..tickets[ply].."^2.\nWait to see if they pay the fine..."
      }})
      return 0 -- Return as to not run the WantedLevel() export below
      
    else 
      TriggerClientEvent('chat:addMessage', cop, { args = {
        "^1Player #"..ply.." is not wanted!"
      }})
      return 0 -- Return as to not run the WantedLevel() export below
      
    end
    
    exports['cnr_wanted']:WantedLevel(ply, 'jailed')
  end
end

AddEventHandler('playerDropped', function(reason)
  local ply      = source
  local isInmate = false 
  for k,v in pairs(inmates) do 
    if v == ply then
      isInmate = true
      table.remove(inmates, k) -- Perform list cleanup
      break
      end
  end
  if isInmate then 
    local uid = exports['cnrobbers']:UniqueId(ply)
    exports['ghmattimysql']:execute(
      "CALL offline_inmate(@uid, @jTime, @bigJail)",
      {['uid'] = uid, ['jTime'] = serveTime[ply], ['bigJail'] = prisoner[ply]},
      function()
        exports['cnrobbers']:ConsolePrint(
          GetPlayerName(ply).." logged off with "..serveTime[ply]..
          "seconds left to serve. Their time has been added to SQL."
        )
        prisoner[ply]  = {}
        serveTime[ply] = {}
      end
    )
  end
end)


-- Checks to see if player last logged off with time in jail/prison to serve
AddEventHandler('cnr:client_loaded', function()
  local ply = source
  local uid = exports['cnrobbers']:UniqueId(ply)
  if not uid then uid = 0 end
  if uid > 0 then 
    exports['ghmattimysql']:execute(
      "SELECT sentence,isPrison FROM inmates WHERE idUnique = @uid",
      {['uid'] = uid},
      function(jailInfo)
        if jailInfo[1] then 
          cprint(GetPlayerName(ply).." last logged off with time to serve.")
          if jailInfo[1]["sentence"] > 0 then 
            inmates[#inmates + 1] = ply
            serveTime[ply] = jailInfo[1]["sentence"]
            InmateTimer() -- Starts the inmate timer, if not running
            if jailInfo[1]["isPrisoner"] then
              prisoner[ply] = true
              cprint(GetPlayerName(ply).." has been sent back to prison.")
            else
              cprint(GetPlayerName(ply).." has been sent back to jail.")
            end
            TriggerClientEvent('cnr:prison_rejail', ply, 
              jailInfo[1]["sentence"], jailInfo[1]["isPrison"]
            )
          else 
            ReleaseFugitive(ply)
          end
        end
      end
    )
  end
end)


-- Handles jail / inmate timers
Citizen.CreateThread(function()
  while true do 
    for k,v in pairs (serveTime) do
      v = v - 1
      if v < 1 then ReleaseFugitive(k) end
      Citizen.Wait(1)
    end
    -- Slow this loop down if there's no inmates
    if #inmates < 1 then Citizen.Wait(9000) end
    Citizen.Wait(1000)
  end
end)



