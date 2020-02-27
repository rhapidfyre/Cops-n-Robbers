
RegisterNetEvent('cnr:inventory_receive') -- Update entire inventory
RegisterNetEvent('cnr:inventory_add')     -- Add a single item stack
RegisterNetEvent('cnr:inventory_remove')  -- Remove single item stack
RegisterNetEvent('cnr:inventory_drop')    -- Tracks items dropped on the ground
RegisterNetEvent('cnr:inventory_modify')  -- Modify an item by amount
RegisterNetEvent('cnr:consume')


local menuEnabled  = false
local pauseDropped = false -- Stop the drop loop from processing

local toggle_inv   = 288 -- F1
local pickup_key   = 38
local inv          = {}
local dropped      = {}

--- EXPORT: GetInventory()
-- Returns the contents of the player's inventory to calling script
function GetInventory()
  return inv
end


--- EXPORT: GetWeight()
-- Returns total weight of the player's inventory
function GetWeight()
  local running_total = 0
  if #inv > 0 then
    for k,v in pairs (inv) do
      running_total = running_total + (v['weight'] * v['quantity'])
    end
  end
  return running_total
end


-- Returns truth value of whether the player should be
-- allowed/able to use the inventory menu
local function IsInventoryAccessible()

  if IsPauseMenuActive() then
    print("Cannot open CNR Inventory with the pause menu open.")
    return false
  elseif exports['chat']:IsTyping() then
    print("Cannot open CNR Inventory while chatting.")
    return false
  elseif IsPedDeadOrDying(PlayerPedId()) then
    print("Cannot open CNR Inventory while dead.")
    return false
  end

  return true
end


-- Handles reasons why the menu should open or close
Citizen.CreateThread(function()
  while true do

    -- While the menu is OPEN
    if menuEnabled then

      -- If player pauses, dies, or the chat box opens, close menu
      if not IsInventoryAccessible() then
        CloseInventory()

      end

    -- While the menu is CLOSED
    else
      if IsControlJustPressed(0, toggle_inv) then
        if IsInventoryAccessible() then
          if not menuEnabled then
            OpenInventory()
          end
        else Citizen.Wait(999)
        end
      end
    end
    
    Citizen.Wait(1)
  end
end)

local function CreateDropPackage(coords, givenModel, iName, qty)
  if not givenModel then givenModel = "prop_cs_package_01" end
  local mdl = GetHashKey(givenModel)
  if IsModelValid(mdl) then
    print("DEBUG - Requesting model '"..givenModel.."'.")
    RequestModel(mdl)
    while not HasModelLoaded(mdl) do Wait(10) end
    print("DEBUG - Model Loaded.")
    local temp = CreateObject(mdl, coords.x, coords.y, coords.z, true, false, true)
    print("DEBUG - Object Created @ "..tostring(coords)..".")
    SetDisableBreaking(temp, true)
    SetEntityAsMissionEntity(temp, true, true)
    ActivatePhysics(temp)
    SetActivateObjectPhysicsAsSoonAsItIsUnfrozen(temp, true)
    FreezeEntityPosition(temp, false)
    ApplyForceToEntity(temp, 0,
      coords.x + 1.0, coords.y, coords.z,
      0.0, 0.1, 0.0, 0, 0, 1, 1, 0, 1
    )
    
    return temp
    
  else
    print("DEBUG - CreateDropPackage() failed on IsModelValid("..mdl..")")
    return nil
  end
end

    
Citizen.CreateThread(function()
  while true do 
    for k,v in pairs (dropped) do
      if DoesEntityExist(v.obj) then
        local objPos = GetEntityCoords(v.obj)
        if #(GetEntityCoords(PlayerPedId()) - objPos) < 12.0 then 
          DrawText3D(objPos.x, objPos.y, objPos.z,
            "[HOLD ~g~E~w~] Pick up: ~y~"..(v.item['title']).." x"..(v.count)
          )
        end
      end
    end
    Citizen.Wait(1)
  end
end)


-- Draws text on screen as positional
function DrawText3D(x, y, z, text) 
	local red = 255
  SetDrawOrigin(x, y, z, 0);
  BeginTextCommandDisplayText("STRING")
  SetTextScale(0.3, 0.3)
  SetTextFont(0)
  SetTextProportional(1)
  SetTextColour(255, red, red, 255)
  SetTextDropshadow(0, 0, 0, 0, 255)
  SetTextEdge(2, 0, 0, 0, 150)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(0.0, 0.0)
  ClearDrawOrigin()
end


