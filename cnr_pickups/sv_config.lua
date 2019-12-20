
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
      mdl = "prop_armour_pickup", -- The model of the object
      quantity = function() return math.random(5, 20) end -- The % of armor it provides
    },
    {mdl = "prop_armour_pickup", quantity = function() return math.random(12, 50) end},
    {mdl = "prop_armour_pickup", quantity = function() return math.random(25, 60) end},
  },
  [3] = {
    {-- Healthpacks
      mdl = "p_syringe_01", -- The model of the object
      quantity = function() return math.random(5, 20) end -- The % of health it provides
    },
    {mdl = "prop_ld_health_pack", quantity = function() return math.random(25, 65) end},
    {mdl = "sm_prop_smug_crate_s_medical", quantity = function() return 100 end},
  }
}

--[[ TABLE: spots
  Key Index => Table:
    occupied (spot taken) => True if the pickup spot is already taken
    types (pType)         => Which pickups are allowed to spawn here (should be at least 1)
    pos (Position)        => Spawn Vector
]]
local spots   = {} 


--- UniqueHash()
-- Checks if the hash generated is unique from hashes in `spots`
local function UniqueHash(genHash)
  for k,v in pairs (spots) do 
      if v.sHash == genHash then return false end
  end
  return true
end


--- SetHashForSpot()
-- Creates a hash for each spot for today's game session
-- Ensures players aren't hacking the events to give themselves stuff
function SetHashForSpot(n)

  local temp     = ""
  local goodHash = false
  local chars = {"0", "1", "2", "3", "4", "5", "6", "7", "8", "9",
                "A", "B", "C", "D", "E", "F", "G", "H", "I", "J",
                "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T",
                "U", "V", "W", "X", "Y", "Z"};

  while not goodHash do
    Wait(100)
    for i=1, 8 do
      local idx = math.random(#chars)
      temp = temp..chars[idx]
    end
    
    -- Ensure the hash is Unique
    goodHash = UniqueHash(temp)
  end
  return temp
  
end


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
  
  -- Choose spot
  for k,v in pairs (spots) do 
    if not v.occupied then
      if not v.sHash then 
        v.sHash = SetHashForSpot(k)
      end
      local n = #avSpots + 1
      avSpots[n] = k
    end
  end
  
  -- Then Occupy
  if #avSpots > 0 then
    local i = math.random(#avSpots)
    local key = avSpots[i]
    spots[key].occupied = true
    return ( spots[key] )
  end
  
  return nil
  
end


--- HashMatch()
-- Challenge to check if player gave a valid hash
-- @return Truth value of hash passed
function HashMatch(pHash)
  if not pHash then return false end
  for i = 1, #spots do 
    if spots[i].sHash == pHash then
      if spots[i].occupied then
        spots[i].occupied = false
        return true
      else
        return false
      end
    end
  end
  return false
end


function SpotOccupied(n, isUsed)
  if not n then n = 1 end
  if not spots[n] then n = 1 end
  spots[n].occupied = isUsed
end


--- GetPickupFromType()
-- Gets a random pickup type from the type table and handle the spot position
-- @returns mdl, icon, item, qty
function GetPickupFromType(tValue, pos, hash)

  if not tValue          then tValue = 1 end
  if not pickups[tValue] then tValue = 1 end
  
  local n        = math.random(#pickups[tValue])
  local retValue = pickups[tValue][n]
  local count    = retValue.quantity()
  
  return ({
    pType    = tValue,
    model    = retValue.mdl,
    blipIcon = retValue.icon,
    name     = retValue.item,
    sHash    = hash,
    qty      = count,
    posn     = pos
  })
  
end

