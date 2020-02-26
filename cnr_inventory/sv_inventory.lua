
RegisterServerEvent('cnr:inventory_update')

--- EXPORT: ItemAdd()
-- Adds an item with specified quantity to the inventory
-- @param itemInfo Table with info (see `__resource.lua`)
-- @param quantity The amount to add. If nil, adds 1
function ItemAdd()
  UpdateInventory(client)
end


--- EXPORT: ItemRemove()
-- Removes an item with specified quantity
-- @param itemInfo Table with the terms to search for (see `__resource.lua`)
-- @param quantity The amount to remove. If nil, removes the entire item
function ItemRemove()
  UpdateInventory(client)
end


--- EXPORT: ItemModify()
-- Changes the amount of an item a player has
-- @param itemInfo Table with the terms to search for (see `__resource.lua`)
-- @param quantity The amount to change by. If nil, ignores entirely
function ItemModify()
  UpdateInventory(client)
end


--- EXPORT: ItemCount()
-- Returns how much of an item the player has
-- @param itemInfo Table with the terms to search for (see `__resource.lua`)
function ItemCount()
  local count = 0
  return count
end


--- EXPORT: GetInventory()
-- Returns the player's inventory to the calling script
-- It's better to call this as needed, instead of storing all this
-- damned info in a global variable. A LOT less overhead.
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