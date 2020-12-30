
RegisterNetEvent('cnr:police_blip_backup')
RegisterNetEvent('cnr:police_duty')

local oldModel          = nil -- Temporary, until we switch to the New Model System
local transition        = false
local nSt               = 0   -- Nearest Police Station (0 if none nearby)
local stationDistance   = 42.0    -- Maximum distance for Near Station detection

local panics = {}


function DutyStatus()
  return CNR.isPolice
end


--- PoliceCamera()
-- Operates the camera when toggling duty
function PoliceCamera(c)
  if not DoesCamExist(cam) then
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
  end
  SetCamActive(cam, true)
  RenderScriptCams(true, true, 500, true, true)
  local cInfo = c.cams
  SetCamParams(cam, c.pos, 0.0, 0.0, c.rot, 60.0)
  Citizen.CreateThread(function()
    while transition do
      HideHudAndRadarThisFrame()
      Citizen.Wait(0)
    end
  end)
  Citizen.Wait(3000)
  DoScreenFadeOut(400)
  Citizen.Wait(600)
  SetCamParams(cam, c.x, 0.0, 0.0, c.xrot, 60.0)
  Citizen.Wait(1000)
  DoScreenFadeIn(1000)
  Citizen.Wait(3200)
  SetCamActive(cam, false)
  RenderScriptCams(false, true, 500, true, true)
  cam = nil
end


AddEventHandler('cnr:police_blip_backup', function(posn)
  if DutyStatus() then 
    local n = #panics + 1
    panics[n] = {
      blip = AddBlipForCoord(pos),
      t = GetGameTimer() + 30000
    }
    SetBlipFlashes(panics[n].blip, true)
    SetBlipDisplay(panics[n].blip, 2)
    SetBlipAsFriendly(panics[n].blip, true)
    SetBlipFlashInterval(panics[n].blip, 600)
    SetBlipColour(panics[n].blip, 2)
  end
end


RegisterCommand('forceduty', function()
  if Config.DebuggingMode() then
    print("Toggling Police Duty (/forceduty)")
      TriggerServerEvent('cnr:police_status', (not DutyStatus()), st.agency, true)
  else
    if AdminLevel() > 2 then
      print("Debugging Mode off, but user is Admin (/forceduty)")
      TriggerServerEvent('cnr:police_status', (not DutyStatus()), st.agency, true)
    else
      print("Not in Debugging Mode and User Not Admin (/forceduty)")
    end
  end
end)


-- If player died, set off duty
AddEventHandler('cnr:player_died', function()
  CNR.isPolice = false
end)


--- EXPORT: DispatchMessage()
function DispatchMessage(title, msg, customMessage)
  if not customMessage then
    PushNotification(2, "Crime Reported",
      '<font color="red">'..title..' reported in '..msg..'</font>'
    )
  else
    PushNotification(2, "Crime Reported",
      '<font color="red">'..customMessage..' '..msg..'</font>'
    )
  end
end


function DispatchNotification(title, msg)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	SetNotificationMessage("CHAR_CALL911", "CHAR_CALL911", 0, 1, "Regional 9-1-1", "~y~"..title)
	DrawNotification(false, true)
	PlaySoundFrontend(-1, "GOON_PAID_SMALL", "GTAO_Boss_Goons_FM_SoundSet", 0)
  return true
end


-- Draws a blip at the crime report location, then fades over the course of time
function DispatchBlip(x,y,z)--,title)

  --if not title then title = "9-1-1 Call Center" end
  local callBlip = AddBlipForRadius(x,y,0.0,120.0)
  --SetBlipSprite(callBlip, 526)
  SetBlipSprite(callBlip, 9)
  SetBlipColour(callBlip, 1)
  SetBlipAlpha(callBlip, 200)
  Citizen.Wait(12000)
  for i = 180, 40, -1 do
    SetBlipAlpha(callBlip, i)
    if i < 80 then Citizen.Wait(2000)
    else Citizen.Wait(1000)
    end
  end
  Citizen.Wait(10000)
  if DoesBlipExist(callBlip) then
    print("DEBUG - Removed 911 radius")
    RemoveBlip(callBlip)
  end
end


