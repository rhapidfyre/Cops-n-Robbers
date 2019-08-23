
--[[
  Cops and Robbers: Pickups Script - Server Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/22/2019
  
  This file contains all the information for creating, modifying, and 
  removing or otherwise operating pickup objects around the map.
--]]

local locs = {
  vector3(-718.58,-884.5,23.82),   vector3(-1073.24,-1049.7,2.15),
  vector3(-1171.63,-972.75,2.15),  vector3(-1143.33,-962.24,5.48),
  vector3(-1147.26,-908.81,2.69),  vector3(-1183.18,-906.41,13.4),
}

local pickups = {} -- List of valid drops

-- DEBUG - 
RegisterServerEvent('cnr:debug_report_pickup')
AddEventHandler('cnr:debug_report_pickup', function(x,y,z,h)
  local dumpFile = io.open("resources/[cnr]/cnr_pickups/pickups.txt", "a+")
  x = math.floor(x*100)/100
  y = math.floor(y*100)/100
  z = math.floor(z*100)/100
  h = math.floor(h*100)/100
  if dumpFile then 
    dumpFile:write("  vector3("..x..","..y..","..z.."),\n")
    dumpFile:close()
    print("DEBUG - Saved Position "..x.." "..y.." "..z.." to pickups.txt.")
  else
    print("DEBUG - Error writing to file pickups.txt")
  end
end)


-- Wipes the pickups table if all players have disconnected
AddEventHandler('playerDropped', function()
  if #GetPlayers() < 1 then pickups = {} end
end)


--[[
  This one is a little complicated. We have to allow people to find pickups,
  but we don't want them to find a ton of them. We also want it to where if 
  a pickup is never found or picked up, we want it to expire. So, the best
  I could come up with at the moment, is a system where every second,
  the Server rolls the dice. If it lands on 1-80, nothing happens. When a pickup
  is created, a corresponding timer will be created to set it to expire.
]]
Citizen.CreateThread(function()
  while true do 
    local dieRoll = math.random(1, 100)
    if dieRoll > 80 then 
      local pickupChoice = items[math.random(#items)]
      local i            = math.random(#locs)
      local position     = locs[i]
      local chosen       = i
      local n = #pickups + 1
      pickups[n] = {i = pickupChoice, p = position, e = GetGameTimer() + 300000}
      TriggerClientEvent('cnr:pickup_create', (-1), n, pickups[n]) 
    end
    for k,v in pairs (pickups) do 
      if v.e < GetGameTimer() then 
        table.remove(pickups, k)
        TriggerClientEvent('cnr:pickup_expired', (-1), k)
      end
    end
    Citizen.Wait(1000)
  end
end)