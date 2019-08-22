
--[[
  Cops and Robbers: Character Creation (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  08/20/2019
  
  This file handles all client-sided interaction to verifying character
  information, switching characters, and creating characters.
  
--]]

-- DEBUG - Remove later
RegisterCommand('relog', function()
  if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
  SetCamParams(cam, -1756.53, -1117.24, 18.0, 6.0, 0.0, 0.0, 50.0) 
  RenderScriptCams(true, true, 500, true, true)
  SetCamActive(cam, true)
  print("DEBUG - Requesting for the server to send us the changelog.")
  SendNUIMessage({showwelcome = true})
  SetNuiFocus(true, true)
  TriggerServerEvent('cnr:create_player')
end)


AddEventHandler('onClientGameTypeStart', function()   
  print("DEBUG - Preparing to load player into the server.")
  --exports.spawnmanager:setAutoSpawn(false)
  
  Citizen.Wait(1000)
  
  if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
  SetCamParams(cam, -1756.53, -1117.24, 18.0, 6.0, 0.0, 0.0, 50.0) 
  RenderScriptCams(true, true, 500, true, true)
  SetCamActive(cam, true)
  
  print("DEBUG - Requesting for the server to send us the changelog.")
  SendNUIMessage({showwelcome = true})
  SetNuiFocus(true, true)
  TriggerServerEvent('cnr:create_player')
end)


--- EVENT: create_ready 
-- Called when the character (or lack thereof) is ready
-- and the player can join.
RegisterNetEvent('cnr:create_ready')
AddEventHandler('cnr:create_ready', function() 
  print("DEBUG - Changing button from ^1LOADING ^7to ^2PLAY")
  SendNUIMessage({hideready = true})
end)


RegisterNetEvent('cnr:create_finished')
AddEventHandler('cnr:create_finished', function()
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
  --ReportPosition()
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


--- EVENT: create_session
-- Called if the player hasn't played here before, and needs a character
RegisterNetEvent('cnr:create_character')
AddEventHandler('cnr:create_character', function()
  SendNUIMessage({hidewelcome = true})
  if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
  SetEntityCoords(PlayerPedId(), -1702.72, -1085.94, 13.1523)
  SetEntityHeading(PlayerPedId(), 40.0)
  SetCamParams(cam, -1702.72, -1082.0, 13.1923, 0.0, 0.0, 180.0, 50.0)
  RenderScriptCams(true, true, 500, true, true)
  SetCamActive(cam, true)
  if IsScreenFadedOut() then DoScreenFadeIn(1000) end
  Citizen.Wait(600)
  SendNUIMessage({showpedpick = true})
end)


RegisterNUICallback("playGame", function(data, cb)
  SendNUIMessage({hidewelcome = true})
  DoScreenFadeOut(300)
  Citizen.Wait(500)
  SetCamActive(cam, false)
  RenderScriptCams(false, true, 500, true, true)
  cam = nil
  TriggerServerEvent('cnr:create_session')
end)


-- DEBUG - 
local pm = 1
RegisterNUICallback("modelPick", function(data, cb)
  local oldPM = pm
  if coolDown then
    TriggerEvent('chatMessage', "^8Selection cooldown in effect.")
    return 0
  end
  
  coolDown = true
  
  if data == "last" then 
    pm = pm - 1
    if pm < 1 then pm = #pedModels end
  
  elseif data == "next" then 
    pm = pm + 1
    if pm > #pedModels then pm = 1 end
  
  -- Allow character model to be used
  elseif data == "addTo" then 
    TriggerServerEvent('cnr:debug_save_model', pedModels[pm])
    TriggerEvent('chatMessage', "^2Added model ["..pedModels[pm].."] to list of authorized models.")
    coolDown = false
    return 0
    
  else
    TriggerServerEvent('cnr:create_save_character', pedModels[pm])
    coolDown = false
    return 0
    
  end
  
  local newHash = GetHashKey(pedModels[pm])
  -- DEBUG -
  TriggerEvent('chatMessage', "^7"..pedModels[pm].." #^3"..(pm))
  print("^7"..pedModels[pm].." #^3"..(pm))
  local timeOut = GetGameTimer() + 8000
  RequestModel(newHash)
  while not HasModelLoaded(newHash) do
    if GetGameTimer() > timeOut then 
      TriggerEvent('chatMessage', "^1Timed out waiting for model to load ["..pedModels[pm].."]")
      table.remove(pedModels, pm)
      pm = oldPM
      coolDown = false
      return 0
    end
    Wait(10)
  end
  
  SetPlayerModel(PlayerId(), newHash)
  SetModelAsNoLongerNeeded(newHash)
  
  coolDown = false
  
end)