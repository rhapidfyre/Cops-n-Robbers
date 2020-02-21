
-- Drug, gun, sex trafficking
RegisterServerEvent('cnr:tr_crate_pickup')


local boxes     = {} -- List of spawned/eligible crates sent to clients
local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local tick    = {  -- Time keeper
  timer = 0,
  mini  = 10,  -- Minimum time between crate events (in minutes)
  maxi  = 40   -- As minimum but maximum
}


-- Client has told us they've picked up a crate
-- The hash code, and their position should be checked
AddEventHandler('cnr:tr_crate_pickup', function(cHash, k)
  local client = source
  if boxes[k].id == cHash then 
  
    print(
      "^3[TRAFFICKING] ^7"..GetPlayerName(client)..
      " (#"..client..") has collected a ^2trafficking crate^7!"
    )
    
    -- DEBUG - TEMPORARY
    -- Give the player $1000 until the inventory system is in place
    exports['cnr_cash']:CashTransaction(client, 1000)
    
    TriggerClientEvent('cnr:tr_crate_delete', (-1), k)
    
  end
end)


--- LOCAL: GenerateCrateCode()
-- Generates a confirmation hash so the player can't "make up" crates
-- @return Returns a five character string
local function GenerateCrateCode()
  local gens = {
    [1] = function() return string.char(math.random(97, 102)) end,
    [2] = function() return tostring(math.random(0, 9)) end
  }
  return (
    gens[math.random(2)]()..gens[math.random(2)]()..gens[math.random(2)]()..
    gens[math.random(2)]()..gens[math.random(2)]()..gens[math.random(2)]()
  )
end


-- This loop handles the create creation
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
  local add  = 10 --math.random((tick.mini), (tick.maxi)) * 60
  tick.timer = GetGameTimer() + (add * 1000)
  
  -- Get time to next crate in seconds
  print(
    "^3[TRAFFICKING] ^7Next crate spawns at "..
    (os.date("%H:%M", os.time() + add)).." local time."
  )
  
	while true do
		Citizen.Wait(1000)
		tick.timer = tick.timer + 1
		if tick.timer < GetGameTimer() then
    
			local plyCount = #GetPlayers()
      add        = math.random((tick.mini), (tick.maxi)) * 60
			tick.timer = GetGameTimer() + (add * 1000)
      
			if plyCount > 0 then
      
        -- Generate the Crate's info and send to players for rendering
				local crateInfo = GetCrateSpawn() -- Location Information Only
        local contents  = GenerateCrate() -- Chooses a model & Contents
        
        if crateInfo then
        
          local idCrate = GenerateCrateCode()
          local n       = #boxes + 1
          
          crateInfo.cont  = contents.cont -- Add contents to crateInfo table
          crateInfo.id    = idCrate       -- Add hashcode to crateInfo table
          
          boxes[n]        = crateInfo     -- Update global var
          
          -- Send to all clients
          TriggerClientEvent('cnr:tr_crate_create', (-1), 
            idCrate, crateInfo.pos, n, contents.mdl
          )
          
        end
        
			else
				print("^3[TRAFFICKING] ^7No players on the server. Canceling crate event.")
        boxes = {} -- Get rid of all spawned boxes; No one is in the game
			end
      
      -- Get time to next crate in seconds
      print(
        "^3[TRAFFICKING] ^7Next crate spawns at "..
        (os.date("%H:%M", os.time() + add)).." local time."
      )
      
		end
	end
end)