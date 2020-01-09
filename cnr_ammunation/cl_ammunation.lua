
-- ammu client script
RegisterNetEvent('cnr:ammu_authorize')
RegisterNetEvent('cnr:ammu_restore')
RegisterNetEvent('cnr:ammu_revoke_weapon') -- Takes given weapon hashcode (nil = ALL)


local nearStore       = 0
local inRange         = false
local waitForServer   = false
local lastWeapon      = nil
local lastAmmoCount   = 0
local cam


--- EXPORT: InsideGunRange()
-- Returns true if player is in a gun range (won't be charged with crimes)
function InsideGunRange()
  return inRange
end


-- If received by server, gives the weapon from server authorized list
-- If provided, arg `ct` adds ammo to the transaction
-- If not provided with arg `ct`, the weapon is given with default ammo
-- To do both, event should be called twice. 1st for weapon, 2nd for ammo count
AddEventHandler('cnr:ammu_authorize', function(i, ct)
  if source == "" then
    print("^1CNR ERROR: ^7Unable to authenticate the weapon purchase.")
    return 0
  end
  if waitForServer then
  
    -- If no count was given, it was a weapon purchase
    if not ct then 
      GiveWeaponToPed(PlayerPedId(),
        weaponsList[i].mdl, weaponsList[i].ammo, false, true
      )
    
    -- Otherwise they bought ammunition
    else
      AddAmmoToPed(PlayerPedId(),
        weaponsList[i].mdl,
        weaponsList[i].ammo * ct
      )
    
    end
    waitForServer = false
  end
end)

-- Restores previously saved weapons upon login
AddEventHandler('cnr:ammu_restore', function(weaponInfo)
  print("DEBUG - Attempting to restore saved weapons.")
  if weaponInfo[1] then 
    print("DEBUG - Found saved weapons. Restoring.")
    for k,v in pairs(weaponInfo) do 
      local vhash = tonumber(v['hash'])
      print("Restored Saved Weapon: "..
        GetWeaponNameFromHash(vhash).." ("..v['hash']..")."
      )
      GiveWeaponToPed(PlayerPedId(), vhash, v['ammo'], true, false)
    end
  else
    print("DEBUG - No weapons found to restore.")
  end
  print("DEBUG - Finished restoring saved weapons.")
end)

AddEventHandler('cnr:close_all_nui', function()
  SendNUIMessage({closemenus = true})
  SetNuiFocus(false)
end)

RegisterCommand('givegun', function(s,a,r)
  GiveWeaponToPed(PlayerPedId(), GetHashKey(a[1]), 24, false, true)
end)

local function AmmunationMenu(toggle)
  if toggle then  
    if not menuEnabled and not exports['chat']:IsTyping() then 
      
      menuEnabled = true 
      SetNuiFocus(true, true)
      
      local htmlTable = {}
      for k,v in pairs (weaponsList) do
        local isDisabled = ""
        if v.ammo < 2 then isDisabled = 'disabled' end
        table.insert(htmlTable,
          '<div class="weapon" id="w'..(k)..'">'..
          '<img src="img/'..(v.name)..'.png"><br/><table>'..
          '<tr><th colspan="3">'..(v.title)..'</th></tr>'..
          '<tr><th colspan="2">$'..(v.price)..'</th>'..
          '<td><button onclick="BuyWeapon('..(k)..')">PURCHASE</button></td></tr>'..
          '<tr><th colspan="2" id="a'..(k)..'">+ '..(v.ammo)..' AMMO</th>'..
          '<td><button id="b'..(k)..'" onclick="BuyAmmo('..(k)..')" '..
          isDisabled..
          '>$'..(v.ammo * v.aprice)..'</button></td></tr>'..
          '<tr><td><button '..isDisabled..' onclick="AmmoCount(0, '..(k)..')">LESS</button></td>'..
          '<td><button '..isDisabled..' onclick="AmmoCount(1, '..(k)..')">MORE</button></td><td></td></tr></table></div>'
        )
      end
      SendNUIMessage({
        showammu = true,
        weapons = table.concat(htmlTable)
      })
      
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
    if DoesCamExist(cam) then
      SetCamActive(cam, false)
      RenderScriptCams(false, true, 500, true, true)
      cam = nil
    end
    SetNuiFocus(false)
    waitForServer = false
    Citizen.Wait(5000)
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
      
      -- Draw Weapon Sales Point
      DrawMarker(1, v.walkup, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.92, 0.92, 0.35, 255, 190, 40, 90, false, false, 1, false
      )
      DrawMarker(29, (v.walkup + vector3(0, 0, 1.33)), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.45, 0.45, 0.45, 0, 255, 0, 255, false, false, 1, true
      )
      
      --[[ Draw Armor Sales Point
      DrawMarker(1, v.vest, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.92, 0.92, 0.35, 255, 190, 40, 90, false, false, 1, false
      )
      DrawMarker(29, (v.vest + vector3(0, 0, 1.33)), 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.45, 0.45, 0.45, 0, 190, 255, 255, false, false, 1, true
      )]]
      
      -- Create NPC Clerk if not exists
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
          if not DoesRelationshipGroupExist(GetHashKey("AMMUNATION")) then
            AddRelationshipGroup(GetHashKey("AMMUNATION"))
          end
          SetRelationshipBetweenGroups(GetHashKey("AMMUNATION"), GetHashKey("PLAYER"), 3)
          SetRelationshipBetweenGroups(GetHashKey("PLAYER"), GetHashKey("AMMUNATION"), 3)
          print("DEBUG - Created ammu clerk.")
          stores[nearStore].npc = ped
          Citizen.CreateThread(function()
            while DoesEntityExist(stores[nearStore].npc) do 
              SetEntityInvincible(stores[nearStore].npc)
              Citizen.Wait(1)
            end
          end)
        end
      end

      local dist = #(GetEntityCoords(PlayerPedId()) - v.walkup)
      if dist > 100.0 then
        if stores[nearStore].npc then 
          DeletePed(stores[nearStore].npc)
          stores[nearStore].npc = nil
          print("DEBUG - Destroyed ammy clerk")
        end
        nearStore = 0

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

local function ChangeAmmo(idx, addOne)

  if addOne then weaponsList[idx].qty = weaponsList[idx].qty + 1
  else weaponsList[idx].qty = weaponsList[idx].qty - 1
  end
  
  if weaponsList[idx].qty > 6 then
    weaponsList[idx].qty = 6
  elseif weaponsList[idx].qty < 1 then 
    weaponsList[idx].qty = 1
  end
  
  SendNUIMessage({
  
    ammoct    = weaponsList[idx].qty *
                weaponsList[idx].ammo,
                
    ammoprice = weaponsList[idx].qty *
                weaponsList[idx].ammo *
                weaponsList[idx].aprice,
                
    ammoindex = idx
    
  })
      
end
RegisterNUICallback("ammuMenu", function(data, cb)
  if data.action == "exit" then
    AmmunationMenu(false)
  else
    if data.action == "ammoCount" then 
      ChangeAmmo(data.weapon, (data.more == 1))
      
    elseif data.action == "buyWeapon" then 
      waitForServer = true
      TriggerServerEvent('cnr:ammu_buyweapon', data.weapon)
    
    elseif data.action == "buyAmmo" then
      waitForServer = true
      TriggerServerEvent('cnr:ammu_buyammo',
        data.weapon, weaponsList[data.weapon].qty
      )
    end
  end
end)

local function ClerkHate(toggle)
  if toggle then 
    print("DEBUG - Clerk will no longer attack the player.")
    if nearStore > 0 then 
      if stores[nearStore].npc then
        local ped = stores[nearStore].npc
        TaskSetBlockingOfNonTemporaryEvents(ped, true)
      end
    end

  else
    print("DEBUG - Clerk will once again engage the player.")
    if nearStore > 0 then 
      if stores[nearStore].npc then
        local ped = stores[nearStore].npc
        TaskSetBlockingOfNonTemporaryEvents(ped, false)
      end
    end
    
    
  end
end

-- Ignore gun crimes while inside the range
local function CheckInGunRange()
  local cDist = math.huge
  for k,v in pairs (stores) do
    if v.range then
      local myPos = GetEntityCoords(PlayerPedId())
      local dist = #(myPos - v.range)
      if dist < cDist then cDist = dist end
    end
  end
  
  if cDist < 8.25 then 
    if not inRange then
      inRange = true
      --[[TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
        "You've entered an area where gun crimes will be ignored."
      }})]]
      TriggerEvent('cnr:crimefree', true, GetCurrentResourceName())
    end
    ClerkHate(true)
  else
    if inRange then
      inRange = false
      --[[TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
        "You've re-entered the game area and gun crimes will be reported."
      }})]]
      TriggerEvent('cnr:crimefree', false, GetCurrentResourceName())
      ClerkHate(false)
    end
  end
