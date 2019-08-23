
--[[
  Cops and Robbers: Pickups Script - Client Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/22/2019
  
  This file contains all the information for creating, modifying, and 
  removing or otherwise operating pickup objects around the map.
--]]

local pickups = {}

Citizen.CreateThread(function()
  while true do 
    if IsControlJustPressed(0, 243) then 
      local pos  = GetEntityCoords(PlayerPedId())
      local head = GetEntityHeading(PlayerPedId())
      TriggerServerEvent('cnr:debug_report_pickup',
        pos.x, pos.y, pos.z, head
      )
    end
    Wait(1)
  end
end)

Citizen.CreateThread(function()
  while true do 
    for k,v in pairs (pickups) do 
      if not DoesEntityExist(v.ent) then 
        -- Creates the object client side
        if #(GetEntityCoords(PlayerPedId()) - v.p) < 120.0 then
          v.ent = CreateObject(GetHashKey(v.i), v.p.x, v.p.y, v.p.z, false, false, true)
        end
      else
        -- Create a blip if one doesn't exist
        if not DoesBlipExist(v.b) then 
          v.b = AddBlipForEntity(v.ent)
          SetBlipSprite(v.b, 465)
          SetBlipScale(0.45)
          SetBlipAsShortRange(v.b, true)
        end
        -- Remove if player gets too far away
        if #(GetEntityCoords(PlayerPedId()) - v.p) > 200.0 then 
          DeleteObject(v.ent)
        end
      end
      Wait(1)
    end
    Wait(1000)
  end
end)


RegisterNetEvent('cnr:pickup_create')
AddEventHandler('cnr:pickup_create', function(n, pInfo)
  pickups[n] = pInfo
  print("DEBUG - Pickup #"..n.." has been created!")
end)


RegisterNetEvent('cnr:pickup_expired')
AddEventHandler('cnr:pickup_expired', function(n)
  if pickups[n] then 
    local rem = table.remove(pickups, n)
    if DoesBlipExist(rem.b) then RemoveBlip(rem.b) end
    if DoesEntityExist(rem.ent) then DeleteObject(rem.ent) end
    print("DEBUG - Pickup #"..n.." has expired and been removed.")
  end
end)