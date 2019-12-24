
--[[
  Cops and Robbers: Admin Resource
  Created by RhapidFyre

  Contributors:
    -

  Created 12/21/2019
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
  "cl_admin.lua"
}

server_scripts {
  "sv_admin.lua"
}

server_exports {
  'AdminLevel',     -- Returns the clan tag for the player
}

exports {
  'MyAdminLevel'
}