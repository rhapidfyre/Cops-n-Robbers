
RegisterNetEvent('cnr:dispatch') -- Receives a dispatch broadcast from Server
RegisterNetEvent('cnr:police_blip_backup') -- Changes blip settings on backup request
RegisterNetEvent('cnr:police_reduty')
RegisterNetEvent('cnr:police_officer_duty')
RegisterNetEvent('cnr:police_station_info')


local isCop       = false   -- True if player is on cop duty
local ignoreDuty  = false   -- Disables cop duty point
local cam         = nil
local transition  = false
local myAgency    = 0
local myCopRank   = 1
local activeCops  = {}
local parking     = {}      -- Holds the parking spots that are occupied/station
local stationInfo = {}      -- Current duty station information
local vehSelected = 0

local forcedutyEnabled = true -- DEBUG - /forceduty


--- EXPORT: CopRank()
-- Allows other scripts to get the client's cop rank
function CopRank()
  return myCopRank
end


--- EXPORT: DispatchMessage()
function DispatchMessage(title, msg, customMessage)
  if not customMessage then
    exports['cnr_chat']:PushNotification(2, "Crime Reported",
      '<font color="red">'..title..' reported in '..msg..'</font>'
    )--[[
    TriggerEvent('chat:addMessage', {
      color = {0,180,255}, multiline = true, args = {
        "DISPATCH", "^3"..title.." reported in "..msg.."^7"
      }
    })]]
  else
    exports['cnr_chat']:PushNotification(2, "Crime Reported",
      '<font color="red">Criminal Disturbance reported in '..msg..'</font>'
    )--[[
    TriggerEvent('chat:addMessage', {
      color = {0,180,255}, multiline = true, args = {
        "DISPATCH", "^3New Incident Reported in "..customMessage.."^7"
      }
    })]]
  end
end

function DispatchAnnounce(crime) --[[
  print("DEBUG - Announcing '"..crime.."'")
  -- DEBUG - use Lua to check if file exists
  SendNUIMessage({
    playsound = "sfx/codes/"..crime..".ogg"
  })]]
end

function DispatchNotification(title, msg)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(msg)
	SetNotificationMessage("CHAR_CALL911", "CHAR_CALL911", 0, 1, "Regional 9-1-1", "~y~"..title)
	DrawNotification(false, true)
	PlaySoundFrontend(-1, "GOON_PAID_SMALL", "GTAO_Boss_Goons_FM_SoundSet", 0)
  return true
end

function DispatchBlip(x,y,z,title)

  if not title then title = "9-1-1 Call Center" end
  local callBlip = AddBlipForRadius(x,y,0.0,120.0)
  --SetBlipSprite(callBlip, 526)
  SetBlipSprite(callBlip, 9)
  SetBlipColour(callBlip, 1)
  SetBlipAlpha(callBlip, 200)
  
  Citizen.Wait(12000)
  for i = 180, 40, -1 do
    SetBlipAlpha(callBlip, i)
    if i < 80 then
      Citizen.Wait(2000)
    else
      Citizen.Wait(1000)
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
  --if isCop then
    if pos then
      if type(pos) ~= "vector3" then
        pos = vector3(pos, y, z)
      end
      if not place then place = "Cell Phone 911" end
      if not area then area   = "Unknown Area" end
      if title then DispatchAnnounce(title) end
      if not title then title = "9-1-1 Call Center" end
      title = exports['cnr_wanted']:GetCrimeName(title)
      DispatchMessage(title, place, message)
      DispatchNotification(title, place)
      DispatchBlip(pos.x, pos.y, pos.z, title)
    else print("DEBUG - pos was nil, unable to dispatch.")
    end
  --end
end
AddEventHandler('cnr:dispatch', SendDispatch)


--- EXPORT: DutyAgency()
-- Returns the agency the player is working for
-- @return The agency value; 0 means off duty.
function DutyAgency()
  return myAgency
end


--- EXPORT: DutyStatus()
-- Returns whether the player is on cop duty
-- @return True if on cop duty, false if not
function DutyStatus(client)
  if not client then return isCop end
  local ply = GetPlayerServerId(client)
  if not activeCops[ply] then return false end
  return activeCops[ply]
end


