
RegisterNetEvent('cnr:pickup_create')

local pickups = {}


-- If a nearby pickup is not being drawn, draw it
Citizen.CreateThread(function()
  while true do 
    local myPos = GetEntityCoords(PlayerPedId())
    for i = 1, #pickups do
      if #(myPos - pickups[i].posn) < 120.0 then
        if not pickups[i].decay then
          if not DoesEntityExist(pickups[i].obj) then 
            local modelHash = GetHashKey(pickups[i].model)
            RequestModel(modelHash)
            while not HasModelLoaded(modelHash) do Wait(1) end
            local tempObj = CreateObject(modelHash, 
              pickups[i].posn.x, pickups[i].posn.y, pickups[i].posn.z,
              false, false, false
            )
            
            pickups[i].obj = tempObj
            FreezeEntityPosition(pickups[i].obj, true)
            
            -- Create a blip for it
            local temp = AddBlipForEntity(pickups[i].obj)
            SetBlipDisplay(temp, 5)
            SetBlipSprite(temp, pickups[i].blipIcon)
            SetBlipColour(temp, 0)
            SetBlipAsShortRange(temp, true)
            pickups[i].blip = temp
            
            -- While the object exists, make it rotate
            Citizen.CreateThread(function()
              while DoesEntityExist(pickups[i].obj) do 
                local heading = GetEntityHeading(pickups[i].obj) + 1.1
                if heading > 359.0 then heading = 0.0 end
                SetEntityHeading(pickups[i].obj, heading)
                Citizen.Wait(1)
              end
            end)
            
            Citizen.CreateThread(function()
              while DoesEntityExist(pickups[i].obj) do 
                DrawLightWithRange(pickups[i].posn, 255, 10, 0, 1.25, 4.0)
                Citizen.Wait(0)
              end
            end)
            
            end -- Not Exists
        else
          if DoesEntityExist(pickups[i].obj) then 
            DeleteObject(pickups[i].obj)
          end
        end -- Not Decaying
      end -- Nearby
      Citizen.Wait(10)
    end
    Citizen.Wait(100)
  end
end)


AddEventHandler('cnr:pickup_create', function(pInfo)
  print("DEBUG - Currently tracking "..#pickups.." pickups.")
  local n = #pickups + 1
  pickups[n] = pInfo
  print("DEBUG - Now tracking "..#pickups.." pickups.")
end)


RegisterCommand('remguns', function()
  for _,v in pairs (pickups) do v.decay = true end
  print("DEBUG - All pickups marked for removal! (client side only)")
end)


-- Client!
RegisterCommand('spawngun', function()

  local modelHash = GetHashKey("w_pi_pistol")
  RequestModel(modelHash)
  while not HasModelLoaded(modelHash) do Wait(1) end
  
  local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 6.5, -0.4)
  
  local obj = CreateObject(modelHash, offset.x, offset.y, offset.z,
		false, false, false
	)
  
  FreezeEntityPosition(obj, true)
  Citizen.CreateThread(function()
    while DoesEntityExist(obj) do 
      local heading = GetEntityHeading(obj) + 1.1
      if heading > 359.0 then heading = 0.0 end
      SetEntityHeading(obj, heading)
      Citizen.Wait(1)
    end
  end)
  
  local temp = AddBlipForEntity(obj)
  SetBlipDisplay(temp, 5)
  SetBlipSprite(temp, 156)
  SetBlipColour(temp, 0)
  SetBlipAsShortRange(temp, true)
  
  Citizen.CreateThread(function()
    while DoesEntityExist(obj) do 
      DrawLightWithRange(offset.x, offset.y, offset.z, 255,10,0, 1.25, 4.0)
      Wait(0)
    end
  end)
  
  Citizen.Wait(8000)
  DeleteObject(obj)
  
end)