-- Sends a message to on duty cop as dispatchSendDispatch
function SendDispatch(title, place, pos, y, z, message, crime)
  if DutyStatus() then
    if pos then
      if type(pos) ~= "vector3" then
        pos = vector3(pos, y, z)
      else
        message = y
        crime = z
      end
      if not place then place = "Cell Phone 911" end
      if not area then area   = "Unknown Area" end
      if not title then
        title = GetCrimeName(title)
      end
      DispatchMessage(title, place, message)
      DispatchNotification(title, place)
      DispatchBlip(pos.x, pos.y, pos.z, title)
    else print("DEBUG - pos was nil, unable to dispatch.")
    end
  end
end
AddEventHandler('cnr:dispatch', SendDispatch)


function RequestBackup()
  TriggerServerEvent('cnr:police_backup', true,
    "Backup Request", "^1Immediate Need", GetFullZoneName()
  )
end
RegisterCommand('backup', RequestBackup)


--- PoliceLoadout()
-- Toggles the usage of police equipment
-- DEBUG - Change later to compensate for player-owned weapons
function PoliceLoadout(toggle)
  local ped = PlayerPedId()
  RemoveAllPedWeapons(ped)
  if toggle then -- Give police weapons
    GiveWeaponToPed(ped, GetHashKey("WEAPON_STUNGUN"), 1, true, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_NIGHTSTICK"), 1, true, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL"), 200, true, false)
    GiveWeaponToPed(ped, GetHashKey("WEAPON_CARBINERIFLE"), 200, true, false)
  end
end


--- BeginCopDuty()
-- Sets a civilian to be a police officer
-- Checks if player is wanted before going on duty
AddEventHandler('cnr:police_duty', function(idPlayer, pName, onDuty, st, ignoreCam)
  if idPlayer == GetPlayerServerId(PlayerId()) then
    if source ~= "" then
      transition = true
      local c = GetPoliceStation(st)
      if not ignoreCam then PoliceCamera(c.camera) end
      if onDuty then
        local wanted  = IsWanted()
        local ply     = GetPlayerServerId(PlayerId())
        if not wanted then
  
          Citizen.Wait(1000)
          oldModel = GetEntityModel(PlayerPedId())
          local newModel = GetHashKey('s_m_y_cop_01')
          RequestModel(newModel)
          while not HasModelLoaded(newModel) do Wait(1) end
          SetPlayerModel(PlayerId(), newModel)
          SetModelAsNoLongerNeeded(newModel)
  
          if c.walkTo and not ignoreCam then
            TaskGoToCoordAnyMeans(PlayerPedId(), c.walkTo, 1.0, 0, 0, 786603, 0)
            Citizen.Wait(3200)
          end
  
          PoliceLoadout(true)
          CNR.isPolice = st
          ChatNotification(
            "CHAR_CALL911", "Police Duty", "~g~Start of Watch",
            "You are now on Law Enforcement duty."
          )
          PoliceDutyLoops()
  
        else
          TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
            args = {"^1You cannot go on police duty while wanted!"}
          })
          Citizen.Wait(8000)
        end
  
      -- Going OFF Duty
      else
  
        -- DEBUG - Using Ped Model System
        RequestModel(oldModel)
        while not HasModelLoaded(oldModel) do Wait(1) end
        SetPlayerModel(PlayerId(), oldModel)
        SetModelAsNoLongerNeeded(oldModel)
  
        if c.walkTo and not ignoreCam then
          TaskGoToCoordAnyMeans(PlayerPedId(), c.walkTo, 1.0, 0, 0, 786603, 0)
          Citizen.Wait(3200)
        end
  
        ChatNotification(
          "CHAR_CALL911", "Police Duty", "~r~End of Watch",
          "You are no longer on Law Enforcement duty."
        )
        PoliceLoadout(false)
        CNR.isPolice = nil
  
      end
      transition = false
    else print("Event 'cnr:police_duty' received illegitimately!")
    end
    
  -- Player going on/off duty was NOT this player
  else
    if onDuty then
      PushNotification(2, "IN SERVICE", "Officer "..pName.." is now on duty")
    else
      PushNotification(2, "OUT OF SERVICE", "Officer "..pName.." is no longer on duty")
    end
  end
end


