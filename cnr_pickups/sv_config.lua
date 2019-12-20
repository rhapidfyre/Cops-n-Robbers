
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


--- DestroyAllPickups()
-- Sets all pickups to available. Used if no players are connected.
function DestroyAllPickups()

  -- SQL: Remove all waiting pickups from the table
  exports['GHMattiMySQL']:execute(
    "DELETE FROM pickup_waiting"
  )
  
end