
RegisterNetEvent('cnr:police_imprison')
RegisterNetEvent('cnr:prison_release')
RegisterNetEvent('cnr:prison_rejail')

local locksound = false
--local inPrison  = 0
local hNear     = 0
local hasInsurance = false
local passiveMode = false
local notified = false


Citizen.CreateThread(function()

  -- Add hospital blips
  for _,v in pairs(hospitals) do
    if v.jailHospital < 1 then
      local blip = AddBlipForCoord(v.coords)
      SetBlipSprite(blip, 61)
      SetBlipDisplay(blip, 2)
      SetBlipScale(blip, 0.82)
      SetBlipColour(blip, 0)
      SetBlipAsShortRange(blip, true)
      BeginTextCommandSetBlipName("STRING")
      AddTextComponentString("Hospital")
      EndTextCommandSetBlipName(blip)
    end
  end
  
  -- Track hospital information (if one is nearby)
  while true do
    if hNear > 0 then
    
      -- Can only buy insurance at non-jail hospitals
      if not hospitals[hNear].jailHospital then
        local iPos = hospitals[hNear].insure
        DrawMarker(1, iPos.x, iPos.y, iPos.z,
          0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
          2.25, 2.25, 0.65, 255, 255, 255, 120,
          false, false, 0, false
        )
        DrawMarker(29, iPos.x, iPos.y, iPos.z + 1.3,
          0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
          1.2, 1.2, 1.2, 255, 65, 65, 255,
          false, false, 0, true
        )
        if #(GetEntityCoords(PlayerPedId()) - iPos) < 2.25 then
          ClearPrints()
          SetTextEntry_2("STRING")
          AddTextComponentString("[~g~E~w~]: Buy Insurance ($25,000)")
          DrawSubtitleTimed(1, 1)
          if IsControlJustPressed(0, 38) then
            TriggerServerEvent('cnr:death_buy_insurance')
            Citizen.Wait(1000)
          end
        end
      end
      
    end
    Citizen.Wait(1)
  end
  
end)


-- Tracks nearest hospital
Citizen.CreateThread(function()
  while true do
    local nearestHospital = 1
    local myPos = GetEntityCoords(PlayerPedId())
    local cDist = #(myPos - hospitals[i].coords)
    for i = 2, #hospitals do
      if hospitals[i].insure then
        local dist = #(myPos - hospitals[i].coords)
        if dist < cDist then
          cDist = dist; nearestHospital = i 
        end
      end
    end
    hNear = nearestHospital
    Citizen.Wait(100)
  end
end)


local function DeathNotification()
  if not notified then
    notified = true
    local cause  = GetPedCauseOfDeath(PlayerPedId())
    local killer = GetPedSourceOfDeath(PlayerPedId())
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
    TriggerEvent('cnr:player_died')
    TriggerServerEvent('cnr:player_death')
    
    -- Prevent repeat checks/messages per death
    Citizen.Wait(5000)
    notified = false
    
  end
end


Citizen.CreateThread(function()
  while not CNR do Wait(100) end
  while true do
    Citizen.Wait(0)
    if CNR.loaded then
      if not CNR.dead then
        if IsPlayerDead(PlayerId()) or IsPedDeadOrDying(PlayerPedId()) then
          CNR.dead = true
        end
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
  end
end)

local doingRevive = false
function RevivePlayer()
  if doingRevive then return 0 end
  doingRevive = true
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
      if Imprisoned() then
      if v.jailHospital then
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
        "^3PASSIVE MODE: ^2Enabled. You are invincible for 5 minutes unless you "..
        "go on police duty, select a weapon, or commit a crime."
      }})
      local unarm = GetHashKey("WEAPON_UNARMED")
      SetCurrentPedWeapon(PlayerPedId(), unarm, true)
      local passTime = GetGameTimer() + 300000
      Citizen.CreateThread(function()
        while passiveMode do
          SetPlayerInvincible(PlayerId(), true)
          Citizen.Wait(0)
        end
        SetPlayerInvincible(PlayerId(), false)
      end)
      while passiveMode do
        local wLevel = WantedLevel()
        if wLevel > 0 then
          passiveMode = false
          print("Passive mode has been disabled: Committed a Criminal Offense.")
        elseif DutyStatus() then
          passiveMode = false
          print("Passive mode has been disabled: Went on Police Duty.")
        elseif GetSelectedPedWeapon(PlayerPedId()) ~= unarm then
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
        "^3PASSIVE MODE: ^1Disabled. You cannow be killed by other players."
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
    if WantedLevel() > 3 then
      TriggerServerEvent('cnr:police_dispatch_report',
        "Wanted Person",
        hospitals[nearest].title,
        GetEntityCoords(PlayerPedId()),
        hospitals[nearest].title.." Security reported a Level "..wl..
        " Wanted Person was just released from their care."
      )
    end
    
    Citizen.Wait(1000)
    TriggerEvent('cnr:death_respawn', hospitals[nearest].title)
    TriggerServerEvent('cnr:death_respawn', hospitals[nearest].title)
    
  end
  doingRevive = false
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