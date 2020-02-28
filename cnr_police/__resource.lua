
--[[
  Cops and Robbers: Law Enforcement
  Created by RhapidFyre

  These files contain all of the law enforcement scripts. Prison, jail, tickets,
  going on and off duty, handcuffing, etc. Anything revolving around law
  enforcement should be in this resource.

  -- DEBUG - Developer's Note:
  To avoid clutter, major components of the law enforcement system, such as
  PRISON versus POLICE PERMISSIONS should be in separate files, or even
  subdirectories.

  Contributors:
    -

  Created 07/12/2019
--]]

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
  'CountCops',
  'DispatchPolice',
  'ReleaseFugitive',
  'ImprisonClient',
}

exports {
  'DutyStatus',
  'DutyAgency',
  'SendDispatch',
  'JailStatus',     -- Allows client to check if someone is in jail/prison
  'CopRank',
}
