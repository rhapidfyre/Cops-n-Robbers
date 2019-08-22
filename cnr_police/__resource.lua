
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependency 'cnrobbers'

files {
	"nui/ui.html",
  "nui/ui.js",
  "nui/ui.css"
}

client_scripts {
  "cl_disable.lua", -- Disable cops/military/jets/etc
  "cl_config.lua", 
  "cl_police.lua"
}

server_scripts {
  "sv_config.lua",
  "sv_police.lua"
}

server_exports {
  'DutyStatus',
  'CountCops'
}

exports {
  'DutyStatus',
  'DutyAgency',
  'SendDispatch',
}
