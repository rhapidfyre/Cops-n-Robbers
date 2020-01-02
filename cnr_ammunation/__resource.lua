
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
	"nui/ui.html",
  "nui/ui.js",
  "nui/ui.css"
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