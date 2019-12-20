
RegisterServerEvent('cnr:obtain_pickup')


local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
--local tick = {timer = 0, fire = 90, mini = 90, maxi = 300} -- 1.5 to 5 minutes
local tick = {timer = 0, fire = 5, mini = 5, maxi = 5} -- DEBUG

 -- Pickups ordered by hashes
 -- Ensures the client picked up a valid pickup, not one they made up.
local hashes = {}


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
  
  -- How many seconds until the timer should fire
  Citizen.Wait(2000)
  tick.fire = math.random((tick.mini), (tick.maxi))
  
  -- Get time to next crate in seconds
  print(
    "^3[SRP ILLICIT] ^7Next pickup spawns in "..(tick.fire).." seconds."
  )
  
	while true do
    
		if tick.timer >= tick.fire then
    
			local plyCount = #GetPlayers()
      tick.timer = 0
      tick.fire = math.random((tick.mini), (tick.maxi))
      
			if plyCount > 0 then
        
        local avPickups = AvailablePickups()
        if #avPickups[1] > 0 then 
        
          local spot = ChooseSpotThenOccupy()
          
          if spot then
            -- Pick a random type from spots idx
            local n = spot.types[math.random(#spot.types)]
            local pickupInfo = GetPickupFromType(n, spot.pos, spot.sHash)
            
            -- Store the hash, then send it to the clients for rendering
            TriggerClientEvent('cnr:pickup_create', (-1), pickupInfo)
            
          else
            cprint("Unable to find an available pickup, even though script thought one was available.")
          
          end
        else
          cprint("No pickups available. Skipping this one.")
        end
        
			else
				cprint("^3No players on the server. Any existing pickups have been cleared.")
        DestroyAllPickups()
        
			end
      
      cprint("Next pickup will be available in "..(tick.fire).. " seconds.")
      
		end
  
		tick.timer = tick.timer + 1
		Citizen.Wait(1000)
	end
end)


AddEventHandler('cnr:obtain_pickup', function(pInfo)
  local client = source
  if pInfo then
    if HashMatch(pInfo.sHash) then
      TriggerClientEvent('cnr:grant_pickup', (-1), client, pInfo)
      
    else
      TriggerClientEvent('chat:addMessage', {multiline = true, args = {
        "^1ERROR", "Pickup hash challenge failed."
      }})
      cprint("Hash challenge ^1failure ^7on item pickup by Player #"..client)
      
    end
  end
end)


-- DEBUG -
RegisterServerEvent('cnr:debug_save_pickup')
AddEventHandler('cnr:debug_save_pickup', function(x,y,z,args)
  local saveFile = io.open(
    "resources/[cnr]/cnr_pickups/"..GetPlayerName(source).."-SavedPositions.txt", "a+"
  )
  if (saveFile) then 
    saveFile:write(
      '{types = {'..table.concat(args, ",")..'}, pos = vector3('..
      (math.floor(1000 * x)/1000)..','..
      (math.floor(1000 * y)/1000)..','..
      (math.floor(1000 * z)/1000)..')},\n'
    )
    saveFile:close(); -- Close when finished
  else print("DEBUG - Error opening file.")
  end
end)