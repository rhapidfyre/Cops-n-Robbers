
--[[
  cl_trafficking.lua - Drug, gun, and sex trafficking scripts

  CLIENT SCRIPTING NOTICE:
  Crate objects come with a unique hash generated for that crate.
  This hash is generated within SQL upon creation, making it near impossible
  for client scripters to make illegitimate crates.
  
]]


RegisterNetEvent('cnr:tr_crate_delete') -- Crate spawned by server
RegisterNetEvent('cnr:tr_crate_create') -- Crate picked up by another player

-- ENUMS
local KEY_CRATE = 38 -- E


local crateList     = {}        -- List of eligible crate objects
local pauseCrates   = false     -- Stops crate loop for script to make changes
local collectorRunning = false  -- Is "KEY_CRATE"-press loop running already


--- PickupCrate()
-- Allows the player to pick up a crate, remove it, and notify the server.
-- Func must check that it still exists, that nobody else got it @ same time
function PickupCrate(k)
  if crateList[k] then 
    if crateList[k].obj then 
    
      local cInfo = crateList[k]
      
      pauseCrates = true -- Pause until event comes back
      TriggerServerEvent('cnr:tr_crate_pickup', cInfo.hash, cInfo.key)
      
      local myPos = GetEntityCoords(PlayerPedId())
      TriggerServerEvent('cnr:wanted_points', '664-carjack', true,
        exports['cnrobbers']:GetFullZoneName(GetNameOfZone(myPos)),
        myPos, true
      )
      
    end
  end
end


function CrateCollection()

  -- Quick pause just to make sure this doesn't start looping
  -- after the loop was JUST terminated
  Citizen.Wait(100)
  
  local n = #crateList
  if not collectorRunning then
    Citizen.CreateThread(function()
      collectorRunning = true
      print("DEBUG - Crate (E) Press loop initiated. Waiting for E press.")
      while #crateList > 0 do -- While crates exist
        if not pauseCrates then 
        
          -- When "KEY_CRATE" is pressed
          if IsControlJustPressed(0, KEY_CRATE) then
          
            local cCrate = 0
            local cDist  = math.huge
            
            -- Check all crates for closest crate
            for k,v in pairs(crateList) do 
              if DoesEntityExist(v.obj) then
                local myPos = GetEntityCoords(PlayerPedId())
                local crPos = GetEntityCoords(v.obj)
                local dist = #(myPos - crPos)
                if dist < cDist or cCrate == 0 then
                  cCrate = k
                  cDist  = dist
                end
              end
            end
            
            -- If such crate exists and it's reasonably close
            if cCrate > 0 then 
            
              if cDist < 2.25 then
                PickupCrate(cCrate)
              
              -- If crate isn't close, display "TOO FAR AWAY!"
              -- from the crate's position (might be de-sync'd)
              elseif cDist < 12.0 then
                Citizen.CreateThread(function()
                  local posn = GetEntityCoords(crateList[cCrate].obj)
                  local c = GetGameTimer() + 3000
                  while c > GetGameTimer() do
                    DrawText3D(posn.x, posn.y, posn.z, "TOO FAR AWAY!")
                    Citizen.Wait(0)
                  end
                end)
              end
            end
            
            Citizen.Wait(3000) -- Slow down "E" press to avoid lag
          end
        end
        Citizen.Wait(0)
      end
      collectorRunning = false
      print("DEBUG - Crate (E) Press loop has been terminated.")
    end)
  end
end


-- Handles removing crates
AddEventHandler('cnr:tr_crate_delete', function(serverKey)
  
  print("DEBUG - Server is telling us to remove crate #"..serverKey)
  -- 'pauseCrates' allows the script to pause the handling of creating,
  -- deleting, or otherwise altering crates while crateList is being modified.
  -- This prevents, but doesn't stop, various errors from occuring.
  pauseCrates = true
    
  -- Search the cratelist for crate with given 'serverKey' (server list index)
  local i = 0
  for k,v in pairs (crateList) do 
    if v.key == serverKey then i = k end
  end

  -- if such crate is found
  if i > 0 then
    
    -- Remove the blip if exists, then remove the object if exists
    if crateList[i].blip then 
      if DoesBlipExist(crateList[i].blip) then RemoveBlip(crateList[i].blip) end
    end
    
    if crateList[i].obj then 
      if DoesEntityExist(crateList[i].obj) then DeleteObject(crateList[i].obj) end
    end
    
    -- Must make sure the crate is removed before allowing the loop to continue
    print("DEBUG - Crate removed!")
    table.remove(crateList, i)

  end -- if i<0
  pauseCrates = false
end)


