
RegisterServerEvent('cnr:robbery_send_lock')  -- Lock/Unlock Robbery Event
RegisterServerEvent('cnr:robbery_take')       -- The cash won from the robbery
RegisterServerEvent('cnr:robbery_dropped')    -- Converts all robberies to cash
RegisterServerEvent('cnr:client_loaded')      -- Called when the char enters
RegisterServerEvent('cnr:robbery_alarm')      -- Rx's and dispatches an alarm
RegisterServerEvent('cnr:robbery_atm')

local atmRobbed = {}

AddEventHandler('cnr:robbery_atm', function(zoneName, position)
  local client = source
  if not atmRobbed[client] then atmRobbed[client] = GetGameTimer() end
  if atmRobbed[client] <= GetGameTimer() then
    atmRobbed[client] = GetGameTimer() + 300000
    exports['cnr_cash']:CashTransaction(client, math.random(100,1000))
    exports['cnr_wanted']:WantedPoints(client, 'atm', true)
    exports['cnr_police']:DispatchPolice(
      "ATM Alarm", zoneName, position
    )
  else
    TriggerClientEvent('chat:addMessage', client, {
      multiline = true,
      args = {
        "^1ATM ROBBERY",
        "You've recently robbed an ATM! Try again later."
      }
    })
  end
end)

--- EVENT cnr:robbery_take
-- Called when a player finishes a robbery
-- @param cashTake The amount the player successfully robbed
AddEventHandler('cnr:robbery_take', function(cashTake)
  if cashTake > 0 then
    local ply = source
    local uid = exports['cnrobbers']:UniqueId(ply)
    if uid then
      TriggerClientEvent('cnr:robbery_drops', ply)
      -- SQL: Add cash take to robbery DB.
      -- This has to be cashed in later
      exports['ghmattimysql']:execute(
        "INSERT INTO robberies (idUnique, cash) VALUES (@u, @m)",
        {['u'] = uid, ['m'] = cashTake}
      )
    end

  else
    TriggerClientEvent('chat:addMessage', client, {
      multiline = true,
      args = {
        "ROBBERY FAILED",
        "You failed to obtain any items of value from the robbery!"
      }
    })
  end
end)


AddEventHandler('cnr:robbery_dropped', function()
  local ply = source
  local uid = exports['cnrobbers']:UniqueId(ply)
  if uid then
    exports['ghmattimysql']:scalar(
      "SELECT SUM(cash) FROM robberies WHERE idUnique = @u",
      {['u'] = uid},
      function(take)
        if take then
          local pInfo = GetPlayerName(ply).."("..ply..")"
          local dt    = os.date("%H:%M.%I", os.time())
          Laundered(ply, take)
          exports['ghmattimysql']:execute(
            "DELETE FROM robberies WHERE idUnique = @u",
            {['u'] = uid}
          )
          print(
            "[CNR "..dt.."] "..pInfo..
            " cashed in their robbery takes (Worth ^2$"..take.."^7)"
          )
        end
      end
    )
  end
end)


AddEventHandler('cnr:robbery_send_lock', function(storeNumber, lockStatus)
  rob[storeNumber].lockout = lockStatus
  local dt  = os.date("%H:%M.%I", os.time())
  local msg = "Store #"..storeNumber.." has been unlocked and can be robbed."
  if lockStatus then
    msg = "Store #"..storeNumber.." was just robbed, and has been locked."

    -- Dispatch Alarm
    Citizen.CreateThread(function()
      Citizen.Wait(math.random(1, 10) * 1000)
      local mission = rob[storeNumber]
      exports['cnr_police']:DispatchPolice(
        "Hold-up Alarm", mission.title..", in "..mission.area,
        vector3(mission.spawn.x, mission.spawn.x, mission.spawn.z)
      )
      exports['cnr_chat']:DiscordMessage(
        16753920, "Robbery",
        (mission.title).." in "..(mission.area).." has reported a Robbery!", "",
        2
      )
    end)

    -- Unlock robbery after 15 to 40 minutes
    Citizen.CreateThread(function()
      local waitTime = (math.random(15, 40) * 60)
      while waitTime > 0 do
        waitTime = waitTime - 1
        Citizen.Wait(1000)
      end
      rob[storeNumber].lockout = false
      -- Recursively unlock the store for robbery
      TriggerEvent('cnr:robbery_send_lock', storeNumber, false)
    end)

  end
  print("[CNR "..dt.."] "..msg)
  TriggerClientEvent('cnr:robbery_lock_status', (-1), storeNumber, lockStatus)
end)

AddEventHandler('cnr:client_loaded', function()
  local ply = source
  local lockouts = {}
  for k,v in pairs (rob) do
    lockouts[k] = v.lockout
  end
  TriggerClientEvent('cnr:robbery_locks', ply, lockouts)
  -- Check for robbery takes and offer drop offs
  exports['ghmattimysql']:execute(
    "SELECT * FROM robberies WHERE idUnique = @u",
    {['u'] = uid},
    function(takes)
      if takes[1] then
        TriggerClientEvent('cnr:robbery_drops')
    end
  )
end)

AddEventHandler('playerDisconnected', function(reason)
  local client = source
  if laundry[client] then
    if laundry[client] > 0 then
      exports['cnr_cash']:BankTransaction(client, laundry[client])
      laundry[client] = nil
    end
  end
end)

function Laundered(ply, take)
  if not laundry[ply] then laundry[ply] = 0 end
  laundry[ply] = laundry[ply] + take
end

Citizen.CreateThread(function()
  Citizen.Wait(30000)
  while true do 
    for k,v in pairs(laundry) do 
      if v then
        print("DEBUG - Laundering "..GetPlayerName(k).."'s cash ($"..v..")")
        exports['cnr_cash']:BankTransaction(k, v)
      end
      laundry[k] = nil
      Citizen.Wait(1000)
    end
    Citizen.Wait(900000)
  end
end)