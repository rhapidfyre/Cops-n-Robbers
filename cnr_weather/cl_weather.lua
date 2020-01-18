

-- Heavily edited version of `vSync`
RegisterNetEvent('cnr:weather_update')
RegisterNetEvent('cnr:weather_time')


wxCurrent = 'EXTRASUNNY'
local wxPrevious = wxCurrent
local bTime      = 0
local timeOffset = 0
local timer      = 0


AddEventHandler('cnr:weather_update', function(wxNew)
  wxCurrent = wxNew
end)


Citizen.CreateThread(function()
  while true do
    if wxPrevious ~= wxCurrent then
      wxPrevious = wxCurrent
      SetWeatherTypeOverTime(wxCurrent, 15.0)
      Citizen.Wait(15000)
    end
    Citizen.Wait(100) -- Wait 0 seconds to prevent crashing.
    ClearOverrideWeather()
    ClearWeatherTypePersist()
    SetWeatherTypePersist(wxPrevious)
    SetWeatherTypeNow(wxPrevious)
    SetWeatherTypeNowPersist(wxPrevious)
    if wxPrevious == 'XMAS' then
      SetForceVehicleTrails(true)
      SetForcePedFootstepsTracks(true)
    else
      SetForceVehicleTrails(false)
      SetForcePedFootstepsTracks(false)
    end
  end
end)


AddEventHandler('cnr:weather_time', function(base, offset)
  timeOffset = offset; bTime = base
end)


Citizen.CreateThread(function()
  local hour = 0
  local minute = 0
  while true do
    Citizen.Wait(0)
    local newtime = bTime
    if GetGameTimer() - 500  > timer then
      newtime = newtime + 0.25
      timer = GetGameTimer()
    end
    bTime  = newtime
    hour   = math.floor(((bTime+timeOffset)/60)%24)
    minute = math.floor((bTime+timeOffset)%60)
    NetworkOverrideClockTime(hour, minute, 0)
  end
end)


AddEventHandler('playerSpawned', function()
  TriggerServerEvent('cnr:weather_sync')
end)

