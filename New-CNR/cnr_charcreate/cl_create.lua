
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
  
  --[[
  exports.spawnmanager:spawnPlayer({
    x = cams.start.ped.x,
    y = cams.start.ped.y,
    z = cams.start.ped.z + 1.0,
    model = "mp_m_freemode_01"
  }, function()
    
  end)
  ]]
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


--- EVENT: create_reload
-- Called when reloading a saved character
RegisterNetEvent('cnr:create_reload')
AddEventHandler('cnr:create_reload', function(cInfo)
  
  SendNUIMessage({hideallmenus = true})
  SetNuiFocus(false)
  
  local pos = json.decode(cInfo["position"])
  local pt  = json.decode(cInfo["blenddata"])
  Wait(200)
  
  SetCamActive(cam, false)
  RenderScriptCams(false, true, 500, true, true)
  cam = nil
    
  Wait(1000)
  
  exports.spawnmanager:spawnPlayer({
    x     = pos["x"],
    y     = pos["y"],
    z     = pos["z"] + 0.08,
    model = cInfo["model"]
  }, function()
  
    local ped = PlayerPedId()
    
    -- Set ped to default config, then set blend data
    SetPedDefaultComponentVariation(ped)
    Wait(100)
    SetPedHeadBlendData(ped,
      pt[1], pt[2], 0, pt[1], pt[2], 0,
      pt[3], pt[4], 0.0, false
    )
    
    -- Load permanent body overlays 
    local bodyInfo = json.decode(cInfo["bodystyle"])
    ped = PlayerPedId()
    for k,v in pairs(bodyInfo) do 
      SetPedHeadOverlay(ped, v["slot"], v["index"], 1.0)
    end
    Wait(100)
    
    -- Load non-permanent overlays
    local bodyDetails = json.decode(cInfo["overlay"])
    ped = PlayerPedId()
    for k,v in pairs(bodyDetails) do 
      SetPedHeadOverlay(ped, v["slot"], v["index"], 1.0)
      if v["slot"] == 2 or v["slot"] == 10 or v["slot"] == 1 then 
        SetPedHeadOverlayColor(ped, v["slot"], 1, 1, 1)
      elseif v["slot"] == 5 or v["slot"] == 8 then
        SetPedHeadOverlayColor(ped, v["slot"], 2, 1, 1)
      else
        SetPedHeadOverlayColor(ped, v["slot"], 0, 1, 1)
      end
    end
    Wait(100)
    
    -- Load last used outfit
    local myOutfit = json.decode(cInfo["clothes"])
    ped = PlayerPedId()
    for k,v in pairs(myOutfit) do 
      SetPedComponentVariation(ped, v["slot"], v["draw"], v["text"], 2)
    end
    Wait(100)
    
    -- Load hair information
    local hair = json.decode(cInfo["hairstyle"])
    ped = PlayerPedId()
    SetPedComponentVariation(ped, 2, hair["draw"], hair["text"], 2)
    SetPedHairColor(ped, hair["color"], hair["light"])
    Wait(100)
    
    TriggerServerEvent('cnr:client_loaded')
    TriggerEvent('cnr:loaded')
    ReportPosition()
    
    Wait(200)
    if IsScreenFadedOut() then
      DoScreenFadeIn(1000)
    end
    
  end)
  Citizen.CreateThread(function()
    Citizen.Wait(5000)
    if IsScreenFadedOut() then
      DoScreenFadeIn(1000)
    end
  end)
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