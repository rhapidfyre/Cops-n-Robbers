
-- table: `weapons`
-- index: hash
--    title: Proper name of the weapon for display
--    class: 0 = Melee, 1 = Handgun, 2 = Shotgun,
--    3 = Rifle, 4 = Explosive, 5 = Special
--    legal: True = Can be purchased, False = Must be crafted/found
--    ammo: < 1 = Does not use ammo (melee). > 0 = Maximum ammo allowance

--[[
  [GetHashKey("WEAPON_")] = { class = 0, title = "",
    legal = false, ammo = 0, price = 0, cam = {
      x = , y = , z = ,
      rotx = 0.0, roty = 0.0, rotz = 20.0
    }
  },
]]

local weapons = {
  [GetHashKey("WEAPON_KNIFE")] = { class = 0, title = "Knife",
    legal = true, ammo = 0, price = 0, cam = {
      x = -3.1, y = 0.25, z = 0.27,
      rotx = -30.0, roty = 0.0, rotz = 20.0
    }
  },
}