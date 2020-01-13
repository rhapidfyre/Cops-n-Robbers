
--[[
  Cops and Robbers
  Created by RhapidFyre

  These files contain all the stored values used across scripts, such as a
  player's Unique ID, Steam ID, or other values that we wish to store or
  otherwise manipulate, without having to make a Database call or search for
  the information again.

  Contributors:
    -

  Created 08/19/2019
--]]

resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

dependencies {
  'ghmattimysql',
}

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
  'ConsolePrint',         -- Print to the console with "[CNR timestamp]"
  'CurrentZone',          -- Returns the currently active zone
  'UniqueId',             -- See function for more info (sv_cnrobbers.lua)
  'GetFullZoneName'       -- Returns the name as specified in sh_cnrobbers.lua
}

exports {
	'EnumerateObjects',
	'EnumerateVehicles',
	'EnumeratePeds',
	'EnumeratePickups',
  'GetActiveZone',        -- Returns the currently active zone number (number)
  'ChatNotification',     -- Native GTA 5 popup notification (icon, title, sub, msg)
  'GetPlayers',           -- OBSOLETE; Use 'GetActivePlayers()' (Native)
  'GetClosestPlayer',     -- Gets the local client reference of the nearest player
  'ReportPosition',       -- Tells script whether or not to report loc to SQL
  'GetFullZoneName',      -- Returns the name as specified in sh_cnrobbers.lua
  'ListZones'
}

