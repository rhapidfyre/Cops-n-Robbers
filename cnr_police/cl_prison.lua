
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
local leashed = {}

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


AddEventHandler('cnr:prison_client', function(idOfficer, pos, leash)
  local oName = GetPlayerName(GetPlayerFromServerId(idOfficer))
  TriggerEvent('chat:addMessage', {args = {
    "^3You have been imprisoned by "..oName.."."
  }})
  
end)


AddEventHandler('cnr:jail_client', function()

end)


AddEventHandler('cnr:ticket_client', function()

end)


