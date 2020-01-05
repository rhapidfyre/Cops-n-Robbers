
-- ammu shared config
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
    walkup  = vector3(841.72, -1033.92, 27.701),
    clerk   = {
      pos = vector3(842.615, -1035.64, 28.194), h = 350.0,
      mdl = GetHashKey("s_m_y_ammucity_01")
    }
  },
}

weaponsList = {
  -- Set ammo to 0 if not a firearm, 1 if throwable (grenade)
  -- qty: Multiples of ammo to purchase
  -- TEMPLATE: [] = {mdl = "WEAPON_", title = "", price = 1000, qty = 1, ammo = 0, aprice = 0},
  [1] = {mdl = "WEAPON_KNUCKLE",        title = "Brass Knuckles",   price = 1000,  qty = 1, ammo = 0, aprice = 0},
  [2] = {mdl = "WEAPON_KNIFE",          title = "Desert Eagle",     price = 90,    qty = 1, ammo = 0, aprice = 0},
  [3] = {mdl = "WEAPON_PISTOL50",       title = "Desert Eagle",     price = 5000,  qty = 1, ammo = 9, aprice = 10},
  [4] = {mdl = "WEAPON_SAWNOFFSHOTGUN", title = "Sawn-off Shotgun", price = 12500, qty = 1, ammo = 8, aprice = 25},
  [5] = {mdl = "WEAPON_FLAREGUN",       title = "Flare Gun",        price = 5000,  qty = 1, ammo = 1, aprice = 100},
  [6] = {mdl = "WEAPON_PISTOL",         title = "Semi-Auto Pistol", price = 5000,  qty = 1, ammo = 12, aprice = 5},
  [7] = {mdl = "WEAPON_REVOLVER",       title = "357 Magnum",       price = 10000, qty = 1, ammo = 6, aprice = 0},
  [8] = {mdl = "WEAPON_SMG",            title = "Submachine Gun",   price = 1300,  qty = 1, ammo = 30, aprice = 1},
  [9] = {mdl = "WEAPON_ASSAULTRIFLE",   title = "Assault Rifle",    price = 1400,  qty = 1, ammo = 30, aprice = 5},
  [10] = {mdl = "WEAPON_CARBINERIFLE",  title = "Carbine Rifle",    price = 1200,  qty = 1, ammo = 30, aprice = 5},
  [11] = {mdl = "WEAPON_BULLPUPRIFLE",  title = "Bullpup Rifle",    price = 1650,  qty = 1, ammo = 30, aprice = 5},
  [12] = {mdl = "WEAPON_MARKSMANRIFLE", title = "Marksman Rifle",   price = 9500,  qty = 1, ammo = 8, aprice = 0},
  [13] = {mdl = "WEAPON_SNIPERRIFLE",   title = "Sniper Rifle",     price = 6000,  qty = 1, ammo = 10, aprice = 0},
  [14] = {mdl = "WEAPON_PETROLCAN",     title = "Gas Can",          price = 100,   qty = 1, ammo = 1, aprice = 100},
}