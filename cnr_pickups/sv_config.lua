
local pickups = {  -- An array of pickup types
  [1] = { -- Weapons; `item` will be the WEAPON_NAME, and `qty` shall be the AMMO GIVEN
    { 
      mdl = "w_pi_pistol", -- The model of the object
      icon = 156, -- The radar blip sprite
      item = "WEAPON_PISTOL", -- The actual weapon name to give 
      quantity = function() return math.random(12, 96) end -- How much ammo to provide
    },
    {mdl = "w_pi_pistol50",     icon = 156, item = "WEAPON_PISTOL50", quantity = function() return math.random(12, 96) end},
    {mdl = "w_sg_sawnoff",      icon = 158, item = "WEAPON_SAWNOFFSHOTGUN", quantity = function() return math.random(12, 28) end},
    {mdl = "w_ar_assaultrifle", icon = 150, item = "WEAPON_ASSAULTRIFLE", quantity = function() return math.random(32, 84) end},
    {mdl = "w_ar_carbinerifle", icon = 150, item = "WEAPON_CARBINERIFLE", quantity = function() return math.random(42, 96) end},
    {mdl = "w_sg_pumpshotgun",  icon = 158, item = "WEAPON_PUMPSHOTGUN", quantity = function() return math.random(8, 24) end},
    {mdl = "w_ex_molotov",      icon = 155, item = "WEAPON_MOLOTOV", quantity = function() return math.random(1, 3) end},
    {mdl = "w_ex_grenadefrag",  icon = 152, item = "WEAPON_HANDGRENADE", quantity = function() return math.random(1, 3) end},
  },
  [2] = { -- Armor
    {
      mdl = "replace_me", -- The model of the object
      quantity = function() return math.random(12, 50) end -- The % of armor it provides
    },
    {mdl = "replace_me", quantity = function() return math.random(5, 10) end},
    {mdl = "replace_me", quantity = function() return math.random(60, 85) end},
    {mdl = "replace_me", quantity = function() return 100 end},
  },
  [3] = {
    {-- Healthpacks
      mdl = "replace_me", -- The model of the object
      quantity = function() return math.random(12, 50) end -- The % of health it provides
    },
    {mdl = "replace_me", quantity = function() return math.random(5, 10) end},
    {mdl = "replace_me", quantity = function() return math.random(60, 85) end},
    {mdl = "replace_me", quantity = function() return 100 end},
  }
}

--[[ TABLE: spots
  Key Index => Table:
    occupied (spot taken) => True if the pickup spot is already taken
    types (pType)         => Which pickups are allowed to spawn here (should be at least 1)
    pos (Position)        => Spawn Vector
]]
local spots   = {
  [1] = {occupied = false, types = {1}, pos = vector3(0.0,4.0,70.92)}, -- 1st eligible spawn location
  [2] = {occupied = false, types = {1}, pos = vector3(-1.7,5.25,71.05)}, -- 2nd eligible spawn location
} 


--- DestroyAllPickups()
-- Sets all pickups to available. Used if no players are connected.
function DestroyAllPickups()
  for k,v in pairs (spots) do 
    if v.occupied then v.occupied = false end
  end
end


--- AvailablePickups()
-- Returns a list of available pickup spots.
-- Also gets how many pickups are free, and how many pickups there are total
-- @returns Array where [1] = open spots and [2] = total spots
function AvailablePickups()
  local avSpots = {}
  for k,v in pairs (spots) do 
    if not v.occupied then
      local n = #avSpots + 1
      avSpots[n] = v -- Add available spot to list in Index 1
    end
  end
  return {[1] = avSpots, [2] = #spots}
end


--- ChooseSpotThenOccupy()
-- Picks an available spot then sets it as occupied
-- @return Table of spot chosen, nil if failed
function ChooseSpotThenOccupy()
  local avSpots = {}
  for k,v in pairs (spots) do 
    if not v.occupied then
      local n = #avSpots + 1
      avSpots[n] = k
    end
  end
  if #avSpots > 0 then
    local i = math.random(#avSpots)
    spots[i].occupied = true
    return ( spots[i] )
  end
  return nil
end


function SpotOccupied(n, isUsed)
  if not n then n = 1 end
  if not spots[n] then n = 1 end
  spots[n].occupied = isUsed
end


--- GetPickupFromType()
-- Gets a random pickup type from the type table and handle the spot position
-- @returns mdl, icon, item, qty
function GetPickupFromType(tValue, pos)
  print("DEBUG - TYPE["..tValue.."]")
  if not tValue          then tValue = 1 end
  if not pickups[tValue] then tValue = 1 end
  
  local n        = math.random(#pickups[tValue])
  local retValue = pickups[tValue][n]
  local count    = retValue.quantity()
  return ({
    model    = retValue.mdl,
    blipIcon = retValue.icon,
    name     = retValue.item,
    qty      = count,
    posn     = pos
  })
  
end

