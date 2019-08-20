
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

dependency 'ghmattimysql'

client_scripts {
  "ent_enum.lua",         -- Entity Enumeration
  "sh_cnrobbers.lua",
  "cl_cnrobbers.lua"
}

server_scripts {
  "sh_cnrobbers.lua",
  "sv_cnrobbers.lua"
}

server_exports {
  'ConsolePrint',
  'CurrentZone',
  'GetUniqueId',
  'GetFullZoneName'
}

exports {
	'EnumerateObjects',
	'EnumerateVehicles',
	'EnumeratePeds',
	'EnumeratePickups',
  'GetActiveZone',
  'ChatNotification',     -- A neatly formatted Chat Notification function
  'GetPlayers',           -- OBSOLETE; Use 'GetActivePlayers()' (Native)
  'GetClosestPlayer',
}

