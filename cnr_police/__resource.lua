
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependency 'cnrobbers'

files {
	"nui/ui.html",
  "nui/ui.js",
  "nui/ui.css",
  "nui/jail.png",
  "nui/fine.png",
}

client_scripts {
  "sh_prison.lua",
  "cl_disable.lua",         -- Disable cops/military/jets/etc
  "cl_config.lua",          -- Client settings for prison/police scripts
  "cl_police.lua",          -- Law Enforcement Scripts
  "cl_prison.lua",          -- Prison/Jail/Ticket Handling
}

server_scripts {
  "sh_prison.lua",
  "sv_config.lua",          -- Server settings
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
  'CopRank',
}
