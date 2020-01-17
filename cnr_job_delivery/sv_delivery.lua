
-- Server
local drivers = {}
local payouts = {
  [1] = function() return (math.random(50, 75))   end,
  [2] = function() return (math.random(80, 120))  end,
  [3] = function() return (math.random(80, 200))  end,
  [4] = function() return (math.random(120, 200)) end,
  [2] = function() return (math.random(200, 500)) end
}

RegisterServerEvent('cnr:delivery_duty')
AddEventHandler('cnr:delivery_duty', function(onDuty)
  local client = source
  if onDuty then  drivers[client] = GetGameTimer()
  else            drivers[client] = nil  
  end
end)

RegisterServerEvent('cnr:delivery_complete')
AddEventHandler('cnr:delivery_complete', function()
  local client = source
  if drivers[client] then
    if drivers[client] < GetGameTimer() then 
      print("DEBUG - Paying for delivery.")
      drivers[client] = GetGameTimer() + 5000
      exports['cnr_cash']:CashTransaction(
        client, payouts[math.random(#payouts)]()
      )
    else print("DEBUG - Was recently paid out. Can't pay.")
    end
  else print("DEBUG - cnr:delivery_complete - Not on delivery duty")
  end
end)

RegisterServerEvent('cnr:delivery_getroutes')
AddEventHandler('cnr:delivery_getroutes', function()
	local ply   = source
	exports['ghmattimysql']:execute(
    "SELECT position FROM houses", {}, function(places)
      TriggerClientEvent('cnr:delivery_routes', ply, places)
    end
  )
end)