--- PickupPackage()
-- Called when the player collects a package on the ground
local function PickupPackage(num)
  pauseDropped = true
  TriggerServerEvent('cnr:inventory_pickup', dropped[num].item, dropped[num].count)
  Citizen.Wait(100)
  if DoesEntityExist(dropped[num].obj) then DeleteObject(dropped[num].obj) end
  table.remove(dropped, num)
  Citizen.Wait(900)
  pauseDropped = false
end


-- Tracks items dropped on the ground
Citizen.CreateThread(function()
  while true do 
    if not pauseDropped then
      local myPos = GetEntityCoords(PlayerPedId())
      for k,v in pairs (dropped) do 
        if v.pos and not pauseDropped then 
          local dist = #(myPos - v.pos)
          
          -- If object does not exist
          if not DoesEntityExist(v.obj) then
            if dist < 80.0 then 
              print("DEBUG - Creating item package from dropped item.")
              v.obj = CreateDropPackage(v.pos, v.item['model'], v.item['title'], v.count)
              print("DEBUG - Successfully created drop package.")
            end
            
          -- Object exists
          else
          
            -- Remove the object if we get too far away
            if dist > 120.0 then 
              if v.obj and not pauseDropped then 
                DeleteObject(v.obj)
                print("DEBUG - Removing item package from ground (too far)")
              end
              
            elseif dist < 4.0 then
            
              -- Pick it up if we're holding E
              if IsControlPressed(0, pickup_key) then
                PickupPackage(k)
              
              end
            
            end
            
          end
          
        end -- if pos
      end -- for
    end -- if not pauseDropped
    Citizen.Wait(1000)
  end
end)


function CloseInventory()
  print("DEBUG - Closing Inventory.")
  SendNUIMessage({hideinv = true})
  SetNuiFocus(false)
  menuEnabled = false
end


function OpenInventory()
  print("DEBUG - Opening Inventory.")
  menuEnabled = true
  SendNUIMessage({showinv = true})
  SetNuiFocus(true, true)
end


-- Emergency Close / Menu's are Stuck
AddEventHandler('cnr:close_all_nui', function()
  CloseInventory()
end)


--- BuildInventory()
-- Builds the inventory from scratch and dispatches it to JavaScript
function BuildInventory()
  local htmlTable = {}
  for k,v in pairs (inv) do 
  
    local n = #htmlTable + 1
    local itemName = v["name"]
    if v["title"] then itemName = v["title"] end
    local strnPath = "img/"
    if v["resname"] ~= "cnr_inventory" then 
      strnPath = 'nui://'..v["resname"]..'/nui/img/'
    end
    local isConsume = "i"
    if v["consume"] then isConsume = "c" end
    table.insert(htmlTable,
      '<div class="item" id="'..isConsume..v["id"]..'"><img src="'..strnPath..v["img"]..'.png">'..
      '<span class="icount">'..v["quantity"]..'</span>'..
      '<span class="iname">'..(itemName)..'</span></div>'
    )
    
  end
  SendNUIMessage({invupdate = table.concat(htmlTable)})
end

AddEventHandler('cnr:inventory_receive', function(myInventory)
  inv = myInventory
  BuildInventory()
end)


AddEventHandler('cnr:inventory_drop', function(itemInfo, qty, coords)
  pauseDropped = true
  local n = #dropped + 1
  dropped[n] = {item = itemInfo, pos = coords, count = qty}
  print("DEBUG - Added a dropped item ("..tostring(dropped[n].item['name'])..") @ "..tostring(pos))
  pauseDropped = false
end)


local lastServerRequest = 0
RegisterNUICallback('inventoryActions', function(data, callback)

  if data.action == "exit" then
    CloseInventory()
  
  elseif data.action == "doAction" then
    
    local i = tonumber(data.item)
    local t = tonumber(data.trigger)
    local q = tonumber(data.quantity)
    local myPos = GetEntityCoords(PlayerPedId())
    local runAction = false
    
    if t == 1 then
      if data.actn == "c" then runAction = true end
    else runAction = true
    end
    if runAction then
    
      if lastServerRequest > GetGameTimer() then
        TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
          "You can't do that for another "..
          math.ceil((lastServerRequest - GetGameTimer())/1000).." seconds."
        }})
        return 0 
      end
      lastServerRequest = GetGameTimer() + 5000
      TriggerServerEvent('cnr:inventory_action', t, i, q, myPos)
      
    else
      if t == 1 then 
        TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
          "That item cannot be used this way!"
        }})
      end
    end
    
  elseif data.action == "itemSelect" then
    SendNUIMessage({itemsel = data.sel})

  end

end)

