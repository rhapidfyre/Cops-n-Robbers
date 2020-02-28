
--[[
  Cops and Robbers: Death Scripts (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  08/26/2019

  Handles all death events, and life saving/resurrection type scripting.
--]]
RegisterNetEvent('cnr:death_insurance')
RegisterNetEvent('cnr:police_imprison')
RegisterNetEvent('cnr:prison_release')
RegisterNetEvent('cnr:prison_rejail')

local locksound = false
local inPrison  = 0
local hNear     = 0
local hasInsurance = false
local passiveMode = false

local hospitals = {
  [1] = {
    coords      = vector3(-497.55, -335.841, 34.51),
    deathcam    = vector3(-465.31, -373.534, 39.05),
    insure      = vector3(-493.62, -325.66, 33.40),
    pedHeading  = 266.0, camHeading = 20.0,
    jailHospital = 0,
    title       = "Mount Zonah Medical Center"
  },
  [2] = {
    coords      = vector3(295.424, -1447.42, 29.97),
    deathcam    = vector3(273.746, -1395.03, 34.51),
    insure      = vector3(306.268, -1433.35, 28.97),
    pedHeading  = 320.0, camHeading = 190.0,
    jailHospital = 0,
    title       = "UC Los Santos"
  },
  [3] = {
    coords      = vector3(-247.909, 6332.7, 32.4262),
    deathcam    = vector3(-217.081, 6317.74, 35.891),
    insure      = vector3(-243.758, 6325.6, 31.32),
    pedHeading  = 222.0, camHeading = 86.0,
    jailHospital = 0,
    title       = "Paleto Bay Medical Center"
  },
  [4] = {
    coords      = vector3(1839.26, 3672.99, 34.276),
    deathcam    = vector3(1841.92, 3646.32, 37.151),
    insure      = vector3(1835.78, 3671.58, 34.28),
    pedHeading  = 210.0, camHeading = 0.0,
    jailHospital = 0,
    title       = "Sandy Shores Care Facility"
  },
  [5] = {
    coords      = vector3(359.99, -585.134, 28.82),
    deathcam    = vector3(391.35, -571.819, 31.5),
    insure      = vector3(361.28, -580.45, 27.73),
    pedHeading  = 230.0, camHeading = 125.0,
    jailHospital = 0,
    title       = "Pillbox Medical Center"
  },
  [6] = {
    coords      = vector3(1662.25, 2592.99, 45.56),
    deathcam    = vector3(1642.71, 2605.39, 48.68),
    pedHeading  = 82.0, camHeading = 220.0,
    jailHospital = 2,
    title       = "Bolingbroke Medical Center"
  },
  [7] = {
    coords      = vector3(460.97, -1001.05, 24.91),
    deathcam    = vector3(465.12, -1002.69, 25.91),
    pedHeading  = 272.0, camHeading = 66.0,
    jailHospital = 1,
    title       = "Mission Row Medical Bay"
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
  while true do 
    if hNear > 0 then
      local iPos = hospitals[hNear].insure
      DrawMarker(1, iPos.x, iPos.y, iPos.z,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        1.25, 1.25, 0.65, 255, 255, 255, 120,
        false, false, 0, false
      )
      DrawMarker(29, iPos.x, iPos.y, iPos.z + 1.3,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        1.25, 1.25, 0.65, 255, 65, 65, 255,
        false, false, 0, true
      )
      if #(GetEntityCoords(PlayerPedId()) - iPos) < 3.25 then
        if not hasInsurance then
          ClearPrints()
          SetTextEntry_2("STRING")
          AddTextComponentString("[~g~E~w~]: Buy Insurance ($25,000)")
          DrawSubtitleTimed(count, 1)
          if IsControlJustPressed(0, 38) then 
            TriggerServerEvent('cnr:death_buy_insurance')
            Citizen.Wait(3000)
          end
        else
          ClearPrints()
          SetTextEntry_2("STRING")
          AddTextComponentString("~r~You already have Health Insurance")
          DrawSubtitleTimed(count, 1)
        end
      end
    else Citizen.Wait(3000)
    end
    
    local cDist = math.huge
    for k,v in pairs (hospitals) do 
      if v.insure then
        local dist = #(GetEntityCoords(PlayerPedId()) - v.insure)
        if dist < cDist and dist < 40.0 then hNear = k end
      end
    end
    Citizen.Wait(0)
  end
end)

local notified = false
local function DeathNotification()
  if not notified then
    notified = true
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
    Citizen.Wait(2000)
    TriggerEvent('cnr:player_died')
    TriggerServerEvent('cnr:player_death')
    Citizen.Wait(3000)
    notified = false
  end
end
Citizen.CreateThread(function()
   while true do
       Citizen.Wait(0)
       if IsPlayerDead(PlayerId()) then
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
  passiveMode = false -- Just to ensure the previous loop has stopped
  Citizen.Wait(5400)
  if IsPlayerDead(PlayerId()) then
  
    DoScreenFadeOut(1200)
  
    while not IsScreenFadedOut() do Wait(100) end
    
    
    local myPos   = GetEntityCoords(PlayerPedId())
    local nearest = 1
    local cDist   = math.huge
    
    -- Return closest hospital OR jail/prison hospital
    for k,v in pairs (hospitals) do
      if v.jailHospital == isPrison then
        local dist = #(myPos - v.coords)
        if dist < cDist then nearest = k; cDist = dist end
      end
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
    
    Citizen.CreateThread(function()
      passiveMode = true 
      TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
        "You are ^2now in Passive Mode^7. You are safe from PVP unless you "..
        "go on police duty, select a weapon, commit a crime, or 5 minutes have passed."
      }})
      local unarm = GetHashKey("WEAPON_UNARMED")
      SetPedCurrentWeapon(PlayerPedId(), unarm, true)
      local passTime = GetGameTimer() + 300000
      while passiveMode do 
        local wLevel = exports['cnr_wanted']:WantedLevel()
        if wLevel > 0 then
          passiveMode = false
          print("Passive mode has been disabled: Committed a Criminal Offense.")
        elseif exports['cnr_police']:DutyStatus() then
          passiveMode = false
          print("Passive mode has been disabled: Went on Police Duty.")
        elseif GetSelectedPedWeapon(PlayerPedId()) ~= unarmed then
          passiveMode = false
          print("Passive mode has been disabled: Selected a Weapon.")
        elseif passTime < GetGameTimer() then 
          passiveMode = false
          print("Passive mode has been disabled: 5 Minutes has Passed.")
        end
        Citizen.Wait(100)
      end
      TriggerServerEvent('cnr:death_nonpassive')
      TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
        "You are ^1no longer in Passive Mode^7. You cannow be killed by other players."
      }})
    end)
      
    Citizen.Wait(1000)
    DoScreenFadeIn(3000)
    Citizen.Wait(2000)
    RenderScriptCams(false, true, 500, false, false)
    Citizen.Wait(520)
    FreezeEntityPosition(PlayerPedId(), false)
    SetCamActive(cam, false)
    
    -- If still wanted, report it to 911
    if exports['cnr_wanted']:WantedLevel() > 3 then
      TriggerServerEvent('cnr:police_dispatch_report',
        "Wanted Person",
        hospitals[nearest].title,
        GetEntityCoords(PlayerPedId()),
        hospitals[nearest].title.." Security reported a Level "..wl..
        " Wanted Person was just released from their care."
      )
    end
  
  end
