
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
  local jailTime = GetGameTimer() + (minutes * 60000)
  while jailTime > GetGameTimer() do 
    if math.floor(jailTime/1000) % 30 == 0 then
      print("DEBUG - 30 seconds have been served.")
      TriggerServerEvent('cnr:prison_served_time')
    end
    Citizen.Wait(1000)
  end
end


function Imprison(idOfficer, jTime, jPrison)
  local spawn = jails[math.random(#jails)]
  if jPrison then spawns = prisons[math.random(#prisons)] end
  Citizen.CreateThread(function()
    BeginSentence(jTime)
  end)
end
AddEventHandler('cnr:police_imprison', Imprison)


--- Reimprison()
-- Called when a player logs in with a sentence still to serve
-- Similar to Imprison() but doesn't have any calculations or notifications
function Reimprison(jt, jp)
  local spawn = jails[math.random(#jails)]
  if jp == 2 then spawn = prisons[math.random(#prisons)] end
  Citizen.CreateThread(function()
    BeginSentence(math.floor(jt/60))
  end)
end
AddEventHandler('cnr:prison_rejail', Reimprison)


function IssueTicket(idOfficer, price)
  
end
AddEventHandler('cnr:ticket_client', IssueTicket)


--- EXPORT: ReleaseClient()
-- Releases person from jail/prison
function ReleaseClient(isPrison)
  local rPos = releaseSpawn[1]
  if isPrison then rPos = releaseSpawn[2] end
  SetEntityCoords(PlayerPedId(), rPos)
end
AddEventHandler('cnr:prison_release', ReleaseClient)