-- DEBUG -
RegisterCommand('cset', function(s,a,r)
  SetPedComponentVariation(PlayerPedId(),
    tonumber(a[1]), tonumber(a[2]), tonumber(a[3]), 2
  )
end)
RegisterCommand('nextitem', function(s,a,r)
  local slotNumber = tonumber(a[1])
  local i = GetPedDrawableVariation(PlayerPedId(), slotNumber)
  SetPedComponentVariation(PlayerPedId(), slotNumber, i+1, 0, 0)
  print("DEBUG - Slot ["..slotNumber.."] Current item #"..i+1)
end)
RegisterCommand('previtem', function(s,a,r)
  local slotNumber = tonumber(a[1])
  local i = GetPedDrawableVariation(PlayerPedId(), slotNumber)
  SetPedComponentVariation(PlayerPedId(), slotNumber, i-1, 0, 0)
  print("DEBUG - Slot ["..slotNumber.."] Current item #"..i-1)
end)


function RequestBackup(emergent)
  local pos    = GetEntityCoords(PlayerPedId())
  local myArea = exports['cnrobbers']:GetFullZoneName(GetNameOfZone(pos.x,pos.y,pos.z))
  if emergent then
    TriggerServerEvent('cnr:police_backup', true, "Backup Request",
      "^1Immediate Need", myArea, pos.x, pos.y, pos.z
    )
  else
    TriggerServerEvent('cnr:police_backup', false, "Backup Request",
      "^3Urgent Need", myArea, pos.x, pos.y, pos.z
    )
  end
end


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


--- PoliceCamera()
-- Operates the camera when toggling duty
function PoliceCamera(c)
  if not DoesCamExist(cam) then
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
  end
  SetCamActive(cam, true)
  RenderScriptCams(true, true, 500, true, true)
  local cInfo = c.cams
  SetCamParams(cam, cInfo.view.pos, 0.0, 0.0, cInfo.view.rot, 60.0)
  Citizen.CreateThread(function()
    while transition do
      HideHudAndRadarThisFrame()
      Citizen.Wait(0)
    end
  end)
  Citizen.Wait(3000)
  DoScreenFadeOut(400)
  Citizen.Wait(600)
  SetCamParams(cam, cInfo.leave.pos, 0.0, 0.0, cInfo.leave.rot, 60.0)
  Citizen.Wait(1000)
  DoScreenFadeIn(1000)
  Citizen.Wait(200)
  Citizen.CreateThread(function()
    Citizen.Wait(4200)
    SetCamActive(cam, false)
    RenderScriptCams(false, true, 500, true, true)
    cam = nil
  end)
end


--- BeginCopDuty()
-- Sets a civilian to be a police officer
-- Checks if player is wanted before going on duty
local oldModel = 0 -- DEBUG - Remove this when going back to MP models
function BeginCopDuty(st)

  local c  = depts[st]
  local wanted = exports['cnr_wanted']:GetWanteds()
  local ply = GetPlayerServerId(PlayerId())
  if not wanted[ply] then wanted[ply] = 0 end
  if wanted[ply] < 1 then
  
    transition = true
    PoliceCamera(c)
    isCop = true
    
    -- DEBUG - Using Ped Model System
    oldModel = GetEntityModel(PlayerPedId())
    print(oldModel)
    local newModel = GetHashKey('s_m_y_cop_01')
    RequestModel(newModel)
    while not HasModelLoaded(newModel) do Wait(1) end
    SetPlayerModel(PlayerId(), newModel)
    SetModelAsNoLongerNeeded(newModel)
    TriggerServerEvent('cnr:police_status', myAgency, true)
    TriggerEvent('cnr:police_duty', true)
    TaskGoToCoordAnyMeans(PlayerPedId(), depts[st].cams.walk.pos, 1.0, 0, 0, 786603, 0)
    PoliceLoadout(true)
    Citizen.Wait(4800)
    exports['cnrobbers']:ChatNotification(
      "CHAR_CALL911", "Police Duty", "~g~Start of Watch",
      "You are now on Law Enforcement duty."
    )
    myAgency = c.agency
    PoliceDutyLoops()
  else
    TriggerEvent('chat:addMessage', {
      args = {"^1You cannot go on police duty while wanted!"}
    })
    TriggerEvent('chat:addMessage', {
      args = {"^1WANTED LEVEL: ^7"..(
        math.floor(wanted[GetPlayerServerId(PlayerId())])
      )}
    })
    Citizen.Wait(12000)
  end
  transition = false
