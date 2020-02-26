
RegisterServerEvent('cnr:inventory_update')

local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end


--- EXPORT: ItemAdd()
-- Adds an item with specified quantity to the inventory
-- @param client The server ID of the client to affect. If nil, returns 0
-- @param itemInfo Table with info (see `__resource.lua`)
-- @param quantity The amount to add. If nil, adds 1
-- @return Returns 1 if function was successful, 0 on fail, -1 on error
function ItemAdd(client, itemInfo, quantity)
  if not client then
    cprint("^1[INVENTORY] ^7No Server ID given to ItemAdd() in sv_inventory.lua")
    return 0
  end
  
  if not itemInfo then
    cprint("^1[INVENTORY] ^7No item table given to ItemAdd() in sv_inventory.lua")
    return (-1)
  end
  
  -- Minimum itemInfo requirement
  if not itemInfo['name'] then
    cprint("^1[INVENTORY] ^7No item game name given to ItemAdd() in sv_inventory.lua")
    return (-1)
  end
  
  if not itemInfo['consume'] then itemInfo['consume'] = 0 end
  if not itemInfo['title'] then itemInfo['title'] = itemInfo['name'] end
  local response = exports['ghmattimysql']:executeSync(
    "SELECT InventoryModify(1, 0, @iname, @ititle, @eat)",
    {
      ['iname']  = itemInfo['name'],
      ['ititle'] = itemInfo['title'],
      ['eat']    = itemInfo['consume']
    }
  )
  
  UpdateInventory(client)
  if response < 1 then 
    cprint(
      "^1[INVENTORY] "..
      "^7MySQL indicated an error when running ItemAdd() in sv_inventory.lua"
    )
  else UpdateInventory(client)
  end
  return response
end


--- EXPORT: ItemRemove()
-- Removes an item with specified quantity
-- @param client The server ID of the client to affect
-- @param itemInfo Table with the terms to search for (see `__resource.lua`)
-- @param quantity The amount to remove. If nil, removes the entire item
-- @return Returns 1 if function was successful, 0 on fail, -1 on error
function ItemRemove(client, itemInfo, quantity)
  if not client then
    cprint("^1[INVENTORY] ^7No Server ID given to ItemRemove() in sv_inventory.lua")
    return 0
  end
  
  if not itemInfo then
    cprint("^1[INVENTORY] ^7No item table given to ItemRemove() in sv_inventory.lua")
    return (-1)
  end
  
  -- Minimum itemInfo requirement
  if not itemInfo['name'] then
    cprint("^1[INVENTORY] ^7No item game name given to ItemRemove() in sv_inventory.lua")
    return (-1)
  end
  
  if not itemInfo['consume'] then itemInfo['consume'] = 0 end
  if not itemInfo['title'] then itemInfo['title'] = itemInfo['name'] end
  if not itemInfo['id'] then itemInfo['id'] = 0 end
  local response = exports['ghmattimysql']:executeSync(
    "SELECT InventoryModify(0, @iid, @iname, @ititle, @eat)",
    {
      ['iid']    = itemInfo['id'],
      ['iname']  = itemInfo['name'],
      ['ititle'] = itemInfo['title'],
      ['eat']    = itemInfo['consume']
    }
  )
  
  UpdateInventory(client)
  if response < 1 then 
    cprint(
      "^1[INVENTORY] "..
      "^7MySQL indicated an error when running ItemRemove() in sv_inventory.lua"
    )
  else UpdateInventory(client)
  end
  return response
end