end



AddEventHandler('cnr:death_insurance', function(insuranceValue)

  local wl = exports['cnr_wanted']:WantedLevel()
  if not insuranceValue then insuranceValue = 0 end
  if insuranceValue > 0 then 
  
    if insuranceValue == 2 then
      TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
        "Since you died in police custody, your personal items have been saved."
      }})
      
    else
      TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
        "Your insurance prevented you from losing your personal items!\n"..
        "You will have to renew your health insurance before dying again."
      }})
      
    end
  
  else
  
    RemoveAllPedWeapons(PlayerPedId(), true)
    TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
      "You died without health insurance! Welcome to your new life!"
    }})
    
    if wl > 0 then
      TriggerServerEvent('cnr:wanted_points', "jailed")
      
    end
  
  end
  hasInsurance = false
end)


RegisterNetEvent('cnr:death_has_insurance', function()
  print("DEBUG - You have insurance!")
  hasInsurance = true
end)

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

AddEventHandler('cnr:police_imprison', function(serveTime, isPrisoner)
  if isPrisoner then isPrison = 2
  else isPrison = 1 end
end)

AddEventHandler('cnr:prison_rejail', function(serveTime, isPrisoner)
  if isPrisoner then isPrison = 2
  else isPrison = 1 end
end)

AddEventHandler('cnr:prison_release', function(serveTime, isPrisoner)
  isPrison = 0
end)