end

--- Reduty()
-- Called if the player just needs a uniform and loadout
function Reduty()
  transition = true
  isCop      = true

  -- DEBUG - Using Ped Model System
  oldModel = GetEntityModel(PlayerPedId())
  print(oldModel)
  local newModel = GetHashKey('s_m_y_cop_01')
  RequestModel(newModel)
  while not HasModelLoaded(newModel) do Wait(1) end
  SetPlayerModel(PlayerId(), newModel)
  SetModelAsNoLongerNeeded(newModel)

  TriggerServerEvent('cnr:police_status', myAgency, true)
  TriggerEvent('cnr:police_duty', true)
  PoliceLoadout(true)
  PoliceDutyLoops()
  Citizen.Wait(1000)
  transition = false
  exports['cnrobbers']:ChatNotification(
    "CHAR_CALL911", "Police Duty", "~y~Restarting Watch",
    "You are now on Law Enforcement duty."
  )
end

-- Rx station info about current duty station
AddEventHandler('cnr:police_station_info', function(stInfo)
  if not stInfo then print("DEBUG - No station information received.")
  else
    
    local decoded = {}
    if stInfo['armory']      then decoded['ar'] = json.decode(stInfo['armory'])      end
    if stInfo['garage']      then decoded['gg'] = json.decode(stInfo['garage'])      end
    if stInfo['garages']     then decoded['gs'] = json.decode(stInfo['garages'])     end
    if stInfo['vehicles']    then decoded['vh'] = json.decode(stInfo['vehicles'])    end
    if stInfo['spawn_heli']  then decoded['he'] = json.decode(stInfo['spawn_heli'])  end
    if stInfo['spawn_cycle'] then decoded['cy'] = json.decode(stInfo['spawn_cycle']) end
    
    -- Restructure stationInfo with new blips and stuff!
    if stationInfo.blips then
      for k,v in pairs (stationInfo.blips) do
        if DoesBlipExist(v) then RemoveBlip(v) end
      end
    end
    stationInfo = { blips = {} }
    for k,v in pairs (decoded) do
      if k == 'ar' or k == 'gg' then
      
        local temp = AddBlipForCoord(v['x'], v['y'], v['z'])
        SetBlipColour(temp, 42)
        
        if     k == 'ar' then
          SetBlipSprite(temp, 487)
          SetBlipScale(temp, 1.1)
        else
          SetBlipSprite(temp, 524)
          SetBlipScale(temp, 0.85)
        end
        
        table.insert(stationInfo.blips, temp)
        
      end -- k != gs
      
      stationInfo[k] = decoded[k]
      
    end -- for
    
  end
end)

AddEventHandler('cnr:police_reduty', Reduty)
-- DEBUG - /forceduty
RegisterCommand('forceduty', function()
  if forcedutyEnabled then
    if not isCop then Reduty()
    else
      TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
        "Already on Law Enforcement duty!"
      }})
    end
  else print("DEBUG - forceduty is not enabled.")
  end
end)


--- EndCopDuty()
-- Sets a civilian to be a police officer
-- Checks if player is wanted before going on duty
function EndCopDuty(st)

  local c = depts[st]
  transition = true
  myAgency   = 0
  PoliceCamera(c)
  
  -- Reset 'stationInfo'
  if stationInfo.blips then
    for k,v in pairs (stationInfo.blips) do 
      if DoesBlipExist(v) then RemoveBlip(v) end
    end
  end
  stationInfo = {}

  -- DEBUG - Using Ped Model System
  RequestModel(oldModel)
  while not HasModelLoaded(oldModel) do Wait(1) end
  SetPlayerModel(PlayerId(), oldModel)
  SetModelAsNoLongerNeeded(oldModel)

  TriggerServerEvent('cnr:police_status', 0, false)
  TriggerEvent('cnr:police_duty', false)
  TaskGoToCoordAnyMeans(PlayerPedId(), c.cams.walk.pos, 1.0, 0, 0, 786603, 0)
  Citizen.Wait(4800)
  exports['cnrobbers']:ChatNotification(
    "CHAR_CALL911", "Police Duty", "~r~End of Watch",
    "You are no longer on Law Enforcement duty."
  )
  PoliceLoadout(false)
  isCop      = false
  transition = false
end


