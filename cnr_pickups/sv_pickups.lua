
RegisterServerEvent('cnr:obtain_pickup')

AddEventHandler('onResourceStart', function(rname)
  if GetCurrentResourceName() == rname then
    DestroyAllPickups()
  end
end)


local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local pickups = 0
local tick = {timer = 0, fire = 30, mini = 300, maxi = 900} -- 5 to 15 minutes


--- DestroyAllPickups()
-- Sets all pickups to available. Used if no players are connected.
function DestroyAllPickups()

  -- SQL: Remove all waiting pickups from the table
  exports.ghmattimysql:execute(
    "DELETE FROM pickup_waiting", {},
    function()
      TriggerClientEvent('cnr:pickups_destroyed', (-1))
      pickups = 0
    end
  )

end


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

	while true do

		if tick.timer >= tick.fire then

			local plyCount = #GetPlayers()
      tick.timer = 0
      tick.fire = math.random((tick.mini), (tick.maxi))

			if plyCount > 0 then
        local pickupInfo = exports.ghmattimysql:executeSync("CALL new_pickup()")
        if pickupInfo[1] then
          if pickupInfo[1][1]['pHash'] ~= "NA" then
            TriggerClientEvent('cnr:pickup_create', (-1), pickupInfo[1][1])
            pickups = pickups + 1
          end
        end

			else
        if pickups > 0 then
          cprint("^3No players on the server. Any existing pickups have been cleared.")
          DestroyAllPickups()
        end
			end

		end

		tick.timer = tick.timer + 1
		Citizen.Wait(1000)

	end
end)


AddEventHandler('cnr:obtain_pickup', function(pHash)
  local client = source
  if pHash then
    local pInfo = exports.ghmattimysql:executeSync(
      "CALL handle_pickup(@ph)",
      {['ph'] = pHash}
    )
    if pInfo[1] then
      if pInfo[1][1] then
        TriggerClientEvent('cnr:grant_pickup', (-1), client, pInfo[1][1])
      end
    end
  else print("DEBUG - No hash received.")
  end
end)


-- DEBUG -
RegisterServerEvent('cnr:debug_save_pickup')
AddEventHandler('cnr:debug_save_pickup', function(x,y,z,pType)
  exports.ghmattimysql:execute(
    "INSERT INTO pickup_spots (x, y, z, ptype) VALUES (@x, @y, @z, @pt)", {
    ['x']  = (math.floor(1000 * x)/1000),
    ['y']  = (math.floor(1000 * y)/1000),
    ['z']  = (math.floor(1000 * z)/1000),
    ['pt'] = pType
  })
end)

