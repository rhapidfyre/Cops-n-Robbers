
-- Set this to false if you don't want the weather to change automatically every 10 minutes.
local wxDynamic = true

local wxTypes = {
  'EXTRASUNNY', 'CLEAR', 'NEUTRAL', 'SMOG', 
  'FOGGY', 'OVERCAST', 'CLOUDS', 'CLEARING', 
  'RAIN', 'THUNDER', 'SNOW', 'BLIZZARD', 
  'SNOWLIGHT', 'XMAS', 'HALLOWEEN',
}

local wxCurrent = "EXTRASUNNY"
local bTime = 0
local timeOffset = 0
local wxNewTimer = 10

RegisterServerEvent('cnr:weather_sync')
AddEventHandler('cnr:weather_sync', function()
  TriggerClientEvent('cnr:weather_update', -1, wxCurrent)
  TriggerClientEvent('cnr:weather_time', -1, bTime, timeOffset)
end)

function IsAdmin(client)
  local aLevel, aid = exports['cnr_admin']:AdminLevel(client)
  return aid
end

--- EXPORT: GetWeather()
-- Returns what the current weather is supposed to be set to
function GetWeather()
  return wxCurrent
end

RegisterCommand('weather', function(source, args)
  local client = source
  if client == 0 then
    local wxValid = false
    if args[1] == nil then
      print("Invalid syntax, correct syntax is: /weather <weathertype> ")
      return
    else
      for i,wtype in ipairs(wxTypes) do
        if wtype == string.upper(args[1]) then
          wxValid = true
        end
      end
      if wxValid then
        print("CNR WEATHER: Changing the weather to: "..wxCurrent)
        wxCurrent = string.upper(args[1])
        wxNewTimer = 10
        TriggerEvent('cnr:weather_sync')
      else
        local wxs = ""
        for _,i in ipairs (wxTypes) do wxs = wxs..v.." " end
        print("CNR WEATHER: Improper weather type. Please use one of these:\n "..wxs)
      end
    end
  else
    if IsAdmin(client) then
      local wxValid = false
      if args[1] == nil then
        TriggerClientEvent('chat:addMessage', (-1), {templateId = 'sysMsg',
          args = {"Invalid Arguments", "/weather <sunny/overcast/etc>"}
        })
      else
        for i,wtype in ipairs(wxTypes) do
          if wtype == string.upper(args[1]) then
            wxValid = true
          end
        end
        if wxValid then
          TriggerClientEvent('cnr:notify', client, 'Weather will change to: ~y~' .. string.lower(args[1]) .. "~s~.")
          wxCurrent = string.upper(args[1])
          wxNewTimer = 10
          TriggerEvent('cnr:weather_sync')
        else
          local wxs = ""
          for _,i in ipairs (wxTypes) do wxs = wxs..v.." " end
          TriggerClientEvent('chat:addMessage', client, {templateId = 'errMsg',
            args = {"Invalid Arguments", "Valid weather types: "..wxs}
          })
        end
      end
    else
      TriggerClientEvent('chat:addMessage', client, {templateId = 'cmdMsg',
        args = {"/weather"}
      })
      print("CNR WEATHER: /weather was denied for player "..GetPlayerName(client).." (ID #"..client..")")
    end
  end
end)

RegisterCommand('morning', function(source)
  if source == 0 then
    print("For console, use the \"/time <hh> <mm>\" command instead!")
    return
  end
  local aid = IsAdmin(client)
  if aid > 0 then
    ShiftMinute(0)
    ShiftHour(9)
    TriggerClientEvent('chat:addMessage', (-1), {templateId = 'sysMsg',
      args = {"Admin #"..aid.." changed the time to ^3MORNING^7 (09:00)"}
    })
    TriggerEvent('cnr:weather_sync')
  end
end)
RegisterCommand('noon', function(source)
  if source == 0 then
    print("For console, use the \"/time <hh> <mm>\" command instead!")
    return
  end
  local aid = IsAdmin(client)
  if aid > 0 then
    ShiftMinute(0)
    ShiftHour(12)
    TriggerClientEvent('chat:addMessage', (-1), {templateId = 'sysMsg',
      args = {"Admin #"..aid.." changed the time to ^3NOON^7 (12:00)"}
    })
    TriggerEvent('cnr:weather_sync')
  end
end)
RegisterCommand('evening', function(source)
  if source == 0 then
    print("For console, use the \"/time <hh> <mm>\" command instead!")
    return
  end
  local aid = IsAdmin(client)
  if aid > 0 then
    ShiftMinute(0)
    ShiftHour(19)
    TriggerClientEvent('chat:addMessage', (-1), {templateId = 'sysMsg',
      args = {"Admin #"..aid.." changed the time to ^3NIGHT^7 (19:00)"}
    })
    TriggerEvent('cnr:weather_sync')
  end
end)
RegisterCommand('night', function(source)
  if source == 0 then
    print("For console, use the \"/time <hh> <mm>\" command instead!")
    return
  end
  local aid = IsAdmin(client)
  if aid > 0 then
    ShiftMinute(0)
    ShiftHour(23)
    TriggerClientEvent('chat:addMessage', (-1), {templateId = 'sysMsg',
      args = {"Admin #"..aid.." changed the time to ^3NIGHT^7 (23:00)"}
    })
    TriggerEvent('cnr:weather_sync')
  end
end)