--- ImprisonClient()
-- Sends the given ID (or closest player) to prison if they are Wanted
function ImprisonClient(client)
  if CNR.isPolice then

    if IsPedDeadOrDying(PlayerPedId()) then
      TriggerEvent('chat:addMessage', {templateId = 'errMsg', args = {
        "You Are Dead", "How are you going to penalize someone if you're dead?"
      }})
      return 0
    end

    print("DEBUG - Trying to jail client.")
    if not client then
      client = GetClosestPlayer()
      print("DEBUG - No Client ID given - Imprisoning nearest client.")
    end

    local theyPed = GetPlayerPed(client)
    if IsPedDeadOrDying(theyPed) or IsPlayerDead(client) then
      TriggerEvent('chat:addMessage', {templateId = 'errMsg', args = {
        "Player is Dead", "You can't penalize dead people!"
      }})
      return 0
    end

    local dist = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(client)))
    if dist < 4.25 then
      print("DEBUG - Trying to imprison "..GetPlayerName(client))
      TriggerServerEvent('cnr:prison_sendto', GetPlayerServerId(client))
    else
      TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
        "Invalid Request", "Too far away, get closer!"
      }})
    end

  else
    TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
      "Invalid Request", "You are not a law enforcement officer!"
    }})
  end
end
RegisterCommand('jail', ImprisonClient)
RegisterCommand('prison', ImprisonClient)
RegisterCommand('ticket', ImprisonClient)
RegisterCommand('capture', ImprisonClient)


-- Create blips & track nearest police station
Citizen.CreateThread(function()

  local stationList = GetPoliceStations()
  for i = 1, #stationList do
    local temp = AddBlipForCoord(stationList[i].pos)
    SetBlipSprite(temp, 60)
    SetBlipColour(temp, 32)
    SetBlipAsShortRange(temp, true)
    SetBlipDisplay(temp, 2)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Police Station")
    EndTextCommandSetBlipName(temp)
  end

  -- Tracks nearest police station
  while true do
    local st      = 0
    local cDist   = stationDistance
    for i = 1, #stationList do
      local dist = #(myPos - stationList[i].pos)
      if dist < cDist then
        st = i; cDist = dist
      end
    end
    if st > 0 then nSt = st end
    Citizen.Wait(3000)
  end

end)


Citizen.CreateThread(function()
  while true do
    if nSt > 0 then
      local st = GetPoliceStation(nSt)
      if #(GetEntityCoords(PlayerPedId()) - st.pos) < 2.65 then
        if IsControlJustReleased(0, 38) and GetLastInputMethod(2) then
          TriggerServerEvent('cnr:police_status', (not CNR.isPolice), st.agency)
          Citizen.Wait(1200)
        else
          ClearPrints()
          SetTextEntry_2("STRING")
          if not IsWanted() then
            if CNR.isPolice then  AddTextComponentString("[~g~E~w~]: ~r~End Police Duty")
            else                  AddTextComponentString("[~g~E~w~]: ~b~Start Police Duty")
            end
          else AddTextComponentString("[~r~BLOCKED~w~]: Player is Wanted")
          end
          DrawSubtitleTimed(100, 1)
        end
      end
    end
    Citizen.Wait(1)
  end
end)










-- DEBUG - ctr is used to determine if B was pressed twice to upgrade alarm to emergent
-- I need to find a better way to implement this later.
local lastRequest = 0
--local lastArrest  = 0
function PoliceDutyLoops()

  Citizen.CreateThread(function()
    while CNR.isPolice do

      local myPos = GetEntityCoords(PlayerPedId())
      local st    = nil
      if nSt > 0 then st = GetPoliceStation(nSt) end
      
      -- Remove old panic blips
      for i = #panics, 1, (-1) do 
        if panics[i].t < GetGameTimer() then
          if DoesBlipExist(panics[i].blip) then 
            RemoveBlip(panics[i].blip)
            table.remove(panics, i)
          end
        end
      end

      -- Draw markers if applicable
      if st then
        for i = 1, #st.vehicles do
          local posn = st.vehicles[i].pos
          DrawMarker(1, posn.x, posn.y, posn.z - 1.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.8, 0.8, 0.62, 0, 180, 255, 120, false, false, 0, false
          )
          DrawMarker(36, posn.x, posn.y, posn.z + 1.3, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            1.2, 1.2, 1.2, 255, 255, 255, 255, false, false, 0, true
          )
        end
      end
      
      Citizen.Wait(0)
      
    end
  end)
end

RegisterKeyMapping('backup', 'Request Backup', 'keyboard', 'b')
RegisterKeyMapping('capture', 'Capture Robber', 'keyboard', 'f2')