function UnlockPoliceCarDoor()
  local veh = GetVehiclePedIsTryingToEnter(PlayerPedId())
  if veh > 0 then
    local mdl = GetDisplayNameFromVehicleModel(GetEntityModel(veh))
    if policeCar[mdl] then
      if GetVehicleDoorLockStatus(veh) > 0 then
        if isCop then
          SetVehicleDoorsLocked(veh, 0)
          SetVehicleNeedsToBeHotwired(veh, false)
          Citizen.CreateThread(function()
            Citizen.Wait(6000)
            if GetVehiclePedIsIn(PlayerPedId()) ~= veh then
              SetVehicleDoorsLocked(veh, 2)
              SetVehicleNeedsToBeHotwired(veh, true)
            end
          end)
        end
      end
    end
  end
end


--- ImprisonClient()
-- Sends the given ID (or closest player) to prison if they are Wanted
function ImprisonClient(client)
  if isCop then
    if IsPedDeadOrDying(PlayerPedId()) then 
      TriggerEvent('chat:addMessage', {templateId = 'errMsg', args = {
        "You Are Dead",
        "How are you going to arrest someone if you're dead?"
      }})
      return 0
    end
    
    print("DEBUG - Trying to jail client.")
    if not client then
      client = exports['cnrobbers']:GetClosestPlayer()
      print("DEBUG - No Client ID given - Imprisoning nearest client.")
    end
    
    local theyPed = GetPlayerPed(client)
    if IsPedDeadOrDying(theyPed) or IsPlayerDead(client) then 
      TriggerEvent('chat:addMessage', {templateId = 'errMsg', args = {
        "Player is Dead", "You can't put dead people in jail!"
      }})
      return 0
    end
    
    local dist     = #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(GetPlayerPed(client)))
    if dist < 4.25 then
      print("DEBUG - Trying to imprison "..GetPlayerName(client))
      TriggerServerEvent('cnr:prison_sendto', GetPlayerServerId(client))
    else
      TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
        "Too far away, get closer!"
      }})
    end
    
  else
    TriggerEvent('chat:addMessage', {templateId = "errMsg", args = {
      "You are not on Law Enforcement duty!"
    }})
  end
end
RegisterCommand('jail', ImprisonClient)
RegisterCommand('prison', ImprisonClient)
RegisterCommand('ticket', ImprisonClient)


-- DEBUG - ctr is used to determine if B was pressed twice to upgrade alarm to emergent
-- I need to find a better way to implement this later.
local lastRequest = 0
local lastArrest  = 0
function PoliceDutyLoops()

  Citizen.CreateThread(function()
    while isCop do
    
      -- Unlock police vehicle door if entering locked police cars
      if IsControlJustPressed(0, 75) then UnlockPoliceCarDoor() -- F

      -- Request Backup "B"
      elseif IsControlJustPressed(0, 29) and GetLastInputMethod(2) then -- B
        if lastRequest < GetGameTimer() then
          lastRequest = GetGameTimer() + 30000
          RequestBackup(true)
        end

      -- Handle "F1" Busting
      elseif IsControlJustPressed(0, 289) then
        if lastArrest < GetGameTimer() then
          lastArrest = GetGameTimer() + 3000
          Citizen.CreateThread(function()
            ImprisonClient()
          end)
        end
      end
      
      -- Draw markers if applicable
      local myPos = GetEntityCoords(PlayerPedId())
      if stationInfo['ar'] then
        local dmPos = vector3(stationInfo['ar']['x'], stationInfo['ar']['y'], stationInfo['ar']['z'] - 1.12)
        if #(myPos - dmPos) < 100.0 then 
          DrawMarker(1, dmPos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.8, 0.8, 0.45, 255, 0, 0, 120, false, false, 0, false
          )
        end
      end
      if stationInfo['gg'] then
        local dmPos = vector3(stationInfo['gg']['x'], stationInfo['gg']['y'], stationInfo['gg']['z'] - 1.12)
        if #(myPos - dmPos) < 100.0 then 
          DrawMarker(1, dmPos, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
            0.8, 0.8, 0.45, 0, 180, 255, 120, false, false, 0, false
          )
        end
      end
      
      Citizen.Wait(0)
    end
  end)
end


