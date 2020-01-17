
--[[
  Cops and Robbers: Death Scripts (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  08/26/2019

  Handles all death events, and life saving/resurrection type scripting.
--]]
local locksound = false

local hospitals = {
  [1] = {
    coords      = vector3(-497.55, -335.841, 34.51),
    deathcam    = vector3(-465.31, -373.534, 39.05),
    pedHeading  = 266.0, camHeading = 20.0,
    title       = "Mount Zonah Medical Center"
  },
  [2] = {
    coords      = vector3(295.424, -1447.42, 29.97),
    deathcam    = vector3(273.746, -1395.03, 34.51),
    pedHeading  = 320.0, camHeading = 190.0,
    title       = "UC Los Santos"
  },
  [3] = {
    coords      = vector3(-247.909, 6332.7, 32.4262),
    deathcam    = vector3(-217.081, 6317.74, 35.891),
    pedHeading  = 222.0, camHeading = 86.0,
    title       = "Paleto Bay Medical Center"
  },
  [4] = {
    coords      = vector3(1839.26, 3672.99, 34.276),
    deathcam    = vector3(1841.92, 3646.32, 37.151),
    pedHeading  = 210.0, camHeading = 0.0,
    title       = "Sandy Shores Care Facility"
  },
  [5] = {
    coords      = vector3(359.99, -585.134, 28.82),
    deathcam    = vector3(391.35, -571.819, 31.5),
    pedHeading  = 230.0, camHeading = 125.0,
    title       = "Pillbox Medical Center"
  },
}

-- Add Hospital Blips
Citizen.CreateThread(function()
  for _,v in pairs(hospitals) do
    local blip = AddBlipForCoord(v.coords)
    SetBlipSprite(blip, 61)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Hospital")
    EndTextCommandSetBlipName(blip)
    Citizen.Wait(1)
  end
end)

local function DeathNotification()
  --[[
  local killer, killerweapon = NetworkGetEntityKillerOfPlayer(PlayerId())
  local killerentitytype     = GetEntityType(killer)
  local killerinvehicle      = false
  local killervehiclename    = ''
  local killervehicleseat    = 0
  
  local killerid             = GetPlayerServerId(killer)
  
  print("DEBUG - killer ("..tostring(killer)..")")
  print("DEBUG - killerid ("..tostring(killerid)..")")
  print("DEBUG - killerentitytype ("..tostring(killerentitytype)..")")
  print("DEBUG - GetPedCauseOfDeath("..tostring(GetPedCauseOfDeath(PlayerPedId()))..")")
  
  local kInfo = {
    weapon    = killerweapon,
    idKiller  = killerid,
    entType   = killerentitytype,
    causation = GetPedCauseOfDeath(PlayerPedId())
  }
  
  -- Is this client a cop? If so, modify the 911 call
  if exports['cnr_police']:DutyStatus() then
  
  -- If this client isn't a cop
  else
    if killerid then
      if killerid > 0 then
        TriggerServerEvent('cnr:death_check', killerid)
      end
    end
  end]]
  local cause  = GetPedCauseOfDeath(PlayerPedId())
  local killer = GetPedSourceOfDeath(PlayerPedId())
  print(cause, killer) 
  if DoesEntityExist(killer) then
    if IsEntityAPed(killer) then
      if IsPedAPlayer(killer) then 
        if PlayerPedId() == killer then
          print("DEBUG - You killed yourself!")
          TriggerServerEvent('cnr:death_check', GetPlayerServerId(PlayerId()))
        else
          print("DEBUG - Killed by Player!")
          local plys = GetActivePlayers()
          for _,i in ipairs (plys) do 
            if GetPlayerPed(i) == killer then 
              print("DEBUG - Killed by player #"..GetPlayerServerId(i))
              TriggerServerEvent('cnr:death_check', GetPlayerServerId(i))
            end
          end
        end
      else print("DEBUG - Killed by an NPC!")
      end
    elseif IsEntityAVehicle(killer) then
      local driver = GetPedInVehicleSeat(killer, (-1))
      if DoesEntityExist(driver) then 
        if IsEntityAPed(driver) then 
          if IsPedAPlayer(driver) then 
            print("DEBUG - Killed by Player!")
            local plys = GetActivePlayers()
            for _,i in ipairs (plys) do 
              if GetPlayerPed(i) == driver then 
                print("DEBUG - Ran over by player #"..GetPlayerServerId(i))
                TriggerServerEvent('cnr:death_check', GetPlayerServerId(i))
              end
            end
          else
            print("DEBUG - Ran down by an aggressive NPC driver!")
            TriggerServerEvent('cnr:death_check', nil)
          end
        else
          print("DEBUG - Ran down by a vehicle with no ped driving!")
          TriggerServerEvent('cnr:death_check', nil)
        end
      else
        print("DEBUG - Ran down by a vehicle with no driver!")
        TriggerServerEvent('cnr:death_check', nil)
      end
    else
      print("DEBUG - Killed by something else!")
      TriggerServerEvent('cnr:death_check', nil)
    end
  end
end

local plyDead = false
Citizen.CreateThread(function()
   while true do
       Citizen.Wait(0)
       if IsPlayerDead(PlayerId()) and not plyDead then
         plyDead = true
         Citizen.CreateThread(RevivePlayer)
         Citizen.CreateThread(DeathNotification)
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
           TriggerEvent('cnr:player_died')
           TriggerServerEvent('cnr:player_death')
           Citizen.CreateThread(function()
            while IsPlayerDead(PlayerId()) do
              DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
              HideHudAndRadarThisFrame(true)
              Citizen.Wait(0)
            end
            plyDead = false
           end)
           StopScreenEffect("DeathFailOut")
           locksound = false
         end
          
       end
    end
end)

function RevivePlayer()
  Citizen.Wait(5800)
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
    
    local wl = exports['cnr_wanted']:WantedLevel()
    if wl > 0 then 
      TriggerServerEvent('cnr:police_dispatch_report',
        "Wanted Person",
        hospitals[nearest].title,
        GetEntityCoords(PlayerPedId()),
        "Security reported a Level "..wl.." Wanted Person was just released from their care."
      )
    end
    
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






RegisterNetEvent('cnr:death_notify')
AddEventHandler('cnr:death_notify', function(v, k)
  local myid = PlayerId()
  local victim = GetPlayerFromServerId(v)
  local killer = GetPlayerFromServerId(k)
  
  print(v, k, victim, killer) 
  
  if not killer then 
    drawNotification(GetPlayerName(victim).." died")
    return 0
  end
  
  -- This client DIED
  if myid == victim then 
    if victim == killer then 
      drawNotification("You committed suicide")
    else
      drawNotification(GetPlayerName(killer).." killed you")
    end
  
  -- This client KILLED
  elseif myid == killer then
    drawNotification("You killed "..GetPlayerName(victim))
  
  -- Someone killed somebody
  else
    drawNotification(GetPlayerName(killer).." killed "..GetPlayerName(victim))
  
  end
  
end)

function drawNotification(Notification)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(Notification)
	DrawNotification(false, false)
end




