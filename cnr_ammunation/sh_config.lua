
local wTranslate = {}


-- icon 110=nonrange 313=gunrange
--[[

  [] = {
    title   = " Ammunation", icon = 110,
    walkup  = vector3(),
    vest    = vector3(),
    clerk   = {
      pos = vector3(), h = .0, 
      mdl = GetHashKey("s_m_m_ammucountry")
    }
  },

]]
stores = {
  [1] = {
    title   = "Pillbox Hill Ammunation", icon = 313,
    walkup  = vector3(22.77, -1107.03, 28.597),
    vest    = vector3(18.4819, -1109.88, 28.597),
    range   = vector3(13.53, -1097.36, 29.8347),
    heading = 332.0,
    clerk   = {
      pos = vector3(22.8847, -1105.48, 29.797), h = 151.0,
      mdl = GetHashKey("s_m_y_ammucity_01")
    }
  },
  [2] = {
    title   = "East L.S. Ammunation", icon = 110,
    walkup  = vector3(841.72, -1033.92, 26.988),
    vest    = vector3(844.78, -1029.94, 26.988),
    heading = 172.0,
    clerk   = {
      pos = vector3(842.615, -1035.64, 28.194), h = 350.0,
      mdl = GetHashKey("s_m_y_ammucity_01")
    }
  },
  [3] = {
    title   = "Vinewood Ammunation", icon = 110,
    walkup  = vector3(252.276, -50.7127, 68.841),
    vest    = vector3(249.683, -46.511, 68.841),
    heading = 240.0,
    clerk   = {
      pos = vector3(254.033, -51.0108, 69.941), h = 65.0,
      mdl = GetHashKey("s_m_y_ammucity_01")
    }
  },
  [4] = {
    title   = "Little Seoul Ammunation", icon = 110,
    walkup  = vector3(-661.587, -934.926, 20.745),
    vest    = vector3(-664.74, -938.915, 20.745),
    heading = 0.0,
    clerk   = {
      pos = vector3(-662.018, -933.084, 21.8292), h = 180.0,
      mdl = GetHashKey("s_m_y_ammucity_01")
    }
  },
  [5] = {
    title   = "Morningwood Ammunation", icon = 110,
    walkup  = vector3(-1305.57, -394.967, 35.545),
    vest    = vector3(-1308.83, -391.008, 35.545),
    heading = 260.0,
    clerk   = {
      pos = vector3(-1303.97, -395.149, 36.6958), h = 80.0,
      mdl = GetHashKey("s_m_y_ammucity_01")
    }
  },
  [6] = {
    title   = "Cypress Flats Ammunation", icon = 313,
    walkup  = vector3(809.502, -2157.73, 28.588),
    vest    = vector3(812.581, -2153.64, 28.588),
    range   = vector3(821.486, -2163.72, 29.619),
    heading = 174.0,
    clerk   = {
      pos = vector3(809.855, -2159.08, 29.619), h = 352.0,
      mdl = GetHashKey("s_m_y_ammucity_01")
    }
  },
}

-- Used to ensure people only use guns the gamemode has approved
-- (AKA the guns in this list)
weaponsList = {
  -- Set ammo to 0 if not a firearm, 1 if throwable (grenade)
  -- qty: Multiples of ammo to purchase
  -- TEMPLATE: [] = {mdl = "WEAPON_", title = "", price = 1000, qty = 1, ammo = 0, aprice = 0},
  -- Setting 'legal = false' ensures it won't be in the ammunation menu
  [1]  = {name = "WEAPON_KNUCKLE",        title = "Brass Knuckles",    price = 1000,  qty = 1, ammo = 0,  aprice = 0},
  [2]  = {name = "WEAPON_KNIFE",          title = "Knife",             price = 90,    qty = 1, ammo = 0,  aprice = 0},
  [3]  = {name = "WEAPON_PISTOL50",       title = "Desert Eagle",      price = 5000,  qty = 1, ammo = 9,  aprice = 10},
  [4]  = {name = "WEAPON_SAWNOFFSHOTGUN", title = "Sawn-off Shotgun",  price = 12500, qty = 1, ammo = 8,  aprice = 25},
  [5]  = {name = "WEAPON_FLAREGUN",       title = "Flare Gun",         price = 5000,  qty = 1, ammo = 1,  aprice = 100},
  [6]  = {name = "WEAPON_PISTOL",         title = "Semi-Auto Pistol",  price = 5000,  qty = 1, ammo = 12, aprice = 5},
  [7]  = {name = "WEAPON_REVOLVER",       title = "357 Magnum",        price = 10000, qty = 1, ammo = 6,  aprice = 0},
  [8]  = {name = "WEAPON_SMG",            title = "Submachine Gun",    price = 1300,  qty = 1, ammo = 30, aprice = 1},
  [9]  = {name = "WEAPON_ASSAULTRIFLE",   title = "Assault Rifle",     price = 1400,  qty = 1, ammo = 30, aprice = 5},
  [10] = {name = "WEAPON_CARBINERIFLE",   title = "Carbine Rifle",     price = 1200,  qty = 1, ammo = 30, aprice = 5},
  [11] = {name = "WEAPON_BULLPUPRIFLE",   title = "Bullpup Rifle",     price = 1650,  qty = 1, ammo = 30, aprice = 5},
  [12] = {name = "WEAPON_MARKSMANRIFLE",  title = "Marksman Rifle",    price = 9500,  qty = 1, ammo = 8,  aprice = 0},
  [13] = {name = "WEAPON_SNIPERRIFLE",    title = "Sniper Rifle",      price = 6000,  qty = 1, ammo = 10, aprice = 0},
  [14] = {name = "WEAPON_PETROLCAN",      title = "Gas Can",           price = 100,   qty = 1, ammo = 1,  aprice = 100},
}

--- EXPORT: GetWeaponNameFromHash()
-- Attempts to translate the weapon's hash into a string name
-- @param The hash key for the weapon
-- @return The string name; If not found, returns "Firearm"
function GetWeaponNameFromHash(hashCode)
  if not hashCode then return "Firearm" end
  if wTranslate[hashCode] then return wTranslate[hashCode] end
  return "Firearm"
end


-- Builds a list of hashcodes to string name
-- Also adds hash as `mdl` to the weaponsList table
Citizen.CreateThread(function()
  for k,v in pairs(weaponsList) do
    v.mdl = GetHashKey(v.name)
    wTranslate[v.mdl] = v.title
    print("DEBUG - wTranslate["..v.mdl.."] = "..v.title)
  end
end)