function PoliceArmory()

  -- Closes the menu
  if not openMenu then
    SetNuiFocus(false)
    SendNUIMessage({hidearmory = true})
    Citizen.Wait(3000)
    ignoreDuty = false
  
  -- Opens the menu
  else
    ignoreDuty = true
    SetNuiFocus(true, true)
    SendNUIMessage({showarmory = true})
    LawVehicle("initial", 1) -- Spawns an initial vehicle (vehicle 1)
  
  end
end


--- PoliceGarage()
-- Opens or closes the police vehicle selection menu
-- When opened, it will spawn an initial vehicle as well
-- @param openMenu if true it will open the menu, false closes
function PoliceGarage(openMenu)

  -- Closes the menu
  if not openMenu then
    print("DEBUG - PoliceGarage(false)")
    SetNuiFocus(false)
    SendNUIMessage({hidevehs = true})
    Citizen.Wait(3000)
    ignoreDuty = false
  
  -- Opens the menu
  else
    print("DEBUG - PoliceGarage(true)")
    ignoreDuty = true
    SetNuiFocus(true, true)
    SendNUIMessage({showvehs = true})
    LawVehicle("initial", 1) -- Spawns an initial vehicle (vehicle 1)
  
  end
  
end


Citizen.CreateThread(function()
  while true do
    if not ignoreDuty and not transition then
      local myPos = GetEntityCoords(PlayerPedId())
      for i = 1, #depts do
        if #(myPos - (depts[i].duty)) < 2.1 then
          ignoreDuty = true
          if isCop then EndCopDuty(i)
          else
            -- Ask server for police station info (vehicle spawns, etc)
            TriggerServerEvent('cnr:police_stations_req', i)
            BeginCopDuty(i) -- Trigger duty start
          end
          ignoreDuty = false
        end
        Citizen.Wait(100)
      end
      
      -- If station has an armory, allow interaction
      if stationInfo['ar'] then
        local dist = #(myPos - vector3(stationInfo['ar']['x'],stationInfo['ar']['y'],stationInfo['ar']['z']))
        if dist < 1.25 then 
          PoliceArmory(true)
        end
      end
      
      -- If station has a garage, allow vehicle select
      if stationInfo['gg'] then 
        local dist = #(myPos - vector3(stationInfo['gg']['x'],stationInfo['gg']['y'],stationInfo['gg']['z']))
        if dist < 1.25 then 
          PoliceGarage(true)
        end
      end
      
    end
    Citizen.Wait(10)
  end
end)


Citizen.CreateThread(function()
	while true do
		for i = 1, 14 do EnableDispatchService(i, false) end
		SetPlayerWantedLevel(PlayerId(), 0, false)
		SetPlayerWantedLevelNow(PlayerId(), false)
		SetPlayerWantedLevelNoDrop(PlayerId(), 0, false)
		Wait(0)
	end
end)


local restricted = {
  ["RHINO"] = true,
}
Citizen.CreateThread(function()
  while true do
    Wait(0)
    -- If player gets in a restricted vehicle, delete it
    local vehc = GetVehiclePedIsTryingToEnter(PlayerPedId())
    if vehc > 0 then
      local mdl = GetDisplayNameFromVehicleModel(GetEntityModel(vehc))
      if restricted[mdl] then
        if true then --exports['ham']:MyAdminLevel() < 4 then
          TaskLeaveVehicle(PlayerPedId(), vehc, 16)
        end
      end
      Citizen.Wait(1000)
    end
  end
end)

Citizen.CreateThread(function()
  SetNuiFocus(false)
  -- Removes air traffic
  local scenes = {
    world = {
      "WORLD_VEHICLE_MILITARY_PLANES_SMALL",
      "WORLD_VEHICLE_MILITARY_PLANES_BIG"
    },
    groups = {
      2017590552, -- LSX Traffic
      2141866469, -- Sandy Shores Air Traffic
      1409640232, -- Grapeseed Air Traffic
      "ng_planes", -- Airborne Air Traffic
    },
    planes = {
      "SHAMAL", "LUXOR", "LUXOR2", "JET", "LAZER", "TITAN",
      "BARRACKS", "BARRACKS2", "CRUSADER", "RHINO", "AIRTUG", "RIPLEY"
    }
  }
  while true do
    for _, sctyp in next, (scenes.world) do
      SetScenarioTypeEnabled(sctyp, false)
    end
    for _, scgrp in next, (scenes.groups) do
      SetScenarioGroupEnabled(scgrp, false)
    end
    for _, model in next, (scenes.planes) do
      SetVehicleModelIsSuppressed(GetHashKey(model), true)
    end
    Citizen.Wait(10000)
  end
end)


