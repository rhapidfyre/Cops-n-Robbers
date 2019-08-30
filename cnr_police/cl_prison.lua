
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
RegisterNetEvent('cnr:police_doors')

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
  SendNUIMessage({showticket = true})
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
    ticketClock = GetGameTimer() + 30000
    Citizen.CreateThread(function()
      while ticketWaiting do 
        if IsControlJustPressed(0, 288) then 
          ticketWaiting = false
          TriggerServerEvent('cnr:ticket_payment', idOfficer)
        else
          if GetGameTimer > ticketClock then
            ticketWaiting = false
          else
            SendNUIMessage({
              ticketTime = "0:"..((ticketClock - GetGameTimer())/1000)
            })
          end
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


-- Draws text on screen as positional
local function DrawText3D(x, y, z, text) 
  local onScreen,_x,_y = GetScreenCoordFromWorldCoord(x,y,z)
  local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
  
  local fov = (1/GetGameplayCamFov()) * 100
  SetDrawOrigin(x, y, z, 0);
  BeginTextCommandDisplayText("STRING")
  SetTextScale(0.28, 0.28)
  SetTextFont(0)
  SetTextProportional(1)
  SetTextColour(255, 255, 255, 255)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextEdge(2, 0, 0, 0, 150)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(0.0, 0.0)
  ClearDrawOrigin()
end


-- Handles jail doors
Citizen.CreateThread(function()
	for i = 1, #pdDoors do 
		local door = GetClosestObjectOfType(
      pdDoors[i].vect.x, pdDoors[i].vect.y, pdDoors[i].vect.z,
      1.0, GetHashKey(pdDoors[i].name),
      false, false, false
    )
		FreezeEntityPosition(door, pdDoors[i].locked)
	end
  local cDoor = 0
  while true do
    local myPos = GetEntityCoords(PlayerPedId())
    if DutyStatus() then 
    
      if cDoor < 1 then 
      
        -- Find closest door
        local cDist = math.huge
        for i = 1, #pdDoors do 
          local dist = #(myPos - pdDoors[i].vect)
          if cDist > dist then cDoor = i; cDist = dist end
          Citizen.Wait(10)
        end
        
      else
      
        -- Calculate door stuff
        -- If we did cDoor = pdDoors[i], the lock status would not update
        if #(myPos - pdDoors[cDoor].vect) < 1.2 then 
          
          local door = GetClosestObjectOfType(
            pdDoors[cDoor].vect.x, pdDoors[cDoor].vect.y, pdDoors[cDoor].vect.z,
            1.0, GetHashKey(pdDoors[cDoor].name)
          )
          
          -- Door exists
          if door > 0 then
            local dPos = GetEntityCoords(door)
            if pdDoors[cDoor].locked then
              DrawText3D(dPos.x, dPos.y, dPos.z, "~g~SECURED ~w~(E)")
            else
              DrawText3D(dPos.x, dPos.y, dPos.z, "~r~UNLOCKED ~w~(E)")
            end
          
            -- Lock/Unlock the door
            if IsControlJustPressed(0, 38) then 
              TriggerServerEvent('cnr:police_door',
                cDoor, (not pdDoors[cDoor].locked)
              )
            end
          
          end
          
          
        -- If distance is greater than that, find a new door
        else
          cDoor = 0
          Citizen.Wait(100)
        end
      end
      
    end
    Citizen.Wait(0)
  end
end)

AddEventHandler('cnr:police_doors', function(n, dLock)
  print("DEBUG - Server updated Door #"..n.." lock status. [Locked = "..tostring(dLock).."]")
  pdDoors[n].locked = dLock
  local door = GetClosestObjectOfType(
    pdDoors[n].vect.x, pdDoors[n].vect.y, pdDoors[n].vect.z,
    1.0, GetHashKey(pdDoors[n].name)
  )
  if door then
    SetDoorAjarAngle(door, 0.0, 0, 1)
		FreezeEntityPosition(door, pdDoors[n].locked)
  end
end)