end

local function RevokeWeapon(hashKey, isAdmin)
  if not hashKey then
    RemoveAllPedWeapons(PlayerPedId(), true)
    local rMsg = "Your weapons were confiscated!"
    if isAdmin then rMsg = "An admin has removed all of your weapons." end
    TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {rMsg}})
  else
    local rMsg = "Your "..GetWeaponFromHash(hashKey).." was confiscated!"
    if isAdmin then
      rMsg = "An admin revoked your "..GetWeaponFromHash(hashKey).."!"
    end
    TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {rMsg}})
  end
end

-- if `hashKey` is rx'd nil, takes ALL weapons away
-- if `isAdmin` is not false/nil, notifies client it was taken by an admin
AddEventHandler('cnr:ammu_revoke_weapon', function(hashKey, isAdmin)
  RevokeWeapon(hashKey, isAdmin)
end)


Citizen.CreateThread(function()
  while true do
  
    CheckInGunRange()
    
    -- Check for reasons to close the Ammunation Menu
    if menuEnabled then 
      if IsPauseMenuActive() then AmmunationMenu(false)
      elseif IsPedDeadOrDying(PlayerPedId()) then AmmunationMenu(false)
      end
    end
    
    -- If the player has fired, update ammunition
    local pedWeapon = GetSelectedPedWeapon(PlayerPedId())
    if pedWeapon ~= GetHashKey("WEAPON_UNARMED") then 
      local hasClip, magazine = GetAmmoInClip(PlayerPedId(), pedWeapon)
      local ammoTotal = GetAmmoInPedWeapon(PlayerPedId(), pedWeapon)
      if lastWeapon then 
        if hasClip and lastWeapon then 
          
          -- If the weapon is the same previous check
          if lastWeapon == pedWeapon then 
          
            -- If the ammo changed, notify the server
            if lastAmmoCount > ammoTotal then
              lastAmmoCount = ammoTotal
              TriggerServerEvent('cnr:ammu_ammo_update', pedWeapon, ammoTotal)
              
            end
          
          -- If the weapon is not the same as it was before
          else lastWeapon = pedWeapon; lastAmmoCount = ammoTotal;
            
          end
        end
      else lastWeapon = pedWeapon; lastAmmoCount = ammoTotal;
      end
    else lastWeapon = nil; lastAmmoCount = 0
    end
    
    Citizen.Wait(1000)
  end
end)
