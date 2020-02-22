
-- car theft, boosting, chopshops

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

  },
  [2] = { -- Zone 2
  },
  [3] = {
  },
  [4] = {
  }
}

-- Currently chosen vehicle(s) for exporting
local vehRequest = {}
local ticker     = 0 -- For reselecting export vehicles


-- This loop handles the exports event
--[[
  - Sets the timer of when the crate will spawn
  - If there are no players on the server, reset timer and wipe existing crates
  - If there are players,
    - Choose an available crate (GetCrateSpawn())
    - Generate a Hash for Validation (GenerateCrateCode())
    - Send it to all clients for rendering
]]
Citizen.CreateThread(function()

  Citizen.Wait(3000)
  
	while true do
		Citizen.Wait(1000)
		ticker = ticker + 1
		if ticker > 3600 then
      
      -- Get time to next crate in seconds
      print(
        "^3[AUTO EXPORTS] ^7Vehicle list will regenerate at "..
        (os.date("%H:%M", os.time() + 3600)).." local time."
      )
      
		end
	end
end)