
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependency 'cnrobbers'

files {
	"nui/ui.html",
  "nui/ui.js",
  "nui/ui.css"
}

client_scripts {
  "config.lua", 
  "cl_clans.lua"
}

server_scripts {
  "config.lua",
  "sv_clans.lua"
}

server_exports {
}

exports {
}
