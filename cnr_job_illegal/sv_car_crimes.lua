
-- car theft, boosting, chopshops
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


-- Where vehicles can be dropped, depending on the active zone
local vehDrops = {
  [1] = { -- Zone 1 Drops
    vector3 = (947.317, -1697.63, 29.96), -- Garage in East LS Alleyway
    vector3 = (-594.872, -1586.06, 25.89), -- Near trash yard back door
    vector3 = (-1604.1, -826.382, 8.28), -- Big yellow garage at beach parking
  },
  [2] = { -- Zone 2
    vector3 = (3832.17, 4463.89, 1.86), -- Hidden Dock
    vector3 = (1321.06, 4228.92, 32.16), -- Grapeseed Dock
    vector3 = (2348.1, 3131.99, 46.45), -- East Joshua Wasteyard
  },
  [3] = {
    vector3 = (3832.17, 4463.89, 1.86), -- Paleto Bay Garage
  },
  [4] = {
    vector3 = (-1803.56, 2992.16, 31.05), -- Fort Zancudo Hangar
  }
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
Citizen.CreateThread(function()

  Citizen.Wait(3000)
  
	while true do
  
		Citizen.Wait(1000)
		ticker = ticker + 1
		if ticker > 3600 then
      
      -- Get time to next mission list in seconds
      print(
        "^3[AUTO EXPORTS] ^7Vehicle list will regenerate at "..
        (os.date("%H:%M", os.time() + 3600)).." local time."
      )
      
      -- Build the list
      local psuedotable = vehExports
      vehRequest = {} -- Wipe the current list
      for i = 1, 3 do 
        local n = math.random(#psuedotable)
        table.insert(vehRequest, table.remove(psuedotable, n))
      end
      
      -- Send it to everyone connected
      TriggerClientEvent('cnr:exports_list', (-1), vehRequest)
      
		end
	end
end)


-- When a player loads, send them the current vehicle export list
AddEventHandler('cnr:client_loaded', function()
  local client = source
  TriggerClientEvent('cnr:exports_list', client, vehRequest)
end)
