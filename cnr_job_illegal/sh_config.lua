
-- shared config
SUPPLY_CTRL = 1
SUPPLY_GUNS = 2
SUPPLY_CHOP = 3


local supplies = {
  [1] = {
    name  = "supplies_controlled", title = "Paraphernalia",
    count = function() return math.random(10, 38) end,
    img   = "syringe"
  },
  [2] = {
    name  = "supplies_gunparts", title = "Gun Parts",
    count = function() return math.random(10, 38) end,
    img   = "gun_part1"
  },
  [3] = {
    name  = "supplies_chopshop", title = "Modparts",
    count = function() return math.random(5, 14) end,
    img   = "gun_part1"
  }
}

-- Where vehicles can be dropped, depending on the active zone
vehDrops = {
  {pos = vector3(947.317, -1697.63, 29.96), zone = 1}, -- Garage in East LS Alleyway
  {pos = vector3(-594.872, -1586.06, 25.89), zone = 1}, -- Near trash yard back door
  {pos = vector3(-1604.1, -826.382, 8.28), zone = 1}, -- Big yellow garage at beach parking
  {pos = vector3(3832.17, 4463.89, 1.86), zone = 2}, -- Hidden Dock
  {pos = vector3(1321.06, 4228.92, 32.16), zone = 2}, -- Grapeseed Dock
  {pos = vector3(2348.1, 3131.99, 46.45), zone = 2}, -- East Joshua Wasteyard
  {pos = vector3(3832.17, 4463.89, 1.86), zone = 3}, -- Paleto Bay Garage
  {pos = vector3(-1803.56, 2992.16, 31.05), zone = 4}, -- Fort Zancudo Hangar
}

function GetSupplyFromEnum(n)
  if not n then n = SUPPLY_CTRL end
  if not supplies[n].name then
    return "supplies_unknown"
  end
  return supplies[n].name
end

function GetSupplyReward(n)
  if not n then n = 1 end
  if not supplies[n] then
    return 1
  end
  return ( supplies[n].count() )
end

function GetSupplyTitle(n)
  if not n then n = 1 end
  if not supplies[n] then return "Unknown Item" end
  if not supplies[n].title then return "Unknown Item" end
  return supplies[n].title
end

function GetSupplyImage(n)
  if not n then n = 1 end
  if not supplies[n] then return "unknown" end
  if not supplies[n].img then return "unknown" end
  return supplies[n].img
end