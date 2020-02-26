
RegisterNetEvent('cnr:inventory_receive') -- Update entire inventory
RegisterNetEvent('cnr:inventory_add')     -- Add a single item stack
RegisterNetEvent('cnr:inventory_remove')  -- Remove single item stack
RegisterNetEvent('cnr:inventory_modify')  -- Modify an item by amount


local menuEnabled = false
local toggle_inv = 288 -- F1
local inv = {}

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
    
    local isConsume = "i"
    if v["consume"] then isConsume = "c" end
    table.insert(htmlTable,
      '<div class="item" id="'..isConsume..v["id"]..'"><img src="'..v["name"]..'">'..
      '<span class="icount">'..v["quantity"]..'</span>'..
      '<span class="iname">'..(itemName)..'</span></div>'
    )
    
  end
  SendNUIMessage({invupdate = table.concat(htmlTable)})
end

AddEventHandler('cnr:inventory_receive', function(myInventory)
  inv = myInventory
  print("DEBUG - Received inventory from server with "..#inv.." items.")
  BuildInventory()
end)


RegisterNUICallback('inventoryActions', function(data, callback)

  if data.action == "exit" then
    CloseInventory()
  
  elseif data.action == "doAction" then
    local i = tonumber(data.item)
    local t = tonumber(data.trigger)
    local runAction = false
    if t == 1 then
      if data.actn == "c" then 
        runAction = true
      end
    else runAction = true
    end
    if runAction then
      TriggerServerEvent('cnr:inventory_action', t, i)
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

