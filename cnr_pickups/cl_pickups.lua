
RegisterNetEvent('cnr:pickup_create')
RegisterNetEvent('cnr:grant_pickup')

local pickups = {}
local tableFree = true -- Ensures no operations are done on 'pickups' when true


-- DEBUG - Test
RegisterCommand('obtain', function(s,args,r)
  if not args then args = {1} end
  local myPos = GetEntityCoords(PlayerPedId())
  TriggerServerEvent('cnr:debug_save_pickup',
    myPos.x, myPos.y, myPos.z, args
  )
end)

--- CreatePickupObj()
-- Creates the pickup object then returns it
-- @return Object
local function CreatePickupObj(pickup)
  local modelHash = GetHashKey(pickup.model)
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
          if objDist < 120.0 then
            if not pickups[i].decay then
              
              pickups[i].obj = CreatePickupObj(pickups[i])
              
              -- Create a blip for it
              pickups[i].blip = CreatePickupBlip(
                pickups[i].obj, pickups[i].blipIcon
              )
              
            -- Pickup Decayed
            else
              if DoesEntityExist(pickups[i].obj) then 
                DeleteObject(pickups[i].obj)
                
              end
              
            end
          end
          
        else -- Object does exist
          if objDist < 1.8 then 
            PlaySoundFrontend((-1), "RANK_UP", "HUD_AWARDS", 0)
            Citizen.CreateThread(function()
              local stopGlow = GetGameTimer() + 2000
              local glowPos = GetEntityCoords(pickups[i].obj)
              while stopGlow > GetGameTimer() do 
                DrawLightWithRange(glowPos, 0, 255, 0, 3.0, 6.0)
                Citizen.Wait(0)
              end
            end)
            pickups[i].decay = true
            TriggerServerEvent('cnr:obtain_pickup', pickups[i])
            DeleteObject(pickups[i].obj)
            pickups[i].obj = nil
          
          elseif objDist > 160.0 then 
            DeleteObject(pickups[i].obj)
          
          end
        end
        Citizen.Wait(10)
      end
      tableFree = true
    end
    Citizen.Wait(100)
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
    if v.sHash == pInfo.sHash then 
      -- Remove pickup from info table
      while not tableFree do Wait(1) end
      tableFree = false -- Stops all other operations on `pickups`
      table.remove(pickups, k)
      tableFree = true -- Continues operations
      
      if GetPlayerServerId(PlayerId()) == picker then
        local ped = PlayerPedId()
        
        -- Weapon Pickup (Type 1)
        if pInfo.pType == 1 then
          local wpnHash = GetHashKey(pInfo.name)
          GiveWeaponToPed(ped, wpnHash, pInfo.qty, false, true)
          
        -- Armor Pickup (Type 2)
        elseif pInfo.pType == 2 then
          local newArmor = GetPedArmour(ped) + pInfo.qty
          if newArmor > GetPlayerMaxArmour(PlayerId()) then 
            newArmor = GetPlayerMaxArmour(PlayerId())
          end
          SetPedArmour(ped, newArmor)
        
        -- Health Pickup (Type 3)
        elseif pInfo.pType == 3 then
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
  tableFree = true -- Continues operations
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
