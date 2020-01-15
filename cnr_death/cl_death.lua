
--[[
  Cops and Robbers: Death Scripts (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  08/26/2019

  Handles all death events, and life saving/resurrection type scripting.
--]]
local locksound = false

local hospitals = {
  [1] = {
    coords = vector3(-454.50, -340.47, 33.00),
    title = "Mount Zonah Medical Center"
  },
  [2] = {
    deathcam = vector3(273.746, -1395.03, 34.5),
    coords = vector3(295.424, -1447.42, 29.97),
    pedHeading = 320.0, camHeading = 190.0,
    title = "UC Los Santos"
  },
  [3] = {
    title = "26th Medical Group",
    coords = vector3(-2078.28, 2811.46, 31.28)
  },
  [4] = {
    title = "Paleto Bay Medical Center",
    coords = vector3(-227.53, 6322.26, 30.15)
  },
  [5] = {
    title = "Sandy Shores Care Facility",
    coords = vector3(1827.15, 3693.88, 31.90)
  },
  [6] = {
    title = "Pillbox Medical Center",
    coords = vector3(360.7, -597.94, 27.10)
  },
}

Citizen.CreateThread(function()
   while true do
       Citizen.Wait(0)      
       if IsPlayerDead(PlayerId()) then 
         StartScreenEffect("DeathFailOut", 0, 0)
         if not locksound then
           PlaySoundFrontend(-1, "Bed", "WastedSounds", 1)
           locksound = true
         end
         ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)
         
         local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")
  
         if HasScaleformMovieLoaded(scaleform) then
           Citizen.Wait(0)
  
           PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
           BeginTextComponent("STRING")
           AddTextComponentString("~r~wasted")
           EndTextComponent()
           PopScaleformMovieFunctionVoid()
  
           Citizen.Wait(500)
  
           PlaySoundFrontend(-1, "TextHit", "WastedSounds", 1)
           Citizen.CreateThread(RevivePlayer)
           TriggerEvent('cnr:client_death')
           while IsPlayerDead(PlayerId()) do
             DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
             HideHudAndRadarThisFrame(true)
             Citizen.Wait(0)
           end
         
           StopScreenEffect("DeathFailOut")
           locksound = false
          end
       end
    end
end)

function RevivePlayer()
  Citizen.Wait(8000)
  if IsPlayerDead(PlayerId()) then 
    DoScreenFadeOut(1200)
    while not IsScreenFadedOut() do Wait(100) end
    local myPos   = GetEntityCoords(PlayerPedId())
    local nearest = 1
    local cDist   = math.huge
    for k,v in pairs (hospitals) do 
      local dist = #(myPos - v.coords)
      if dist < cDist then nearest = k; cDist = dist end
    end
    
    if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
    SetCamParams(cam, hospitals[nearest].deathcam, 0.0, 0.0, hospitals[nearest].camHeading, 50.0)
    RenderScriptCams(true, true, 500, true, true)
    SetCamActive(cam, true)

    NetworkResurrectLocalPlayer(
     hospitals[nearest].coords, 0.0, false, false
    )
    SetEntityHeading(PlayerPedId(), hospitals[nearest].pedHeading)
    FreezeEntityPosition(PlayerPedId(), true)
    Citizen.Wait(1000)
    DoScreenFadeIn(3000)
    Citizen.Wait(2000)
    RenderScriptCams(false, true, 500, false, false)
    Citizen.Wait(520)
    FreezeEntityPosition(PlayerPedId(), false)
    SetCamActive(cam, false)
    
  end
end