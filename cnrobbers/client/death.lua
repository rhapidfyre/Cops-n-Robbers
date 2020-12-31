
RegisterNetEvent('cnr:police_imprison')
RegisterNetEvent('cnr:player_respawn')
RegisterNetEvent('cnr:prison_release')
RegisterNetEvent('cnr:prison_rejail')
RegisterNetEvent('cnr:death_notify')

local locksound     = false
local hNear         = 0
local hasInsurance  = false
local passiveMode   = false
local notified      = false
local doingRevive   = false
local fadeTime      = 4200

local function deathNotify(Notification)
	SetNotificationTextEntry('STRING')
	AddTextComponentString(Notification)
	DrawNotification(false, false)
end


Citizen.CreateThread(function()

  -- Add hospital blips
  for _,v in pairs(hospitals) do
    if v.jailHospital then
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
    local cDist = #(myPos - hospitals[1].coords)
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


-- Sends killer information to server and triggers death events
local function DeathNotification()
  if not notified then

    TriggerEvent('cnr:player_died')
    TriggerServerEvent('cnr:player_death')

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

  end
end


-- Runs the traditional "WASTED" screen
local function DeathFX()

  local fadeOut = GetGameTimer() + fadeTime

	StartScreenEffect("DeathFailOut", 0, 0)
	if not locksound then
    PlaySoundFrontend(-1, "Bed", "WastedSounds", 1)
	  locksound = true
	end
	ShakeGameplayCam("DEATH_FAIL_IN_EFFECT_SHAKE", 1.0)

	local scaleform = RequestScaleformMovie("MP_BIG_MESSAGE_FREEMODE")

	if HasScaleformMovieLoaded(scaleform) then
		Wait(0)

    PushScaleformMovieFunction(scaleform, "SHOW_SHARD_WASTED_MP_MESSAGE")
    BeginTextComponent("STRING")
    AddTextComponentString("~r~wasted")
    EndTextComponent()
    PopScaleformMovieFunctionVoid()

	  Wait(500)

    PlaySoundFrontend(-1, "TextHit", "WastedSounds", 1)
    while IsEntityDead(PlayerPedId()) and fadeOut > GetGameTimer() do
      DrawScaleformMovieFullscreen(scaleform, 255, 255, 255, 255)
      Wait(0)
    end

  end

  StopScreenEffect("DeathFailOut")
  locksound = false

end


function CheckForDeath()
  if not CNR.dead then
    if IsPlayerDead(PlayerId()) or IsPedDeadOrDying(PlayerPedId()) then
      CNR.dead = GetGameTimer() + 6200
      CreateThread(DeathFX)
      CreateThread(DeathNotification)
    end
  else
    if CNR.dead < GetGameTimer() then
      -- Do not thread
      RevivePlayer()
    end
  end
end


function RevivePlayer()

  print("DEBUG - Fading Screen.")
  DoScreenFadeOut(1200)
  Wait(1300)
  print("DEBUG - Screen Faded.")

  local ped = PlayerPedId()
  local hNumber = 1
  
  local plyPos = GetEntityCoords(ped)
  local cDist = #(plyPos - hospitals[1].coords)
  for i = 2, #hospitals do 
    local dist = #(plyPos - hospitals[i].coords)
    if dist < cDist then
      cDist = dist; hospitalNumber = i
    end
  end
  
  -- Ensure dead inmates always go back to jail
  if CNR.isPrisoner then hNumber = 6 end

  print("DEBUG - Spawning @ hospital #"..hNumber.." ("..hospitals[hNumber].title..")")
  if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
  SetCamParams(cam, hospitals[hNumber].deathcam, 0.0, 0.0, hospitals[hNumber].camHeading, 50.0)
  RenderScriptCams(true, true, 500, true, true)
  SetCamActive(cam, true)

  local ped = PlayerPedId()
  NetworkResurrectLocalPlayer(GetEntityCoords(ped), 0.0, false, false)
  SetEntityCoords(ped, hospitals[hNumber].coords)
  SetEntityHeading(ped, pedHeading)

  -- Activate Passive Mode
  -- Threaded to ensure player stays in passive mode while the main game driver runs
  --CNR.PassiveMode(true)

  notified = false
  Citizen.Wait(1000)
  CNR.dead = nil
  DoScreenFadeIn(3000)
  Citizen.Wait(5000)
  RenderScriptCams(false, true, 500, false, false)
  Citizen.Wait(520)
  SetCamActive(cam, false)
  Citizen.Wait(100)

  -- Fire off respawn events after this script has finished
  print("DEBUG - Respawn Complete. Firing 'cnr:respawned'")
  TriggerEvent('cnr:respawned', hNumber)
  TriggerServerEvent('cnr:respawned', hNumber)

end


AddEventHandler('cnr:death_notify', function(v, k)
  local myid = PlayerId()
  local victim = GetPlayerFromServerId(v)
  local killer = GetPlayerFromServerId(k)

  if not killer then
    deathNotify(GetPlayerName(victim).." died")
    return 0
  end

  -- This client DIED
  if myid == victim then
    if victim == killer then
      deathNotify("You committed suicide")
    else
      deathNotify(GetPlayerName(killer).." killed you")
    end

  -- This client KILLED
  elseif myid == killer then
    deathNotify("You killed "..GetPlayerName(victim))

  -- Someone killed somebody
  else
    deathNotify(GetPlayerName(killer).." killed "..GetPlayerName(victim))

  end

end)

