
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

dependency 'cnrobbers'

ui_page "nui/ui.html"

files {
	"nui/ui.html",
	"nui/ui.js", 
	"nui/ui.css",
}

client_scripts {
	'config.lua',
	'cl_delivery.lua'
}
server_scripts {
	'config.lua',
	'sv_delivery.lua'
}