AddEventHandler('cnr:police_officer_duty', function(ply, onDuty, cLevel)

  if onDuty then  activeCops[ply] = cLevel
  else            activeCops[ply] = nil
  end

  local idPlayer = GetPlayerFromServerId(ply)

  if PlayerId() == idPlayer then
    if not onDuty then
      exports['cnr_chat']:PushNotification(
        2, "DUTY STATUS CHANGED", "You are no longer on duty."
      )

    else
      myCopRank = cLevel
      exports['cnr_chat']:PushNotification(
        2, "DUTY STATUS CHANGED", "You are now on duty<br>Cop Level: "..cLevel
      )

    end

  else
    if DutyStatus() then
      if onDuty then
        exports['cnr_chat']:PushNotification(
          2, "NEW UNIT AVAILABLE", "Officer "..GetPlayerName(idPlayer)..
          " is now On Duty<br>Cop Level: "..cLevel
        )
      else
        exports['cnr_chat']:PushNotification(
          2, "NEW UNIT AVAILABLE", "Officer "..GetPlayerName(idPlayer)..
          " is no longer available."
        )
      end
    end
  end
end)


function CalculateExtras(veh)
  
  local extras = {}
  local hasExtras = false
  for i = 1, 14 do 
    if DoesExtraExist(veh, i) then
      if IsVehicleExtraTurnedOn(veh, i) then
        table.insert(extras,
        '<tr><th colspan="3">Extra '..(i)..'</th><td><button id="te'..(i)..'" onclick="ToggleExtra('..(i)..')">OFF</button></td></tr>'
        )
      else
        table.insert(extras,
        '<tr><th colspan="3">Extra '..(i)..'</th><td><button id="te'..(i)..'" onclick="ToggleExtra('..(i)..')">ON</button></td></tr>'
        )
      end
      print("DEBUG - Vehicle has extra @ Slot #"..i)
      hasExtras = true
    end
  end
  if hasExtras then
    SendNUIMessage({vehextras = table.concat(extras)})
  else
    print("DEBUG - Vehicle has no extras.")
    SendNUIMessage({
      vehextras = '<tr><td colspan="4"><button disabled>NO EXTRAS</button></td></tr>'
    })
  end
  
end


