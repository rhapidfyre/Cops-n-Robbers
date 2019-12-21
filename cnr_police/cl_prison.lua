

RegisterNetEvent('cnr:prison_client')
RegisterNetEvent('cnr:jail_client')
RegisterNetEvent('cnr:ticket_client')
RegisterNetEvent('cnr:police_imprison')
RegisterNetEvent('cnr:prison_rejail')
RegisterNetEvent('cnr:prison_release')
RegisterNetEvent('cnr:police_doors')

local isPrisoner = false
local isInmate   = false

function IsPrisoner()
  isInmate   = false
  isPrisoner = true
  Citizen.CreateThread(function()
    while isPrisoner do
      if #(GetEntityCoords(PlayerPedId()) - prison.center) > prison.limit then
        isPrisoner = false
        TriggerServerEvent('cnr:wanted_points', 'prisonbreak')
        TriggerServerEvent('cnr:prison_break')
        break
      end
      Wait(100)
    end
  end)
end


function IsInmate()
  isPrisoner = false
  isInmate   = true
  Citizen.CreateThread(function()
    while isInmate do
      if #(GetEntityCoords(PlayerPedId()) - jails[3].pos) > 100.0 then
        isInmate = false
        TriggerServerEvent('cnr:wanted_points', 'jailbreak')
        TriggerServerEvent('cnr:prison_break')
        break
      end
      Wait(100)
    end
  end)
end


function BeginSentence(secondz)
  local jailTime = (secondz * 60)
  SendNUIMessage({showjail = true})

  -- While serving time and is in jail or prison
  while jailTime > 0 and (isInmate or isPrisoner) do
    local secs = math.floor(jailTime%60)
    if secs < 10 then secs = "0"..secs end
    SendNUIMessage({
      jailTime = math.floor(jailTime/60)..":"..secs
    })
    jailTime = jailTime - 1
    Citizen.Wait(1000)
  end

  -- Time has either been served, or they broke out of jail/prison
  SendNUIMessage({hidejail = true})
  Citizen.Wait(3000)

  -- If either of these are true, we served our time but still stuck in a cell
  -- Notify server that we think we're not supposed to be in jail/prison anymore
  if isPrisoner or isInmate then
    TriggerServerEvent('cnr:prison_time_served')
  end
end