--- EXPORT: ItemModify()
-- Changes the amount of an item a player has
-- @param client The server ID of the client to affect
-- @param itemInfo Table with the terms to search for (see `__resource.lua`)
-- @param quantity The amount to change by. If nil, ignores entirely
-- @return Returns 1 if function was successful, 0 on fail, -1 on error
function ItemModify(client, itemInfo, quantity)
  if not client then
    cprint("^1[INVENTORY] ^7No Server ID given to ItemModify() in sv_inventory.lua")
    return 0
  end
  
  if not itemInfo then
    cprint("^1[INVENTORY] ^7No item table given to ItemModify() in sv_inventory.lua")
    return (-1)
  end
  
  -- Minimum itemInfo requirement
  if not itemInfo['name'] then
    cprint("^1[INVENTORY] ^7No item game name given to ItemModify() in sv_inventory.lua")
    return (-1)
  end
  
  if not itemInfo['consume'] then itemInfo['consume'] = 0 end
  if not itemInfo['title'] then itemInfo['title'] = itemInfo['name'] end
  if not itemInfo['id'] then itemInfo['id'] = 0 end
  local response = exports['ghmattimysql']:executeSync(
    "SELECT InventoryModify(2, @iid, @iname, @ititle, @eat)",
    {
      ['iid']    = itemInfo['id'],
      ['iname']  = itemInfo['name'],
      ['ititle'] = itemInfo['title'],
      ['eat']    = itemInfo['consume']
    }
  )
  
  if response < 1 then 
    cprint(
      "^1[INVENTORY] "..
      "^7MySQL indicated an error when running ItemModify() in sv_inventory.lua"
    )
  else UpdateInventory(client)
  end
  return response
end


--- EXPORT: ItemCount()
-- Returns how much of an item the player has
-- @param client The server ID of the client to affect. If nil, returns 0
-- @param itemInfo Table with the terms to search for (see `__resource.lua`)
-- @return Returns number of items, or 0 if not found
function ItemCount(client, itemInfo)
  if not client then
    cprint("^1[INVENTORY] ^7No Server ID given to ItemCount() in sv_inventory.lua")
    return 0
  end
  
  if not itemInfo then
    cprint("^1[INVENTORY] ^7No item table given to ItemCount() in sv_inventory.lua")
    return (-1)
  end
  
  -- Minimum itemInfo requirement
  if not itemInfo['name'] then
    cprint("^1[INVENTORY] ^7No item game name given to ItemCount() in sv_inventory.lua")
    return (-1)
  end
  
  if not itemInfo['consume'] then itemInfo['consume'] = 0 end
  if not itemInfo['title'] then itemInfo['title'] = itemInfo['name'] end
  if not itemInfo['id'] then itemInfo['id'] = 0 end
  local response = exports['ghmattimysql']:executeSync(
    "SELECT InventoryModify(3, @iid, @iname, @ititle, @eat)",
    {
      ['iid']    = itemInfo['id'],
      ['iname']  = itemInfo['name'],
      ['ititle'] = itemInfo['title'],
      ['eat']    = itemInfo['consume']
    }
  )
  
  if response < 1 then 
    cprint(
      "^1[INVENTORY] "..
      "^7MySQL indicated an error when running ItemCount() in sv_inventory.lua"
    )
  else UpdateInventory(client)
  end
  return response
end


--- EXPORT: GetInventory()
-- Returns the player's inventory to the calling script
-- It's better to call this as needed, instead of storing all this
-- damned info in a global variable. A LOT less overhead.
-- @param client The server ID of the client to affect. If nil returns empty tbl
-- @return Returns table of inventory items.
function GetInventory(client)

  if not client then return {} end
  local uid = exports['cnrobbers']:UniqueId(client)
  
  if uid > 0 then 
    return (
      exports['ghmattimysql']:executeSync(
        "SELECT * FROM inventories WHERE character_id = @u",
        {['u'] = uid}
      )
    )
            
  else return {}
  end
  
end

--- EXPORT: GetWeight()
-- Returns the total weight of the player's inventory
-- @param client The server ID of the client to affect. If nil, returns 0.
-- @return Returns total weight of inventory
function GetWeight(client)

  if not client then return 0 end
  local uid = exports['cnrobbers']:UniqueId(client)
  
  local weight = exports['ghmattimysql']:scalarSync(
    "SELECT SUM(weight * quantity) FROM inventories WHERE character_id = @u",
    {['u'] = uid}
  )
  return weight
end


--- EXPORT: UpdateInventory()
-- Forces an inventory update to the given client
-- @param client The server ID of whose inventory to send the update to
function UpdateInventory(client)
  if not client then return 0 end
  local uid = exports['cnrobbers']:UniqueId(client)
  exports['ghmattimysql']:execute(
    "SELECT * FROM inventories WHERE character_id = @u",
    {['u'] = uid},
    function(invStuff)
      TriggerClientEvent('cnr:inventory_receive', client, invStuff)
    end
  )
end