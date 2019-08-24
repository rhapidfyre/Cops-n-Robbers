
--[[
  Cops and Robbers: Law Enforcement - Jail/Prison Scripts (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  08/22/2019
  
  This file handles all the functionality to jailing players, releasing players,
  as well as prison functionality for prisoners and police officers.
  
  Also handles tickets/citations.
--]]

RegisterNetEvent('cnr:prison_client')
RegisterNetEvent('cnr:jail_client')
RegisterNetEvent('cnr:ticket_client')

local isPrisoner = false
local isInmate   = false
local leashed    = {}

function IsPrisoner()
  Citizen.CreateThread(function()
    while isPrisoner do 
      if #(GetEntityCoords(PlayerPedId()) - leashed.center) > leashed.limit then
        isPrisoner = false
        TriggerServerEvent('cnr:wanted_points', 'prisonbreak')
        break
      end
      Wait(1000)
    end
  end)
end


function BeginSentence(minutes)
  while isPrisoner or isInmate do 
    
    Citizen.Wait(1000)
  end
end


function CalculateTime()
  local n = 0
  for k,v in pairs(exports['cnr_wanted']:CrimeList()) do
    n = n + exports['cnr_wanted']:GetCrimeTime(v)
  end
  if n > 120 then   return 120
  elseif n < 5 then return 5
  else              return n
  end
  return 5
end


function Imprison(idOfficer, wantedLevel)
  local mins = CalculateTime()
  if wantedLevel > 0 then 
    local spawn
    if     wantedLevel > 5 then spawns = prisons[math.random(#prisons)]
    elseif wantedLevel > 3 then spawns = jails[math.random(#jails)]
    end
    Citizen.CreateThread(function()
      BeginSentence(mins)
    end)
  end
end
AddEventHandler('cnr:police_imprison', Imprison)


function IssueTicket(idOfficer, price)
  
end
AddEventHandler('cnr:ticket_client', IssueTicket)