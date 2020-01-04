
-- ammu shared config
-- icon 110=nonrange 313=gunrange
--[[

  [] = {
    title   = " Ammunation", icon = 110,
    walkup  = vector3(),
    walkoff = vector3(),
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
    walkoff = vector3(18.08, -1111.14, 29.810),
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
    walkoff = vector3(844.42, -1031.24, 28.194),
    clerk   = {
      pos = vector3(842.615, -1035.64, 28.194), h = 350.0,
      mdl = GetHashKey("s_m_y_ammucity_01")
    }
  },
}

weaponsList = { -- Set ammo to 0 if not a firearm, 1 if throwable (grenade)
  -- TEMPLATE: [] = {mdl = "WEAPON_", title = "", price = 1000, ammo = 0, aprice = 0},
  [1] = {mdl = "WEAPON_KNUCKLE", title = "Brass Knuckles", price = 1000, ammo = 12, aprice = 5},
  [2] = {mdl = "WEAPON_KNIFE", title = "Desert Eagle", price = 1000, ammo = 12, aprice = 5},
  [3] = {mdl = "WEAPON_PISTOL50", title = "Desert Eagle", price = 1000, ammo = 12, aprice = 5},
  [4] = {mdl = "WEAPON_SAWNOFFSHOTGUN", title = "Sawn-off Shotgun", price = 1000, ammo = 12, aprice = 5},
  [5] = {mdl = "WEAPON_FLAREGUN", title = "Flare Gun", price = 1000, ammo = 0, aprice = 0},
  [6] = {mdl = "WEAPON_PISTOL", title = "Semi-Auto Pistol", price = 1000, ammo = 0, aprice = 0},
  [7] = {mdl = "WEAPON_REVOLVER", title = "357 Magnum", price = 1000, ammo = 0, aprice = 0},
  [8] = {mdl = "WEAPON_SMG", title = "Submachine Gun", price = 1000, ammo = 0, aprice = 0},
  [9] = {mdl = "WEAPON_ASSAULTRIFLE", title = "Assault Rifle", price = 1000, ammo = 0, aprice = 0},
  [10] = {mdl = "WEAPON_CARBINERIFLE", title = "Carbine Rifle", price = 1000, ammo = 0, aprice = 0},
  [11] = {mdl = "WEAPON_BULLPUPRIFLE", title = "Bullpup Rifle", price = 1000, ammo = 0, aprice = 0},
  [12] = {mdl = "WEAPON_MARKSMANRIFLE", title = "Marksman Rifle", price = 1000, ammo = 0, aprice = 0},
  [13] = {mdl = "WEAPON_SNIPERRIFLE", title = "Sniper Rifle", price = 1000, ammo = 0, aprice = 0},
  [14] = {mdl = "WEAPON_PETROLCAN", title = "Gas Can", price = 1000, ammo = 0, aprice = 0},
}