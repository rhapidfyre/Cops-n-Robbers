
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependency 'cnrobbers'

files {
	"nui/ui.html",
  "nui/ui.js",
  "nui/ui.css",
  "nui/jail.png",
}

client_scripts {
  "cl_disable.lua", -- Disable cops/military/jets/etc
  "cl_config.lua", 
  "cl_police.lua",
  "cl_prison.lua",
}

server_scripts {
  "sv_config.lua",
  "sv_police.lua",
  "sv_prison.lua"
}

server_exports {
  'DutyStatus',   
  'Imprison',     -- Put player in Prison
  'Jail',         -- Put player in Jail
  'Probation',    -- Release from Jail
  'Parole',       -- Release from Prison
  'CountCops'
}

exports {
  'DutyStatus',
  'DutyAgency',
  'SendDispatch',
  'JailStatus',     -- Allows client to check if someone is in jail/prison
}
