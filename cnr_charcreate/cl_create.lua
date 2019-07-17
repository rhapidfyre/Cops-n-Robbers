
--[[
  Cops and Robbers: Character Creation (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  05/11/2019
  
  This file handles all client-sided interaction to verifying character
  information, switching characters, and creating characters.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]


local sign      = GetHashKey("prop_police_id_board")
local ovrl      = GetHashKey("prop_police_id_text")
local cb        = nil
local ov        = nil
local lastPos   = nil

local game_area = 1
local handle    = nil

local myParents = {[1] = 1, [2] = 21}
local mySimilar = 50

local reportLocation = false

 -- DEBUG - 
Citizen.CreateThread(function()
  Wait(1000)
  SetNuiFocus(false)
end)
    
local cam = nil

AddEventHandler('onClientGameTypeStart', function()   
  print("DEBUG - Preparing to load player into the server.")
  exports.spawnmanager:setAutoSpawn(false)
  Citizen.Wait(1000)
  
  local c = cams.start
  if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
  SetCamActive(cam, true)
  RenderScriptCams(true, true, 500, true, true)
  SetCamParams(cam,
    c.view.x, c.view.y, c.view.z,
    c.rotx, c.roty, c.h,
    50.0
  ) 
  print("DEBUG - Spawn Camera created.")
  
  exports.spawnmanager:spawnPlayer({
    x = cams.start.ped.x,
    y = cams.start.ped.y,
    z = cams.start.ped.z + 1.0,
    model = "mp_m_freemode_01"
  }, function()
   
    print("DEBUG - Spawning temporary player.")
    SetPedDefaultComponentVariation(PlayerPedId())
    
  end)
  TriggerServerEvent('cnr:create_player')
end)


--- EVENT: create_character
-- Creates a new player for newbies or if character was wiped/lost
RegisterNetEvent('cnr:create_character')
AddEventHandler('cnr:create_character', function()
  
  Wait(200)
  
  SetPedDefaultComponentVariation(PlayerPedId())
  ModifyParents(1, 21, 50)
 
  local c   = cams.creator
  SetEntityCoords(PlayerPedId(), c.ped)
  SetEntityHeading(PlayerPedId(), c.h)
  
  Wait(200)
  
  if not DoesCamExist(cam) then
    cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true)
  end
  
  SetCamActive(cam, true)
  RenderScriptCams(true, true, 500, true, true)
  
  SetCamParams(cam,
    c.view.x, c.view.y, c.view.z,
    c.rotx, c.roty, c.rotz,
    50.0
  )
  
  RequestAnimDict(creation.dict)
  while not HasAnimDictLoaded(creation.dict) do Wait(10) end
  
  TaskPlayAnim(PlayerPedId(), creation.dict, creation.anim,
    8.0, 0, (-1), 2, 0, 0, 0, 0
  )
  
  Wait(200)
  DoScreenFadeIn(600)
  
  Citizen.CreateThread(CreateBoardDisplay)
  
  Wait(6400)
  
  TaskPlayAnim(PlayerPedId(), creation.dict, "loop",
    8.0, 0, (-1), 1, 0, 0, 0, 0
  )
  
  SendNUIMessage({opendesigner = true})
  SetNuiFocus(true, true)
    
end)


RegisterNetEvent('cnr:create_finished')
AddEventHandler('cnr:create_finished', function()

  SendNUIMessage({hideallmenus = true})
  SetNuiFocus(false)
  
  RequestAnimDict(creation.dict)
  while not HasAnimDictLoaded(creation.dict) do Wait(10) end
  
  TaskPlayAnim(PlayerPedId(), creation.dict, creation.done,
    8.0, 0, 3200, 1, 0, 0, 0, 0
  )
  
  Wait(2000)
  DoScreenFadeOut(1000)
  Wait(1200)
  
  SetCamActive(cam, false)
  RenderScriptCams(false, true, 500, true, true)
  cam = nil
  
  DeleteObject(ov)
  DeleteObject(cb)
  
  local n = math.random(#spPoints[game_area])
  local pos = spPoints[game_area][n]
  SetEntityCoords(PlayerPedId(), pos)
  
  ClearPedTasksImmediately(PlayerPedId())
  ClearPedSecondaryTask(PlayerPedId())
  
  Wait(400)
  
  if IsScreenFadedOut() then
    DoScreenFadeIn(1000)
  end
  
  ReleaseNamedRendertarget(handle)
  Citizen.InvokeNative(0xE9F6FFE837354DD4, 'tvscreen')
  handle = nil
  TriggerEvent('cnr:new_player_ready')
  TriggerEvent('cnr:client_loaded')
  TriggerServerEvent('cnr:client_loaded')
  
end)





local function CreateNamedRenderTargetForModel(name, model)
	local handle = 0
	if not IsNamedRendertargetRegistered(name) then
		RegisterNamedRendertarget(name, 0)
	end
	if not IsNamedRendertargetLinked(model) then
		LinkNamedRendertarget(model)
	end
	if IsNamedRendertargetRegistered(name) then
		handle = GetNamedRendertargetRenderId(name)
	end

	return handle
end

local function LoadScaleform (scaleform)
	local handle = RequestScaleformMovie(scaleform)

	if handle ~= 0 then
		while not HasScaleformMovieLoaded(handle) do
			Citizen.Wait(0)
		end
	end

	return handle
end

local function CallScaleformMethod (scaleform, method, ...)
	local t
	local args = { ... }

	BeginScaleformMovieMethod(scaleform, method)

	for k, v in ipairs(args) do
		t = type(v)
		if t == 'string' then
			PushScaleformMovieMethodParameterString(v)
		elseif t == 'number' then
			if string.match(tostring(v), "%.") then
				PushScaleformMovieFunctionParameterFloat(v)
			else
				PushScaleformMovieFunctionParameterInt(v)
			end
		elseif t == 'boolean' then
			PushScaleformMovieMethodParameterBool(v)
		end
	end

	EndScaleformMovieMethod()
end

function CreateBoardDisplay()

  local ped  = PlayerPedId()
  
  RequestModel(sign)
  RequestModel(ovrl)
  while not HasModelLoaded(sign) or not HasModelLoaded(ovrl) do Wait(10) end
  cb = CreateObject(sign, GetEntityCoords(ped), false, false, false)
  ov = CreateObject(ovrl, GetEntityCoords(ped), false, false, false)
  
	AttachEntityToEntity(ov, cb, (-1), 4103,
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0, 0, 0, 0, 2, 1
  )
  
	AttachEntityToEntity(cb, ped,
    GetPedBoneIndex(ped, 28422),
    0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
    0, 0, 0, 0, 2, 1
  )
  
  SetModelAsNoLongerNeeded(sign)
  SetModelAsNoLongerNeeded(ovrl)
  
  Citizen.CreateThread(function()
    board_scaleform = LoadScaleform("mugshot_board_01")
    handle = CreateNamedRenderTargetForModel("ID_Text", ovrl)
  
    CallScaleformMethod(board_scaleform, 'SET_BOARD',
      GetPlayerName(PlayerId()),
      "31337455",
      "LOS SANTOS POLICE DEPT",
      "TRANSFERRED",
      0, 0, 116
    )
  
    while handle do
      HideHudAndRadarThisFrame()
      SetTextRenderId(handle)
      Set_2dLayer(4)
      Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
      DrawScaleformMovie(board_scaleform, 0.405, 0.37, 0.81, 0.74, 255, 255, 255, 255, 0)
      Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
      SetTextRenderId(GetDefaultScriptRendertargetRenderId())
  
      Citizen.InvokeNative(0xC6372ECD45D73BCD, 1)
      Citizen.InvokeNative(0xC6372ECD45D73BCD, 0)
      Wait(0)
    end
  end)
end


function SwitchGender()
  local currModel = GetEntityModel(PlayerPedId())
  local newHash   = femaleHash
  if (femaleHash == currModel) then 
    newHash = maleHash
  end
  RequestModel(newHash)
  while not HasModelLoaded(newHash) do Wait(10) end
  SetPlayerModel(PlayerId(), newHash)
  Wait(100)
  SetPedDefaultComponentVariation(PlayerPedId())
  SendNUIMessage({getParents = true}) -- Update blend data
end


function ModifyParents(one, two, val)
  myParents = {[1] = one, [2] = two}
  mySimilar = val
  SetPedHeadBlendData(PlayerPedId(),
    one, two, 0,
    one, two, 0,
    (100 - val)/100,
    val/100,
    0.0, false
  )
end

function DesignerCamera(addX, addY, addZ, rotX, rotY, rotZ, fov)
  if not addX then addX =  0.0 end
  if not addY then addY =  0.0 end
  if not addX then addZ =  0.0 end
  if not rotX then rotX =  0.0 end
  if not rotY then rotY =  0.0 end
  if not rotZ then rotZ =  0.0 end
  if not fov  then fov  = 50.0 end
  local c = cams.creator
  SetCamParams(cam,
    c.view.x + addX, c.view.y + addY, c.view.z + addZ,
    c.rotx + rotX, c.roty + rotY, c.rotz + rotZ,
    fov
  )
end









--- EVENT: create_ready 
-- Called when the character (or lack thereof) is ready
-- and the player can join.
RegisterNetEvent('cnr:create_ready')
AddEventHandler('cnr:create_ready', function() 
  print("DEBUG - Changing button from LOADING to PLAY")
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
    TriggerEvent('cnr:client_loaded')
    
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


-- Start saving the player's location
AddEventHandler('cnr:client_loaded', function()
  if not reportLocation then 
    reportLocation = true
    -- Sends update to MySQL every 12 seconds
    -- Does not send the update if position has not changed
    Citizen.CreateThread(function()
      while reportLocation do 
        if plyIsDead or IsPedDeadOrDying(PlayerPedId()) then 
          print("[CNR] Cannot report position; Player is dead.")
        else
          local myPos = GetEntityCoords(PlayerPedId())
          local doUpdate = false 
          if not lastPos then 
            doUpdate = true 
          elseif #(lastPos - myPos) > 5.0 then 
            doUpdate = true
          end
          if doUpdate then
            local savePos = {
              x = math.floor(myPos.x*1000)/1000,
              y = math.floor(myPos.y*1000)/1000,
              z = math.floor(myPos.z*1000)/1000
            }
            TriggerServerEvent('cnr:save_pos', json.encode(savePos))
          end
          lastPos = GetEntityCoords(PlayerPedId())
        end
        Citizen.Wait(12000)
      end
    end)
  end
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


RegisterNUICallback("heritage", function(data, cb)
  if data.action == "gender" then 
    SwitchGender()
    DesignerCamera(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 50.0)
  
  elseif data.action == "changeParent" then
    ModifyParents(data.pOne, data.pTwo, data.similarity)
  
  end
end)

RegisterNUICallback("doOverlays", function(data, cb)
  if data.action == "setOverlay" then 
    local i = tonumber(data.ovr)
    local s, n, ct, c1, c2, c0 = GetPedHeadOverlayData(PlayerPedId(), i)
    
    if data.direction == 1 then n = n + 1
    else n = n - 1
    end
    
    if     n <    0             then n = 255
    elseif n == 254 or n == 256 then n =   0
    elseif n >  maxOverlays[i]  then n = 255
    end
    
    SetPedHeadOverlay(PlayerPedId(), i, n, 1.0)
    SetPedHeadOverlayColor(PlayerPedId(), i, 1, 1, 1)
    DesignerCamera(0.0, 0.8, 0.24, 0.0, 0.0, 0.0, 50.0)
    
    if i == 10 or i == 11 then 
      if GetEntityModel(PlayerPedId()) == maleHash then 
        SetPedComponentVariation(PlayerPedId(), 11, 91, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 3,  15, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 8,  15, 0, 0)
      else
        SetPedComponentVariation(PlayerPedId(), 11, 18, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 3,  15, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 8,  14, 0, 0)
      end
    else
      if GetEntityModel(PlayerPedId()) == maleHash then 
        SetPedComponentVariation(PlayerPedId(), 11, 0, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 3,  0, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 8,  15, 0, 0)
      else
        SetPedComponentVariation(PlayerPedId(), 11, 0, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 3,  0, 0, 0)
        SetPedComponentVariation(PlayerPedId(), 8,  14, 0, 0)
      end
    end
    
  elseif data.action == "hairStyle" then
    local i    = GetPedDrawableVariation(PlayerPedId(), 2)
    local iMax = GetNumberOfPedDrawableVariations(PlayerPedId(), 2)
    
    if data.direction == 1 then i = i + 1
    else i = i - 1
    end
    
    if i < 0 then i = iMax
    elseif i > iMax then i = 0
    end
    
    if GetEntityModel(PlayerPedId()) == maleHash then 
      if i == 23 then -- Ignore night vision goggle hairpiece
        if data.direction == 1 then i = 24
        else i = 22
        end
      end
    else
      if i == 24 then -- Ignore night vision goggle hairpiece
        if data.direction == 1 then i = 25
        else i = 23
        end
      end
    end
    
    SetPedComponentVariation(PlayerPedId(), 2, i, 0, 0)
    DesignerCamera(0.0, 1.6, 0.32, 0.0, 0.0, 0.0, 50.0)
    
  elseif data.action == "hairColor" then
    local i = GetPedHairColor(PlayerPedId())
    
    if data.direction == 1 then i = i + 1
    else i = i - 1
    end
    
    if     i > 63 then i =  0
    elseif i <  0 then i = 63
    end
    
    SetPedHairColor(PlayerPedId(), i, GetPedHairHighlightColor(PlayerPedId()))
    DesignerCamera(0.0, 1.6, 0.32, 0.0, 0.0, 0.0, 50.0)
    
  elseif data.action == "hairHighlight" then
    local i = GetPedHairHighlightColor(PlayerPedId())
    
    if data.direction == 1 then i = i + 1
    else i = i - 1
    end
    
    if     i > 63 then i =  0
    elseif i <  0 then i = 63
    end
    
    SetPedHairColor(PlayerPedId(), GetPedHairColor(PlayerPedId()), i)
    DesignerCamera(0.0, 1.6, 0.32, 0.0, 0.0, 0.0, 50.0)
    
  
  elseif data.action == "eyeColor" then
    local i = GetPedEyeColor(PlayerPedId())
    
    if data.direction == 1 then i = i + 1
    else i = i - 1
    end
    
    if     i > 8 then i = 0
    elseif i < 0 then i = 8
    end
    
    SetPedEyeColor(PlayerPedId(), i)
    DesignerCamera(0.0, 1.6, 0.32, 0.0, 0.0, 0.0, 50.0)
  
  end
end)


RegisterNUICallback("facialFeatures", function(data, cb)
  if data.action == "setFeature" then
    SetPedFaceFeature(PlayerPedId(), (data.fNum), (data.sVal)/100)
    DesignerCamera(0.0, 0.8, 0.24, 0.0, 0.0, 0.0, 50.0)
  end
end)


RegisterNUICallback("clothingOptions", function(data, cb)
  if data.action == "setOutfit" then
    local pModel = GetEntityModel(PlayerPedId())
    if (data.sex == 0 and pModel == maleHash)   or 
       (data.sex == 1 and pModel == femaleHash) then
      for k,v in pairs (defaultOutfits[pModel][data.cNum]) do
        SetPedComponentVariation(PlayerPedId(), v.slot, v.draw, v.text, 2)
      end
      if pModel == femaleHash then
        SetPedComponentVariation(PlayerPedId(), 8, 14, 0, 2)
      else
        SetPedComponentVariation(PlayerPedId(), 8, 15, 0, 2)
      end
    end
    DesignerCamera(0.0, 0.0, -0.15, 0.0, 0.0, 0.0, 50.0)
  end
end)


RegisterNUICallback("finishPlayer", function(data, cb)
  if data == "apply" then 
    local ped = PlayerPedId()
    DesignerCamera(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 50.0)
    
    local eyeColor = GetPedEyeColor(ped)
    local myModel  = "mp_m_freemode_01"
    if GetEntityModel(ped) == femaleHash then 
      myModel = "mp_f_freemode_01"
    end
    
    local overlays = {
      {["slot"] = 0,  ["index"] = GetPedHeadOverlayValue(ped, 0)},
      {["slot"] = 3,  ["index"] = GetPedHeadOverlayValue(ped, 3)},
      {["slot"] = 7,  ["index"] = GetPedHeadOverlayValue(ped, 7)},
      {["slot"] = 9,  ["index"] = GetPedHeadOverlayValue(ped, 8)},
      {["slot"] = 11, ["index"] = GetPedHeadOverlayValue(ped, 11)},
    }
    
    local tempOverlays = {
      {["slot"] = 2,  ["index"] = GetPedHeadOverlayValue(ped, 2)},
      {["slot"] = 10, ["index"] = GetPedHeadOverlayValue(ped, 10)},
    }
    
    local startOutfit = {
      {slot = 3,
        draw = GetPedDrawableVariation(ped,3),
        text = GetPedTextureVariation(ped,3)},
      {slot = 4,
        draw = GetPedDrawableVariation(ped,4),
        text = GetPedTextureVariation(ped,4)},
      {slot = 6,
        draw = GetPedDrawableVariation(ped,6),
        text = GetPedTextureVariation(ped,6)},
      {slot = 8,
        draw = GetPedDrawableVariation(ped,8),
        text = GetPedTextureVariation(ped,8)},
      {slot = 11,
        draw = GetPedDrawableVariation(ped,11),
        text = GetPedTextureVariation(ped,11)},
    }
    
    local feats = {}
    for i = 0, 14 do feats[i] = GetPedFaceFeature(ped, i)
    end
    
    local jsonParents = json.encode({
      [1] = myParents[1],  [2] = myParents[2],
      [3] = (100 - mySimilar)/100, [4] = mySimilar/100
    })
    
    local jsonHair = json.encode({
      ["draw"]  = GetPedDrawableVariation(ped, 2),
      ["text"]  = GetPedTextureVariation(ped, 2),
      ["color"] = GetPedHairColor(ped),
      ["light"] = GetPedHairHighlightColor(ped)
    })
    
    TriggerServerEvent('cnr:create_save_character',
      jsonParents, eyeColor, jsonHair,
      json.encode(overlays), json.encode(tempOverlays),
      json.encode(feats), myModel, json.encode(startOutfit)
    )
  
  elseif data == "reset" then 
    
    SetPedDefaultComponentVariation(PlayerPedId())
    SetPedHairColor(PlayerPedId(), 0, 0)
    SetPedEyeColor(PlayerPedId(), 0)
    
    for i = 0, 12 do
      SetPedHeadOverlay(PlayerPedId(), i, 0, 1.0)
      SetPedHeadOverlayColor(PlayerPedId(), i, 1, 1, 1)
    end
    for i = 0, 14 do SetPedFaceFeature(PlayerPedId(), i, 0.5)
    end
    
    myParents = {[1] = 1, [2] = 21}
    mySimilar = 50
    ModifyParents(1, 21, 50)
    DesignerCamera(0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 50.0)
  
  end
end)




--- EVENT: changelog
-- Creates a new player for newbies or if character was wiped/lost
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
  end
  --table.insert(msgInfo, '</ul>')
  SendNUIMessage({showwelcome = true, motd = table.concat(msgInfo)})
  SetNuiFocus(true, true)
end)



