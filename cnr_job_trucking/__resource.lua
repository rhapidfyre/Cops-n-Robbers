
--[[
  Cops and Robbers: 
  Created by RhapidFyre

  Contributors:
    -

  Created //2020
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
}

server_scripts {
  "sh_config.lua",
  "sv_config.lua",
}

server_exports {
}

exports {
}
