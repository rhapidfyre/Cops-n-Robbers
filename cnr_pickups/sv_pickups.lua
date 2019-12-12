

local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local tick = {timer = 0, fire = 90, mini = 90, maxi = 300} -- 1.5 to 5 minutes

-- Pickup Spawn Event
--[[
  - Sets the timer of when a pickup will spawn
  - If there are no players on the server, reset timer and wipe existing crates
  - If there are players,
    - Check if any pickup locations are available
      - If no pickups are available (all locations used, doubt it)
      - the game should remove one, and replace it with another item.
      - This ensures that the pickup wasn't bugged.
    - Choose an available pickup location
    - Generate a Hash for Validation (GenerateCrateCode())
    - Send it to all clients for rendering
]]
Citizen.CreateThread(function()

  Citizen.Wait(3000)
  
  -- How many seconds until the timer should fire
  tick.fire = math.random((tick.mini), (tick.maxi))
  
  -- Get time to next crate in seconds
  print(
    "^3[SRP ILLICIT] ^7Next crate spawns at "..
    (os.date("%H:%M", os.time() + add)).." local time."
  )
  
	while true do
    
		if tick.timer >= tick.fire 
    
			local plyCount = #GetPlayers()
      tick.timer = 0
      tick.fire = math.random((tick.mini), (tick.maxi)) * 60
      
			if plyCount > 0 then
        
        local pickupInfo = {}
        TriggerClientEvent('cnr:pickup_create', (-1), pickupInfo)
        
			else
				cprint("^3No players on the server. Any existing pickups have been cleared.")
        DestroyAllPickups()
        
			end
      
		end
  
		tick.timer = tick.timer + 1
		Citizen.Wait(1000)
	end
end)