
RegisterNetEvent('cnr:changelog')
RegisterNetEvent('cnr:create_reload')
RegisterNetEvent('cnr:create_character')
RegisterNetEvent('cnr:create_ready')
RegisterNetEvent('cnr:create_finished')

local connected = false


-- DEBUG - Remove later
-- /relog
-- Allows the player to invoke the create_player event as if
-- they had just connected to the server.
RegisterCommand('relog', function()
  TriggerServerEvent('cnr:create_player')
end)


-- Establish server connection
Citizen.CreateThread(function()
  while not connected do
    print("DEBUG - Requesting for the server to let me spawn.")
    TriggerServerEvent('cnr:create_player')
    Citizen.Wait(5000)
  end
  print("DEBUG - The Server has acknowledged my connection.")
end)


--- EVENT: create_ready
-- Called when the character (or lack thereof) is ready
-- and the player can join.
AddEventHandler('cnr:create_ready', function()
  connected = true
end)


--- EVENT: create_finished
-- Called when the player has finished creating their player model
AddEventHandler('cnr:create_finished', function()
  local game_area = CNR.zones.active
  if not game_area then game_area = 1 end
  SendNUIMessage({hideallmenus = true})
  SetNuiFocus(false)
  SetCamActive(cam, false)
  RenderScriptCams(false, true, 500, true, true)
  cam = nil
  SetEntityCoords(PlayerPedId(), GetSpawnpoint(game_area))
  TriggerEvent('cnr:new_player_ready')
  TriggerEvent('cnr:loaded')
  TriggerServerEvent('cnr:client_loaded')
  Wait(400)
  if IsScreenFadedOut() then DoScreenFadeIn(1000) end
  ReportPosition(true)
end)


--- EVENT: changelog
-- Called when the player receives the changelog from the server
AddEventHandler('cnr:changelog', function(logLines)
  local msgInfo = {}
  --table.insert(msgInfo, '<ul>')
  for k,v in pairs(logLines) do
    if v ~= "" then
      local cl    = string.find(v, ":")
      local dt    = string.sub(v, 0, 10)
      local subj  = string.sub(v, 11, cl)
      local deets = string.sub(v, cl+2, string.len(v))
      table.insert(msgInfo,
        '<li><strong>'..subj..
        '</strong><br>&nbsp;&nbsp;'..dt..
        '<br>&nbsp;&nbsp;'..deets..'</li>'
      )
    end
    Wait(1)
  end
  --table.insert(msgInfo, '</ul>')
  SendNUIMessage({show = 'motd_bkgd', motd = table.concat(msgInfo)})
  SetNuiFocus(true, true)
end)


--- EVENT: create_reload
-- Called when player has an existing character to reload
AddEventHandler('cnr:create_reload', function(myChar)

  SendNUIMessage({hideallmenus = true})
  SetNuiFocus(false)
  print("Reloading Model", myChar['model'])

	exports.spawnmanager:spawnPlayer({
		x = myChar['x'], y = myChar['y'], z = myChar['z'],
    model = myChar['model']
	}, function()
    SetNuiFocus(false)
    TriggerEvent('cnr:wallet_valet', myChar['cash'])
    TriggerEvent('cnr:bank_account', myChar['bank'])
    ReportPosition(true)
    TriggerEvent('cnr:loaded')
    TriggerServerEvent('cnr:client_loaded')
  end)
  
end)


--- EVENT: create_session
-- Called if the player hasn't played here before, and needs a character
AddEventHandler('cnr:create_character', function()

  SendNUIMessage({hide = 'motd_bkgd'})
  SetNuiFocus(true, true)

  -- Default model spawn

  local mdl = ModelChoice('random')
  
  -- This should be changed later to use a psuedo-ped, not the actual player
	exports.spawnmanager:spawnPlayer({
		x     = -1702.72,
		y     = -1085.94,
		z     = 13.1523,
		model = mdl
	}, function()

    if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
    SetCamParams(cam, -1702.72, -1082.0, 13.1923, 0.0, 0.0, 180.0, 50.0)
    RenderScriptCams(true, true, 500, true, true)
    SetCamActive(cam, true)

    if IsScreenFadedOut() then DoScreenFadeIn(1000) end
    SendNUIMessage({show = 'ped-select'})

  end)

end)


--- NUI: playGame
-- Called when the player clicks "PLAY" at the welcome screen
RegisterNUICallback("playGame", function(data, cb)
  SendNUIMessage({hide = 'motd_bkgd'})
  DoScreenFadeOut(300)
  Citizen.Wait(500)
  SetCamActive(cam, false)
  RenderScriptCams(false, true, 500, true, true)
  cam = nil
  TriggerServerEvent('cnr:create_session')
end)


-- DEBUG - Model Selection
-- This is the temporary ped model selection.
-- We will make the move to the freemode models once we have more time, but
-- this works for the time being.
local pm = 1
function ModelChoice(data, cb)
  local oldPM = pm
  if coolDown then
    TriggerEvent('chatMessage', "^8You're clicking too fast! Please Wait.")
    return 0
  end

  coolDown = true

  if data == "random" then
    oldPM = pm
    pm = math.random(#pedModels)
    while not pedModels[pm] do
      pm = math.random(#pedModels)
      Wait(10)
    end

  elseif data == "last" then
    pm = pm - 1
    if pm < 1 then pm = #pedModels end

  elseif data == "next" then
    pm = pm + 1
    if pm > #pedModels then pm = 1 end

  else
    TriggerServerEvent('cnr:create_save_character', pedModels[pm])
    coolDown = false
    return 0

  end

  local newHash = GetHashKey(pedModels[pm])
  local timeOut = GetGameTimer() + 4000
  RequestModel(newHash)
  while not HasModelLoaded(newHash) do
    if GetGameTimer() > timeOut then
      TriggerEvent('chatMessage', "^1Failed to load model ["..pedModels[pm]..
        "].\nModel was removed from the list. Please try again."
      )
      table.remove(pedModels, pm)
      pm       = oldPM
      coolDown = false
      return 0
    end
    Wait(10)
  end

  SetPlayerModel(PlayerId(), newHash)
  SetModelAsNoLongerNeeded(newHash)
  coolDown = false
  
end
RegisterNUICallback("modelPick", ModelChoice)