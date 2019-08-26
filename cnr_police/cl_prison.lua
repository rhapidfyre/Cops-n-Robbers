
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
RegisterNetEvent('cnr:police_imprison')
RegisterNetEvent('cnr:prison_rejail')
RegisterNetEvent('cnr:prison_release')

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


function BeginSentence(secondz)
  local jailTime = (secondz * 60)
  SendNUIMessage({showjail = true})
  while jailTime > 0 do
    local secs = math.floor(jailTime%60)
    if secs < 10 then secs = "0"..secs end
    SendNUIMessage({
      jailTime = math.floor(jailTime/60)..":"..secs
    })
    jailTime = jailTime - 1
    Citizen.Wait(1000)
  end
  if jailTime < 0 then jailTime = 0 end
  Citizen.Wait(3000)
  if isPrisoner or isInmate then TriggerServerEvent('cnr:prison_time_served')
  end
end


function Imprison(idOfficer, jTime, jPrison)
  local spawn = jails[math.random(#jails)]
  if jPrison then spawn = prisons[math.random(#prisons)] end
  SetEntityCoords(PlayerPedId(), spawn.pos)
  SetEntityHeading(PlayerPedId(), spawn.h)
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
  SetEntityCoords(PlayerPedId(), spawn.pos)
  SetEntityHeading(PlayerPedId(), spawn.h)
  Citizen.CreateThread(function()
    BeginSentence(jt)
  end)
end
AddEventHandler('cnr:prison_rejail', Reimprison)


local ticketWaiting = false 
function IssueTicket(idOfficer, price)
  TriggerEvent('chat:addMessage', { args = {
    "TICKET",
    "You have been issued a ticket for ^2$"..price..
    "^7 by ^4"..GetPlayerName(GetPlayerFromServerId(idOfficer)).."^7."
  }})
  TriggerEvent('chat:addMessage', { args = {
    "TICKET",
    "You have^3 30 seconds ^7to decide your response ( F1 to Pay )."
  }})
  if not ticketWaiting then 
    ticketWaiting = true
    Citizen.CreateThread(function()
      while ticketWaiting do 
        if IsControlJustPressed(0, 288) then 
          ticketWaiting = false
          TriggerServerEvent('cnr:ticket_payment', idOfficer)
        end
        Citizen.Wait(1)
      end
      ticketWaiting = false
    end)
  end
end
AddEventHandler('cnr:ticket_client', IssueTicket)


--- EXPORT: ReleaseClient()
-- Releases person from jail/prison
function ReleaseClient(isPrison)
  SendNUIMessage({hidejail = true})
  local rPos = releaseSpawn[1]
  if isPrison then rPos = releaseSpawn[2] end
  SetEntityCoords(PlayerPedId(), rPos)
  jailTime   = 0
  isPrisoner = false
  isInmate   = false 
end
AddEventHandler('cnr:prison_release', ReleaseClient)

