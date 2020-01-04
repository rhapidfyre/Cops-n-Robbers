
-- ammu client script
local nearStore = 0
local inRange = false

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
    end
  else
    SetNuiFocus(false)
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

      local dist = #(GetEntityCoords(PlayerPedId()) - v.walkup)
      if dist > 100.0 then nearStore = 0

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