function Imprison(idOfficer, jTime, jPrison)
  local spawn = jails[math.random(#jails)]
  if jPrison then
    spawn = prisons[math.random(#prisons)]
  end
  SetEntityCoords(PlayerPedId(), spawn.pos)
  SetEntityHeading(PlayerPedId(), spawn.h)
  Citizen.CreateThread(function()
    BeginSentence(jTime)
    if jPrison then IsPrisoner()
    else IsInmate() end
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
  local onScreen = GetScreenCoordFromWorldCoord(x,y,z)
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


-- Handles jail door lock status
local cDoor = 0
Citizen.CreateThread(function()
  while true do
    for i = 1, #pdDoors do
      local door = GetClosestObjectOfType(
        pdDoors[i].vect.x, pdDoors[i].vect.y, pdDoors[i].vect.z,
        1.0, GetHashKey(pdDoors[i].name),
        false, false, false
      )
      if door > 0 then FreezeEntityPosition(door, pdDoors[i].locked) end
    end
    Citizen.Wait(0)
  end
end)


-- Find closest door (updates 'cDoor' variable)
-- We are using 'i ~= 2' because I don't want anyone touching it
function FindRestrictedDoor()
  local cDist = math.huge
  local myPos = GetEntityCoords(PlayerPedId())
  local door  = 0
  for i = 1, #pdDoors do
    local dist = #(myPos - pdDoors[i].vect)
    if cDist > dist and i ~= 2 then door = i; cDist = dist end
  end
  return door
end
Citizen.CreateThread(function()
  while true do
    if DutyStatus() then cDoor = FindRestrictedDoor() end
    Citizen.Wait(100)
  end
end)


-- Solely for operating the Bolingbroke Penitentary gates
-- Also contains the door points for going in/out of the prison
local prisonDoors = {
  enter  = vector3(1847.03, 2585.94, 45.672),
  goIn   = vector3(1814.38, 2593.95, 45.7473),
  leave  = vector3(1817.98, 2594.21, 45.7227),
  getOut = vector3(1849.54, 2585.81, 45.672)
}
Citizen.CreateThread(function()
  while true do
    if DutyStatus() then
      local ped   = PlayerPedId()
      local myPos = GetEntityCoords(ped)

      -- If closest door is a prison gate
      if cDoor == 9 or cDoor == 10 then
        if #(myPos - (pdDoors[cDoor].vect)) < 20.0 then
          if IsUsingPoliceVehicle() then
            local sv = (pdDoors[cDoor].vect) -- sv = Short Vectorname
            if pdDoors[cDoor].locked then
              DrawText3D(sv.x, sv.y + 2.0, sv.z + 6.0, "~g~SECURED ~w~(`)")
            else
              DrawText3D(sv.x, sv.y + 2.0, sv.z + 6.0, "~r~UNLOCKED ~w~(`)")
            end
            if IsControlJustPressed(0, 243) then -- ~
              TriggerServerEvent('cnr:police_door', cDoor, (not pdDoors[cDoor].locked))
            end
          end
        end
      end

      -- If near the enter/exit point(s)
      if #(myPos - prisonDoors.enter) < 400.0 then
        DrawMarker(1,
          prisonDoors.enter.x, prisonDoors.enter.y, prisonDoors.enter.z - 1.08,
          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.4, 1.4, 0.52, 0, 80, 200, 120
        )
        DrawMarker(1,
          prisonDoors.leave.x, prisonDoors.leave.y, prisonDoors.leave.z - 1.08,
          0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.4, 1.4, 0.52, 0, 80, 200, 120
        )
        if #(myPos - prisonDoors.enter) < 0.8 then
          SetEntityCoords(ped, prisonDoors.goIn)
        elseif #(myPos - prisonDoors.leave) < 0.8 then
          SetEntityCoords(ped, prisonDoors.getOut)
        end
      end
    end
    Citizen.Wait(0)
  end
end)


-- Handles locking/unlocking jail doors
Citizen.CreateThread(function()
  while true do
    local myPos = GetEntityCoords(PlayerPedId())
    if DutyStatus() then
      if cDoor > 0 then
        -- Calculate door stuff
        -- If we did cDoor = pdDoors[i], the lock status would not update
        local distCheck = #(myPos - pdDoors[cDoor].vect)
        if (distCheck < 3.0) then

          local door = GetClosestObjectOfType(
            pdDoors[cDoor].vect.x, pdDoors[cDoor].vect.y, pdDoors[cDoor].vect.z,
            1.0, GetHashKey(pdDoors[cDoor].name)
          )

          -- Check if restricted (sally port, prison gate, etc)
          if cDoor < 9 and cDoor ~= 4 then

            -- Allow E unlock/lock
            if door > 0 then
              local dPos = GetEntityCoords(door)
              if pdDoors[cDoor].locked then
                DrawText3D(dPos.x, dPos.y, dPos.z, "~g~SECURED ~w~(E)")
              else
                DrawText3D(dPos.x, dPos.y, dPos.z, "~r~UNLOCKED ~w~(E)")
              end

              -- Lock/Unlock the door
              if IsControlJustPressed(0, 38) then
                if cDoor > 5 and CopRank() < 7 and (pdDoors[cDoor].locked) then
                  TriggerEvent('cnr:push_notify',
                    2, "INSUFFICIENT RANK",
                    "Your cop rank only allows you to LOCK this door."
                  )
                else
                  TriggerServerEvent('cnr:police_door',
                    cDoor, (not pdDoors[cDoor].locked)
                  )
                end
              end

            end
          end
        end
      end

    end
    Citizen.Wait(0)
  end
end)

function ToggleDoorLockStatus(n, dLock)
  pdDoors[n].locked = dLock
  local door = GetClosestObjectOfType(
    pdDoors[n].vect.x, pdDoors[n].vect.y, pdDoors[n].vect.z,
    1.0, GetHashKey(pdDoors[n].name)
  )
  if door then FreezeEntityPosition(door, pdDoors[n].locked) end
end
AddEventHandler('cnr:police_doors', ToggleDoorLockStatus)


Citizen.CreateThread(function()

  -- Prison Blip
  local pblip = AddBlipForCoord(prison.center)
  SetBlipSprite(pblip, 285)
  SetBlipDisplay(pblip, 2)
  SetBlipScale(pblip, 1.0)
  SetBlipAsShortRange(pblip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("State Prison")
  EndTextCommandSetBlipName(pblip)

  -- Jail Blip
  local jblip = AddBlipForCoord(jails[3].pos)
  SetBlipSprite(jblip, 285)
  SetBlipDisplay(jblip, 2)
  SetBlipScale(jblip, 1.0)
  SetBlipAsShortRange(jblip, true)
  BeginTextCommandSetBlipName("STRING")
  AddTextComponentString("Jailhouse")
  EndTextCommandSetBlipName(jblip)

end)