-- DEBUG - Needs to take into account rank authorization
function LawVehicle(actionName, value)

  -- Initial Vehicle Spawn
  if actionName == "initial" then
  
    DoScreenFadeOut(400)
    Citizen.Wait(400)
  
    local mdl    = stationInfo['vh'][1]['mdl']
    local gHash  = GetHashKey(mdl)
    local pspots = math.random(#stationInfo['gs'])
    
    RequestModel(gHash)
    while not HasModelLoaded(gHash) do Wait(10) end
    
    local veh = CreateVehicle(
      GetHashKey(stationInfo['vh'][1]['mdl']),
      stationInfo['gs'][1]['x'],
      stationInfo['gs'][1]['y'],
      stationInfo['gs'][1]['z'],
      0.0, true, false
    )
    
    local ped = PlayerPedId()
		SetVehicleEngineOn(veh, true, false, false)
    FreezeEntityPosition(veh, true)
		SetVehicleLivery(veh, 1)
		SetVehicleOnGroundProperly(veh)
    SetEntityHeading(veh, stationInfo['gs'][1]['h'])
		SetVehicleNeedsToBeHotwired(veh, false)
		SetPedIntoVehicle(ped, veh, (-1))
    
    -- DEBUG - Revisit vehicle mods later
		SetVehicleModKit(veh, 0)
		SetVehicleMod(veh, 11, 3, false) -- EMS 4 Engine
		SetVehicleMod(veh, 12, 1, false) -- Sport Brakes
		SetVehicleMod(veh, 13, 2, false) -- Performance Transmission
		
		SetModelAsNoLongerNeeded(gHash)
    CalculateExtras(veh)
    
    Citizen.Wait(1000)
    if not DoesCamExist(cam) then
      cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
    end
    SetCamActive(cam, true)
    RenderScriptCams(true, true, 500, true, true)
    local pHead = GetEntityHeading(veh)
    local offset = GetOffsetFromEntityInWorldCoords(veh, -2.4, 6.0, 1.2)
    SetCamParams(cam, offset.x, offset.y, offset.z, 350.0, 0.0, pHead + 200.0, 60.0)
    DoScreenFadeIn(1000)
    
  -- Change the extra(s)
  elseif actionName == "extra" then 

    local veh = GetVehiclePedIsIn(PlayerPedId())
    local i = value
    if IsVehicleExtraTurnedOn(veh, i) then
      SendNUIMessage({togextra = i, flipname = "ON"})
      SetVehicleExtra(veh, i, 1)
    else
      SendNUIMessage({togextra = i, flipname = "OFF"})
      SetVehicleExtra(veh, i, 0)
    end
    
  -- Change the vehicle selected
  elseif actionName == "change" then
  
    local veh = GetVehiclePedIsIn(PlayerPedId())
    local thisModel = GetEntityModel(veh)
    local curr = 1
    
    if veh > 0 then
      DeleteVehicle(veh)
    end
    
    local count = 0
    local resolved = false
    for k,v in pairs (stationInfo['vh']) do
      count = count + 1
      if not resolved then
        if GetHashKey(v['mdl']) == thisModel then
          curr = k
          print("DEBUG - "..GetHashKey(v['mdl']).." == "..thisModel)
          if value == 2 then curr = curr + 1
          else               curr = curr - 1
          end
          resolved = true
        end
      end
    end
    if curr > count or curr < 1 then
      if curr < 0 then curr = count
      else curr = 1 end
      print("DEBUG - curr was out of range, reset to "..curr..".")
    end
    print("DEBUG - Vehicle "..curr.." of "..count)
    
    local mdl = stationInfo['vh'][curr]['mdl']
    local gHash = GetHashKey(mdl)
    RequestModel(gHash)
    while not HasModelLoaded(gHash) do Wait(10) end
    
    local gSpot = 1
    local myPos = GetEntityCoords(PlayerPedId())
    local gs    = stationInfo['gs']
    local d1    = vector3(stationInfo['gs'][1]['x'], stationInfo['gs'][1]['y'], stationInfo['gs'][1]['z'])
    for k,v in pairs(gs) do 
      local d2 = vector3(v['x'], v['y'], v['z'])
      if #(myPos - vector3(d1['x'], d1['y'], d1['z'])) > #(myPos - d2) then
        d1 = d2; gSpot = k
      end
    end
    
    local veh = CreateVehicle(
      GetHashKey(stationInfo['vh'][curr]['mdl']),
      stationInfo['gs'][gSpot]['x'],
      stationInfo['gs'][gSpot]['y'],
      stationInfo['gs'][gSpot]['z'],
      0.0, true, false
    )
    
    local ped = PlayerPedId()
    FreezeEntityPosition(veh, true)
		SetVehicleEngineOn(veh, true, false, false)
		SetVehicleLivery(veh, 1)
		SetVehicleOnGroundProperly(veh)
    SetEntityHeading(veh, stationInfo['gs'][gSpot]['h'])
		SetVehicleNeedsToBeHotwired(veh, false)
		SetPedIntoVehicle(ped, veh, (-1))
		
    -- DEBUG - Revisit vehicle mods later
		SetVehicleModKit(veh, 0)
		SetVehicleMod(veh, 11, 3, false) -- EMS 4 Engine
		SetVehicleMod(veh, 12, 1, false) -- Sport Brakes
		SetVehicleMod(veh, 13, 2, false) -- Performance Transmission
		
		SetModelAsNoLongerNeeded(veh)
    CalculateExtras(veh)
    
  
  end
end

RegisterNUICallback("vehicleMenu", function(data, cb)

  local cmd = data.action
  if cmd == "lawVehicle" then
    LawVehicle("change", data.dir)
  
  elseif cmd == "toggleExtra" then
    LawVehicle("extra", data.num)
  
  else -- Fallback case: Close Menu
    FreezeEntityPosition(GetVehiclePedIsIn(PlayerPedId()), false)
    if DoesCamExist(cam) then 
      SetCamActive(cam, false)
      RenderScriptCams(false, true, 500, true, true)
      cam = nil
    end
    PoliceGarage(false)
    print("DEBUG - Law Vehicle selection canceled / closed.")
    
  end

end)