

local connected = false


-- DEBUG - Remove later
-- /relog
-- Allows the player to invoke the create_player event as if
-- they had just connected to the server.
RegisterCommand('relog', function()
  TriggerServerEvent('cnr:create_player')
end)


-- On connection to the server
--AddEventHandler('onClientGameTypeStart', function()   
AddEventHandler('onClientResourceStart', function(resname)
  if GetCurrentResourceName() == resname then
  
    --exports.spawnmanager:setAutoSpawn(false)
    Citizen.Wait(100)
    
    print("DEBUG - Requesting for the server to let me spawn.")
    --SendNUIMessage({showwelcome = true})
    --SetNuiFocus(true, true)
    
    Citizen.CreateThread(function()
      while not connected do 
        TriggerServerEvent('cnr:create_player')
        Citizen.Wait(3000)
      end
      print("DEBUG - The Server has acknowledged my connection.")
    end)
  end
end)


--- EVENT: create_ready 
-- Called when the character (or lack thereof) is ready
-- and the player can join.
RegisterNetEvent('cnr:create_ready')
AddEventHandler('cnr:create_ready', function() 
  --print("DEBUG - Changing button from ^1LOADING ^7to ^2PLAY")
  --SendNUIMessage({hideready = true})
  connected = true
end)


--- EVENT: create_finished
-- Called when the player has finished creating their player model
RegisterNetEvent('cnr:create_finished')
AddEventHandler('cnr:create_finished', function()
  local game_area = exports['cnrobbers']:GetActiveZone()
  SendNUIMessage({hideallmenus = true})
  SetNuiFocus(false)
  SetCamActive(cam, false)
  RenderScriptCams(false, true, 500, true, true)
  cam = nil
  local n   = math.random(#spPoints[game_area])
  local pos = spPoints[game_area][n]
  SetEntityCoords(PlayerPedId(), pos)
  TriggerEvent('cnr:new_player_ready')
  TriggerEvent('cnr:loaded')
  TriggerServerEvent('cnr:client_loaded')
  Wait(400)
  if IsScreenFadedOut() then DoScreenFadeIn(1000) end
  exports['cnrobbers']:ReportPosition(true)
end)


--- EVENT: changelog
-- Called when the player receives the changelog from the server
RegisterNetEvent('cnr:changelog')
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
  SendNUIMessage({showwelcome = true, motd = table.concat(msgInfo)})
  SetNuiFocus(true, true)
end)


--- EVENT: create_reload
-- Called when player has an existing character to reload
RegisterNetEvent('cnr:create_reload')
AddEventHandler('cnr:create_reload', function(myChar)
  SendNUIMessage({hideallmenus = true})
  SetNuiFocus(false)
  local lastPos = json.decode(myChar["position"])
  --SetEntityCoords(PlayerPedId(), lastPos['x'], lastPos['y'], lastPos['z'])
  local myModel = GetHashKey(myChar["model"])
  print("DEBUG - Reloading Model ["..tostring(myChar["model"]).."]")
  --RequestModel(myModel)
  --while not HasModelLoaded(myModel) do Wait(1) end
  --SetPlayerModel(PlayerId(), myModel)
  --SetModelAsNoLongerNeeded(myModel)
	exports.spawnmanager:spawnPlayer({
		x     = lastPos.x,
		y     = lastPos.y,
		z     = lastPos.z,
		model = myChar['model']
	}, function()
    SetNuiFocus(false)
    exports['cnrobbers']:ReportPosition(true)
    TriggerEvent('cnr:loaded')
    TriggerEvent('cnr:wallet_valet', myChar['cash'])
    TriggerEvent('cnr:bank_account', myChar['bank'])
    TriggerServerEvent('cnr:client_loaded')
  end)
end)


--- EVENT: create_session
-- Called if the player hasn't played here before, and needs a character
RegisterNetEvent('cnr:create_character')
AddEventHandler('cnr:create_character', function()

  SendNUIMessage({hidewelcome = true})
  SetNuiFocus(true, true)
  
  if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
  SetEntityCoords(PlayerPedId(), -1702.72, -1085.94, 13.1523)
  SetEntityHeading(PlayerPedId(), 40.0)
  SetCamParams(cam, -1702.72, -1082.0, 13.1923, 0.0, 0.0, 180.0, 50.0)
  RenderScriptCams(true, true, 500, true, true)
  SetCamActive(cam, true)
  
  if IsScreenFadedOut() then DoScreenFadeIn(1000) end
  
  Citizen.Wait(600)
  SendNUIMessage({showpedpick = true})
  
  -- Default model spawn
  ModelChoice("random")
  
end)


--- NUI: playGame
-- Called when the player clicks "PLAY" at the welcome screen
RegisterNUICallback("playGame", function(data, cb)
  SendNUIMessage({hidewelcome = true})
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
    print("^3DEBUG - Menu given RANDOM MODEL command!")
    oldPM = pm
    pm = math.random(#pedModels)
    while not pedModels[pm] do 
      pm = math.random(#pedModels)
      Wait(10)
    end
  
  elseif data == "last" then 
    print("^3DEBUG - Menu given LAST command!")
    pm = pm - 1
    if pm < 1 then pm = #pedModels end
  
  elseif data == "next" then 
    print("^3DEBUG - Menu given NEXT command!")
    pm = pm + 1
    if pm > #pedModels then pm = 1 end
  
  else
    print("^3DEBUG - No argument given to menu, submitting character for approval.")
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
        "].\nModel removed from eligible list. Please try again."
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