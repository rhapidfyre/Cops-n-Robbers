
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

dependency 'ghmattimysql'

client_scripts {
  "sh_cnrobbers.lua",
  "cl_cnrobbers.lua"
}

server_scripts {
  "sh_cnrobbers.lua",
  "sv_cnrobbers.lua"
}

server_exports {
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
  'WantedPoints',         -- Tells client their wanted points
  'WantedLevel',          -- Returns Wanted Level (client or others)
  'ChatNotification',     -- A neatly formated Chat Notification function
  'GetWanteds',           -- Returns the wanted list (t[ServerId] = points)
  'GetPlayers',
  'GetClosestPlayer',
}

