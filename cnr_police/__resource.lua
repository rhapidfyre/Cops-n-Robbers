
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
	"nui/ui.html", "nui/ui.js", "nui/ui.css",
  "nui/jail.png", "nui/fine.png",
  --"nui/sfx/codes/adw.ogg",
  --"nui/sfx/codes/assault.ogg",
  --"nui/sfx/codes/atm.ogg",
  --"nui/sfx/codes/brandish-leo.ogg",
  --"nui/sfx/codes/brandish-npc.ogg",
  --"nui/sfx/codes/brandish.ogg",
  --"nui/sfx/codes/burglary.ogg",
  --"nui/sfx/codes/carjack-npc.ogg",
  --"nui/sfx/codes/carjack.ogg",
  --"nui/sfx/codes/discharge.ogg",
  --"nui/sfx/codes/gta-npc.ogg",
  --"nui/sfx/codes/gta.ogg",
  --"nui/sfx/codes/jailbreak.ogg",
  --"nui/sfx/codes/kidnapping-npc.ogg",
  --"nui/sfx/codes/kidnapping.ogg",
  --"nui/sfx/codes/mans-veh.ogg",
  --"nui/sfx/codes/manslaughter.ogg",
  --"nui/sfx/codes/murder-leo.ogg",
  --"nui/sfx/codes/murder.ogg",
  --"nui/sfx/codes/prisonbreak.ogg",
  --"nui/sfx/codes/robbery-bank.ogg",
  --"nui/sfx/codes/robbery-sa.ogg",
  --"nui/sfx/codes/robbery.ogg",
  --"nui/sfx/codes/solicitation.ogg",
  --"nui/sfx/codes/theft-grand.ogg",
  --"nui/sfx/codes/theft-petty.ogg",
  --"nui/sfx/codes/trafficking.ogg",
  --"nui/sfx/codes/unknown-crime.ogg",
  --"nui/sfx/codes/unknown-drugs.ogg",
  --"nui/sfx/codes/unpaid.ogg",
  --"nui/sfx/codes/vandalism.ogg",
  --"nui/sfx/codes/.ogg",
}

client_scripts {
  "@NativeUILua_Reloaded/src/NativeUIReloaded.lua",
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
