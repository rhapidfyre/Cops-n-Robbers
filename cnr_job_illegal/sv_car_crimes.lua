
-- car theft, boosting, chopshops
RegisterServerEvent('baseevents:enteringVehicle')
RegisterServerEvent('baseevents:enteredVehicle')
RegisterServerEvent('cnr:exports_arrived')
RegisterServerEvent('cnr:client_loaded')

-- List of vehicles eligible for exporting
local vehExports = {
  --{mdl = "", price = 1000, alarm = 0},
  {mdl = "BANDSHEE",      price = 5000,   alarm = 0},
  {mdl = "DOMINATOR",     price = 5000,   alarm = 0},
  {mdl = "GAUNTLET",      price = 5000,   alarm = 0},
  {mdl = "ADDER",         price = 5000,   alarm = 0},
  {mdl = "BULLET",        price = 5000,   alarm = 0},
  {mdl = "CHEETAH",       price = 5000,   alarm = 0},
  {mdl = "NINEF",         price = 5000,   alarm = 0},
  {mdl = "NINEF2",        price = 5000,   alarm = 0},
  {mdl = "BUFFALO2",      price = 5000,   alarm = 0},
  {mdl = "CAVALCADE2",    price = 5000,   alarm = 0},
  {mdl = "CARBONIZZARE",  price = 5000,   alarm = 0},
  {mdl = "COMET",         price = 5000,   alarm = 0},
  {mdl = "COQUETTE",      price = 5000,   alarm = 0},
  {mdl = "DUNE",          price = 5000,   alarm = 0},
  {mdl = "DUNE2",         price = 5000,   alarm = 0},
  {mdl = "COMET2",        price = 5000,   alarm = 0},
  {mdl = "ENTITYXF",      price = 5000,   alarm = 0},
  {mdl = "EXEMPLAR",      price = 5000,   alarm = 0},
  {mdl = "ELEGY2",        price = 5000,   alarm = 0},
  {mdl = "F620",          price = 5000,   alarm = 0},
  {mdl = "FELON2",        price = 5000,   alarm = 0},
  {mdl = "INFERNUS",      price = 5000,   alarm = 0},
  {mdl = "BFINJECTION",   price = 5000,   alarm = 0},
  {mdl = "MONROE",        price = 5000,   alarm = 0},
  {mdl = "PHOENIX",       price = 5000,   alarm = 0},
  {mdl = "RAPIDGT",       price = 5000,   alarm = 0},
  {mdl = "RAPIDGT2",      price = 5000,   alarm = 0},
  {mdl = "SANDKING2",     price = 5000,   alarm = 0},
  {mdl = "STINGERGT",     price = 5000,   alarm = 0},
  {mdl = "VOLTIC",        price = 5000,   alarm = 0},
  {mdl = "ZTYPE",         price = 5000,   alarm = 0},
  {mdl = "DOZER",         price = 5000,   alarm = 0},
  {mdl = "DAEMON",        price = 5000,   alarm = 0},
  {mdl = "BATI",          price = 5000,   alarm = 0},
  {mdl = "COQUETTE2",     price = 5000,   alarm = 0},
  {mdl = "ELEGY",         price = 5000,   alarm = 0},
  {mdl = "FUROREGT",      price = 5000,   alarm = 0},
  {mdl = "HOTKNIFE",      price = 5000,   alarm = 0},
  {mdl = "JESTER",        price = 5000,   alarm = 0},
  {mdl = "TURISMO",       price = 5000,   alarm = 0}
}


-- Currently chosen vehicle(s) for exporting
local vehRequest = {}
local ticker     = 0 -- For reselecting export vehicles


-- This loop handles the exports event
--[[
  -- Every hour:
  -- A list of 3 vehicles will be chosen
  -- Those 3 vehicles will be sent to all players
]]
local function GenerateVehicleList()
    
  -- Get time to next mission list in seconds
  print(
    "^3[AUTO EXPORTS] ^7Vehicle list will regenerate at "..
    (os.date("%H:%M", os.time() + 3600)).." local time."
  )
  
  -- Build the list
  vehRequest = {} -- Wipe the current list
  local psuedotable = {}
  for k,v in pairs (vehExports) do
    table.insert(psuedotable, v)
  end
  for i = 1, 3 do 
    local n = math.random(#psuedotable)
    local vChoice = table.remove(psuedotable, n)
    table.insert(vehRequest, vChoice)
    print("DEBUG - Added "..(vChoice.mdl).." to the exports list.")
  end
  
  -- Send it to everyone connected
  TriggerClientEvent('cnr:exports_list', (-1), vehRequest)
      
end
Citizen.CreateThread(function()
  Citizen.Wait(3000)
  GenerateVehicleList()
	while true do
		Citizen.Wait(1000)
		ticker = ticker + 1
		if ticker > 3600 then
      ticker = 0
      GenerateVehicleList()
		end
	end
end)


-- When a player loads, send them the current vehicle export list
AddEventHandler('cnr:client_loaded', function()
  local client = source
  TriggerClientEvent('cnr:exports_list', client, vehRequest)
end)


AddEventHandler('baseevents:enteredVehicle', function(veh, seat, vehModel)
  local client = source
  for k,v in pairs (vehRequest) do 
    if GetHashKey(v.mdl) == GetHashKey(vehModel) then
      TriggerClientEvent('cnr:exports_mission_vehicle', client, v.price, veh)
      break
    end
  end
end)


AddEventHandler('cnr:exports_arrived', function(vehModel)
  local client = source
  local misnVehicle = 0
  for k,v in pairs (vehRequest) do 
    if GetHashKey(v.mdl) == vehModel then 
      misnVehicle = k 
    end
  end
  if misnVehicle > 0 then 
    TriggerClientEvent('cnr:exports_delivered', client)
    exports['cnr_wanted']:WantedPoints(client, "auto-export", true)
    exports['cnr_cash']:BankTransaction(client, vehRequest[misnVehicle].price)
  end
end)

