
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependencies  {'cnrobbers','cnr_police'}

files {
	"nui/ui.html",
  "nui/ui.js",
  "nui/ui.css"
}

client_scripts { 
  "cl_score.lua"
}

server_scripts {
  "sv_score.lua"
}

server_exports {
}

exports {
}
