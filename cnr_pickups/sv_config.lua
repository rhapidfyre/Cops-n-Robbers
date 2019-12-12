
local pickups = {  -- An array of pickup types
  [1] = { -- Weapons; `item` will be the WEAPON_NAME, and `qty` shall be the AMMO GIVEN
    { 
      mdl = "replace_me.mdl", -- The model of the object
      item = "WEAPON_PISTOL", -- The actual weapon name to give 
      qty = function() math.random(12, 96) end -- How much ammo to provide
    },
    {mdl = "replace_me.mdl", item = "WEAPON_PISTOL50", qty = function() math.random(12, 96) end},
    {mdl = "replace_me.mdl", item = "WEAPON_SAWNOFFSHOTGUN", qty = function() math.random(12, 28) end},
    {mdl = "replace_me.mdl", item = "WEAPON_ASSAULTRIFLE", qty = function() math.random(32, 84) end},
    {mdl = "replace_me.mdl", item = "WEAPON_CARBINERIFLE", qty = function() math.random(42, 96) end},
    {mdl = "replace_me.mdl", item = "WEAPON_PUMPSHOTGUN", qty = function() math.random(8, 24) end},
    {mdl = "replace_me.mdl", item = "WEAPON_MOLOTOV", qty = function() math.random(1, 3) end},
    {mdl = "replace_me.mdl", item = "WEAPON_HANDGRENADE", qty = function() math.random(1, 3) end},
  },
  [2] = { -- Armor
    {
      mdl = "replace_me.mdl", -- The model of the object
      qty = function() math.random(12, 50) end -- The % of armor it provides
    },
    {mdl = "replace_me.mdl", qty = function() math.random(5, 10) end},
    {mdl = "replace_me.mdl", qty = function() math.random(60, 85) end},
    {mdl = "replace_me.mdl", qty = 100},
  },
  [3] = { -- Healthpacks
      mdl = "replace_me.mdl", -- The model of the object
      qty = function() math.random(12, 50) end -- The % of health it provides
    },
    {mdl = "replace_me.mdl", qty = function() math.random(5, 10) end},
    {mdl = "replace_me.mdl", qty = function() math.random(60, 85) end},
    {mdl = "replace_me.mdl", qty = 100},
  },
  
}

--[[ TABLE: spots
  Key Index => Table:
    occupied (spot taken) => True if the pickup spot is already taken
    types (pType)         => Which pickups are allowed to spawn here (should be at least 1)
    pos (Position)        => Spawn Vector
]]
local spots   = {
  {occupied = false, types = {}, pos = vector3()}, -- 1st eligible spawn location
  {occupied = false, types = {}, pos = vector3()}, -- 2nd eligible spawn location
} 


--- DestroyAllPickups()
-- Sets all pickups to available. Used if no players are connected.
function DestroyAllPickups()
  for k,v in pairs (spots) do 
    if v.occupied then v.occupied = false end
  end
end


--- AvailablePickups()
-- Gets how many pickups are free, and how many pickups there are total
-- @returns Array where [0] = spots available and [1] = total pickups
function AvailablePickups()
  local i = 0
  for k,v in pairs (spots) do 
    if not v.occupied then i = i + 1 end
  end
  return {i, #spots}
end


--- IsPickupAvailable()
-- Checks if the requested pickup is available
-- @param n The index of the pickup chosen
-- @returns True if pickup can be created, false if it's already taken
function IsPickupAvailable(n)
  if n then
    if pickups[n] then 
      if not pickups[n].occupied then 
        return true
      end
    end
  end
  return false
end


--- GetPickupLocation()
-- Gets the spawn position of the pickup
-- @param
-- @returns 
function GetPickupLocation(n)
  if n then
    if pickups[n] then 
      if pickups[n].pos then 
        return pickups[n].pos
      end
    end
  end
  return nil
end


