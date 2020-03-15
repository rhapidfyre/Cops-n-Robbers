
--[[
  Cops and Robbers: 
  Created by RhapidFyre

  Contributors:
    -

  Created //2020
--]]

resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependencies {'baseevents', 'cnrobbers'}

files {
	"nui/ui.html", "nui/ui.js", "nui/ui.css",
  "nui/img/cocaine.png", "nui/img/syringe.png",
  "nui/img/weed.png", "nui/img/gun_parts1.png"
}

client_scripts {
  "sh_config.lua",
  "cl_config.lua",
  "cl_car_crimes.lua",
  "cl_trafficking.lua"
}

server_scripts {
  "sh_config.lua",
  "sv_config.lua",
  "sv_car_crimes.lua",
  "sv_trafficking.lua"
}

server_exports {
}

exports {
}
