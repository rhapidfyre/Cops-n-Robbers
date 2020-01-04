
-- ammu client script
local nearStore = 0
local inRange = false
local cam

--- EXPORT: InsideGunRange()
-- Returns true if player is in a gun range (won't be charged with crimes)
function InsideGunRange()
  return inRange
end

local function AmmunationMenu(toggle)
  if toggle then  
    if not menuEnabled then 
      
      menuEnabled = true 
      SendNUIMessage({showammu = true})
      SetNuiFocus(true, true)
      
      if stores[nearStore].heading then
        SetEntityHeading(PlayerPedId(), stores[nearStore].heading)
      end
      
      local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 2.0, -1.25, 1.075)
      local headn = GetEntityHeading(PlayerPedId())
      if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
      SetCamActive(cam, true)
      RenderScriptCams(true, true, 500, true, true)
      SetCamParams(cam, offset.x, offset.y, offset.z, 350.0, 0.0, headn + 42.0, 50.0)
      
    end
  else
    SetNuiFocus(false)
    if DoesCamExist(cam) then
      SetCamActive(cam, false)
      RenderScriptCams(false, true, 500, true, true)
      cam = nil
    end
    Citizen.Wait(3000)
    menuEnabled = false
  end
end

-- Build map markers
Citizen.CreateThread(function()

  -- Draw blips for each ammunation
  for k,v in pairs (stores) do
    if not v.blip then
      local temp = AddBlipForCoord(v.walkup)
      SetBlipSprite(temp, v.icon)
      SetBlipAsShortRange(temp, true)
      SetBlipDisplay(temp, 8)
      v.blip = temp
    end
  end

  -- Draw markers if in range
  while true do
    if nearStore > 0 then

      local v = stores[nearStore]
      DrawMarker(1, v.walkup, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.85, 0.85, 0.35, 255, 190, 40, 90, false, false, 1, false
      )
      DrawMarker(29, (v.walkup + vector3(0, 0, 1)), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.65, 0.65, 0.65, 0, 255, 0, 255, false, false, 1, true
      )
      if not stores[nearStore].npc then 
        print("DEBUG - NPC Doesn't exist for store #"..nearStore)
        if stores[nearStore].clerk then 
          local mdl = (stores[nearStore].clerk.mdl)
          RequestModel(mdl)
          print("DEBUG - Requesting Model")
          local sPos = stores[nearStore].clerk.pos
          local ped = CreatePed(
            PED_TYPE_CIVMALE, mdl, sPos.x, sPos.y, sPos.z,
            stores[nearStore].clerk.h, false, false
          )
          GiveWeaponToPed(ped, GetHashKey("WEAPON_PISTOL50"), 96, true, false)
          print("DEBUG - Created ammu clerk.")
          stores[nearStore].npc = ped
        end
      end

      local dist = #(GetEntityCoords(PlayerPedId()) - v.walkup)
      if dist > 100.0 then
        nearStore = 0
        if stores[nearStore].npc then 
          DeletePed(stores[nearStore].npc)
          stores[nearStore].npc = nil
          print("DEBUG - Destroyed ammy clerk")
        end

      else
        if dist < 1.25 then AmmunationMenu(true) end
      end
    else
      local cDist = math.huge
      local myPos = GetEntityCoords(PlayerPedId())
      for k,v in pairs (stores) do
        local dist = #(myPos - v.walkup)
        if dist < 100.0 and dist < cDist then
          cDist = dist; nearStore = k
        end
      end
      Citizen.Wait(1000)
    end
    Citizen.Wait(0)
  end

end)

RegisterNUICallback("ammuMenu", function(data, cb)
  if data.action == "exit" then AmmunationMenu(false)
  else
  
  end
end)

-- Ignore gun crimes while inside the range
Citizen.CreateThread(function()
  while true do
    for k,v in pairs (stores) do
      if v.range then
        local myPos = GetEntityCoords(PlayerPedId())
        if #(myPos - v.range) < 9.0 then
          if not inRange then
            inRange = true
            TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
              "You've entered an area where gun crimes will be ignored."
            }})
            TriggerEvent('cnr:crimefree', true, GetCurrentResourceName())
          end
        else
          if inRange then
            inRange = false
            TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
              "You've re-entered the game area and gun crimes will be reported."
            }})
            TriggerEvent('cnr:crimefree', false, GetCurrentResourceName())
          end
        end
      end
    end
    Citizen.Wait(1000)
  end
end)