function ShiftMinute(minute)
  timeOffset = timeOffset - ( ( (bTime+timeOffset) % 60 ) - minute )
end

function ShiftHour(hour)
  timeOffset = timeOffset - ( ( ((bTime+timeOffset)/60) % 24 ) - hour ) * 60
end

RegisterCommand('time', function(s, args, rawCommand)
  local client = s
  if client == 0 then
    if tonumber(args[1]) and tonumber(args[2]) then
      local hr_ = tonumber(args[1])
      local min_ = tonumber(args[2])
      if hr_ < 24 then ShiftHour(hr_)
      else              ShiftHour(0)
      end
      if min_ < 60 then ShiftMinute(min_)
      else              ShiftMinute(0)
      end
      print("CNR WEATHER: Time has changed to " .. hr_ .. ":" .. min_ .. ".")
      TriggerEvent('cnr:weather_sync')
    else
      print("CNR WEATHER: Invalid syntax, correct syntax is: time <hour> <minute> !")
    end
  elseif client ~= 0 then
    local aid = IsAdmin(client)
    if aid > 0 then
      if tonumber(args[1]) and tonumber(args[2]) then
        local hr_ = tonumber(args[1])
        local min_ = tonumber(args[2])
        if hr_ < 24 then ShiftHour(hr_)
        else              ShiftHour(0)
        end
        if min_ < 60 then ShiftMinute(min_)
        else              ShiftMinute(0)
        end
        local newtime = math.floor(((bTime+timeOffset)/60)%24) .. ":"
        local minute  = math.floor((bTime+timeOffset)%60)
        if minute < 10 then newtime = newtime .. "0" .. minute
        else                newtime = newtime .. minute
        end
        TriggerClientEvent('chat:addMessage', (-1), {templateId = 'sysMsg',
          args = {"Admin #"..aid.." changed the time to "..newtime}
        })
        TriggerEvent('cnr:weather_sync')
      else
        TriggerClientEvent('chat:addMessage', client, {templateId = 'errMsg',
          args = {"Invalid Arguments", "USAGE: /time <hour> <minutes>"}
        })
      end
    else
      TriggerClientEvent('chat:addMessage', (-1), {templateId = 'cmdMsg',
        args = {"/time"}
      })
      print("CNR WEATHER: /time was denied for player "..GetPlayerName(client).." (ID #"..client..")")
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(0)
    bTime = os.time(os.date("!*t"))/2 + 360
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(5000)
    TriggerClientEvent('cnr:weather_time', -1, bTime, timeOffset)
  end
end)

Citizen.CreateThread(function()
  while true do
    Citizen.Wait(300000)
    TriggerClientEvent('cnr:weather_time', -1, wxCurrent)
  end
end)

Citizen.CreateThread(function()
  while true do
    wxNewTimer = wxNewTimer - 1
    Citizen.Wait(60000)
    if wxNewTimer == 0 then
      if wxDynamic then NextWeather() end
      wxNewTimer = 10
    end
  end
end)

function NextWeather()
  if wxCurrent == "CLEAR" or wxCurrent == "CLOUDS" or wxCurrent == "EXTRASUNNY"  then
    local new = math.random(1,2)
    if new == 1 then wxCurrent = "CLEARING"
    else             wxCurrent = "OVERCAST"
    end
  elseif wxCurrent == "CLEARING" or wxCurrent == "OVERCAST" then
    local new = math.random(1,6)
    if new == 1 then
        if wxCurrent == "CLEARING" then wxCurrent = "FOGGY" else wxCurrent = "RAIN" end
    elseif new == 2 then wxCurrent = "CLOUDS"
    elseif new == 3 then wxCurrent = "CLEAR"
    elseif new == 4 then wxCurrent = "EXTRASUNNY"
    elseif new == 5 then wxCurrent = "SMOG"
    else                 wxCurrent = "FOGGY"
    end
  elseif wxCurrent == "THUNDER" or wxCurrent == "RAIN" then
    wxCurrent = "CLEARING"
  elseif wxCurrent == "SMOG" or wxCurrent == "FOGGY" then
    wxCurrent = "CLEAR"
  end
  TriggerEvent('cnr:weather_sync')
end

