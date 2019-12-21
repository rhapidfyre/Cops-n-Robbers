
RegisterNetEvent('cnr:pickup_create')
RegisterNetEvent('cnr:grant_pickup')

local pickups = {}
local tableFree = true -- Ensures no operations are done on 'pickups' when true


-- DEBUG - Test
RegisterCommand('obtain', function(s,args,r)
  if not args then args = 1 end
  local myPos = GetEntityCoords(PlayerPedId())
  TriggerServerEvent('cnr:debug_save_pickup',
    myPos.x, myPos.y, myPos.z, tonumber(args[1])
  )
end)

--- CreatePickupObj()
-- Creates the pickup object then returns it
-- @return Object
local function CreatePickupObj(pickup)
  local modelHash = GetHashKey(pickup.p_model)
  RequestModel(modelHash)
  while not HasModelLoaded(modelHash) do Wait(1) end
  local tempObj = CreateObject(modelHash, pickup.posn)
  FreezeEntityPosition(tempObj, true)
  return tempObj
end


--- CreatePickupBlip()
-- Creates a blip for hte pickup object entity
-- @param obj The object
-- @param icon The icon to use
-- @return The blip object
function CreatePickupBlip(obj, icon)
  local temp = AddBlipForEntity(obj)
  SetBlipDisplay(temp, 5)
  SetBlipSprite(temp, icon)
  SetBlipColour(temp, 0)
  SetBlipScale(temp, 0.65)
  SetBlipAsShortRange(temp, true)
  return temp
end

-- If a nearby pickup is not being drawn, draw it
Citizen.CreateThread(function()
  while true do 
    if tableFree then
      tableFree = false
      local myPos = GetEntityCoords(PlayerPedId())
      
      for i = 1, #pickups do
        
        local objDist = #(myPos - pickups[i].posn)
        if not DoesEntityExist(pickups[i].obj) then 
          if objDist < 220.0 then
            if not pickups[i].decay then
              
              pickups[i].obj = CreatePickupObj(pickups[i])
              
              -- Create a blip for it
              pickups[i].blip = CreatePickupBlip(
                pickups[i].obj, pickups[i].p_icon
              )
  
            -- Pickup Decayed
            else
              if DoesEntityExist(pickups[i].obj) then 
                DeleteObject(pickups[i].obj)
                
              end
              
            end
          end
          
        else -- Object does exist
          if objDist < 0.85 then 
            PlaySoundFrontend((-1), "RANK_UP", "HUD_AWARDS", 0)
            Citizen.CreateThread(function()
              local stopGlow = GetGameTimer() + 2000
              local glowPos = GetEntityCoords(pickups[i].obj)
              local glowCol = {255,0,0}
              if pickups[i].p_type == 2 then glowCol = {0,120,255}
              elseif pickups[i].p_type == 3 then glowCol = {0,255,0}
              end
              while stopGlow > GetGameTimer() do 
                DrawLightWithRange(
                  glowPos.x, glowPos.y, glowPos.z - 0.8,
                  glowCol[1], glowCol[2], glowCol[3], 12.0, 4.0
                )
                Citizen.Wait(0)
              end
            end)
            pickups[i].decay = true
            TriggerServerEvent('cnr:obtain_pickup', pickups[i].pHash)
            DeleteObject(pickups[i].obj)
            pickups[i].obj = nil
          
          elseif objDist > 280.0 then 
            DeleteObject(pickups[i].obj)
          
          end
        end
        Citizen.Wait(1)
      end
      tableFree = true
    end
    Citizen.Wait(10)
  end
end)

Citizen.CreateThread(function()
  while true do 
    for i = 1, #pickups do 
      if pickups[i] then 
        if pickups[i].obj then
          if DoesEntityExist(pickups[i].obj) then
            local heading = GetEntityHeading(pickups[i].obj) + 1.1
            if heading > 359.0 then heading = 0.0 end
            SetEntityHeading(pickups[i].obj, heading)
            
          end
          
          if DoesEntityExist(pickups[i].obj) then
            DrawLightWithRange(pickups[i].posn, 255, 10, 0, 1.25, 4.0)
            
          end
        end
      end
    end
    Citizen.Wait(0)
  end
end)

AddEventHandler('cnr:grant_pickup', function(picker, pInfo)
  for k,v in pairs (pickups) do 
    if v.pHash == pInfo.pHash then 
      -- Remove pickup from info table
      while not tableFree do Wait(1) end
      tableFree = false -- Stops all other operations on `pickups`
      table.remove(pickups, k)
      tableFree = true -- Continues operations
      
      if GetPlayerServerId(PlayerId()) == picker then
        local ped = PlayerPedId()
        print("DEBUG - Received ["..pInfo.p_item.."]")
        -- Weapon Pickup (Type 1)
        if pInfo.p_type == 1 then
          local wpnHash = GetHashKey(pInfo.p_item)
          GiveWeaponToPed(ped, wpnHash, pInfo.qty, false, true)
          
        -- Armor Pickup (Type 2)
        elseif pInfo.p_type == 2 then
          local newArmor = GetPedArmour(ped) + pInfo.qty
          if newArmor > GetPlayerMaxArmour(PlayerId()) then 
            newArmor = GetPlayerMaxArmour(PlayerId())
          end
          SetPedArmour(ped, newArmor)
        
        -- Health Pickup (Type 3)
        elseif pInfo.p_type == 3 then
          local newHealth = GetEntityHealth(ped) + pInfo.qty
          if newHealth > GetEntityMaxHealth(ped) then 
            newHealth = GetEntityMaxHealth(ped)
          end
          SetEntityHealth(ped, newHealth)
        
        -- Something else (AKA: Hacked)
        end
      end
    end
  end
end)


AddEventHandler('cnr:pickup_create', function(pInfo)
  while not tableFree do Wait(1) end
  tableFree = false -- Stops all other operations on `pickups`
  local n = #pickups + 1
  pickups[n] = pInfo
  pickups[n].posn = vector3(pInfo['pos_x'], pInfo['pos_y'], pInfo['pos_z'])
  tableFree = true -- Continues operations
  print("DEBUG - Now tracking "..#pickups.." pickups.")
end)


RegisterCommand('remguns', function()
  for _,v in pairs (pickups) do v.decay = true end
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