--- CrateHandler()
-- Handles spawning crates if the player is nearby one
-- Only spawns crates if they're within X units (a reasonable range)
function CrateHandler()
  while true do
    -- Iterate thru crateList and draw them if necessary
    -- pauseCrates: If true, script is changing the crate table, wait for
    --              it to complete to continue. (avoids nil bug)
    if not pauseCrates then
      if #crateList > 0 then
        print("DEBUG - Crates exist!")
        for k,v in pairs(crateList) do
          local dist = #(GetEntityCoords(PlayerPedId()) - v.pos)
          
          -- Only render the crate if it's reasonably nearby
          if dist < 100.0 then 
            print("DEBUG - Crate is close by.")
            -- Create the crate object
            if not DoesEntityExist(v.obj) then
              print("DEBUG - Crate doesn't exist; Creating.")
              local mdlHash = GetHashKey(v.mdl)
              RequestModel(mdlHash)
              while not HasModelLoaded(mdlHash) do Wait(10) end
              
              v.obj = CreateObject(mdlHash,
                v.pos.x, v.pos.y, v.pos.z,
                false, false, true
              )
              print("DEBUG - Create Object spawned. Initializing settings...")
              -- Set Options on the Crate
              SetDisableBreaking(v.obj, true)     -- Invincible
              ActivatePhysics(v.obj)              -- Allow physics
              FreezeEntityPosition(v.obj, false)  -- Unfreeze
              Citizen.Wait(100)
              
              print("DEBUG - Crate object finished!")
            end
          end -- dist < 100
          
          Citizen.Wait(100)
        end -- for 
        
      end -- #crateList > 0
    end -- not pauseCrates
    Citizen.Wait(1000) -- antifreeze
  end
end
Citizen.CreateThread(CrateHandler)


-- in_circle()
-- Used to ensure the psuedo-circle blip contains the actual location
local function in_circle(center_x, center_y, radius, x, y)
    dist = math.sqrt((center_x - x) ^ 2 + (center_y - y) ^ 2)
    return dist < radius
end


-- Registers a new crate available for handling
-- @param cInfo Table: {hash, position, key, model}
AddEventHandler('cnr:tr_crate_create', function(cHash, cPos, cKey, cModel)
  
  print("DEBUG - Received new crate from server.")
  pauseCrates = true -- Stop crate rendering
  
  -- Create table entry
  print("DEBUG - Adding crate to list.")
  local n = #crateList + 1
  crateList[n] = {
    hash = cHash, pos  = cPos,
    key  = cKey, mdl  = cModel
  }
  
  
  local dist = 90.0
  
  -- Generate positional information
  local loopn = true      -- loop until radius is valid
  local pX, pY = 0.0, 0.0 -- PsuedoX, PsuedoY
  while loopn do
    pX = math.random(-80, 80) + (cPos.x)
    pY = math.random(-80, 80) + (cPos.y)
    if in_circle(pX, pY, dist, cPos.x, cPos.y) then
      loopn = false
    end
    Citizen.Wait(0)
  end
  
  print("AddBlipForRadius("..pX..", "..pY..", 0.0, "..dist..")")
  local tempBlip = AddBlipForRadius(pX, pY, 0.0, dist)
  SetBlipSprite(tempBlip, 9)
  SetBlipColour(tempBlip, 1)
  SetBlipAlpha(tempBlip, 40)
  crateList[n].blip = tempBlip
  
  print("DEBUG - Now tracking "..n.." crates")
  
	SetNotificationTextEntry("STRING")
	AddTextComponentString("A supply drop has become available. Check your map.")
	SetNotificationMessage(icon, icon, false, 2, title, subtitle, "")
	DrawNotification(false, true)
	PlaySoundFrontend(-1, "GOON_PAID_SMALL", "GTAO_Boss_Goons_FM_SoundSet", 0)
  
  CrateCollection()
  
  pauseCrates = false -- Allow crate rendering
end)