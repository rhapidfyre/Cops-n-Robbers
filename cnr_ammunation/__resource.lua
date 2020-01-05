
--[[
  Cops and Robbers: Ammunation & Weapon Scripts
  Created by RhapidFyre

  These files contain all the features to purchasing and obtaining weapons
  from stores. Eventually the `cnr_pickups` resource will be merged in here

  Contributors:
    -

  Created 01/01/2020
--]]

resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependency 'cnrobbers'

files {
  "nui/img/WEAPON_PISTOL50.png", "nui/img/WEAPON_SAWNOFFSHOTGUN.png",
  "nui/img/WEAPON_PISTOL.png", "nui/img/WEAPON_KNUCKLE.png",
  "nui/img/WEAPON_ASSAULTRIFLE.png", "nui/img/WEAPON_CARBINERIFLE.png",
  "nui/img/WEAPON_PETROLCAN.png", "nui/img/WEAPON_PUMPSHOTGUN.png",
  "nui/img/WEAPON_SMG.png", "nui/img/WEAPON_REVOLVER.png",
  "nui/img/WEAPON_BULLPUPRIFLE.png", "nui/img/WEAPON_MARKSMANRIFLE.png",
  "nui/img/WEAPON_FLAREGUN.png", "nui/img/WEAPON_KNIFE.png",
  "nui/ui.html", "nui/ui.js", "nui/ui.css"
}

client_scripts {
  "sh_config.lua",
  "cl_config.lua",
  "cl_ammunation.lua"
}

server_scripts {
  "sh_config.lua",
  "sv_config.lua",
  "sv_ammunation.lua"
}

server_exports {}

exports {
  'InsideGunRange' -- Checks if player is in a no-crime reporting area (gun range)
}