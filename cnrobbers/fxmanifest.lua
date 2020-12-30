
fx_version 'cerulean'
game 'gta5'

author 'RhapidFyre'
description '5M Cops & Robbers'
version '0.0.1'

dependencies {'spawnmanager', 'ghmattimysql'}

ui_page "nui/ui.html"

files {
  -- HTML Elements
	"nui/ui.css", "nui/ui.js", "nui/ui.html",
  "nui/wanted.css",   "nui/creator.css",
  
  -- Images & Animations
	"nui/cop.gif",	    "nui/robber.gif",	  "nui/logo.gif",
  "nui/stars/1.png",  "nui/stars/2.png",  "nui/stars/3.png",
  "nui/stars/4.png",  "nui/stars/5.png",  "nui/stars/6.png",
  "nui/stars/7.png",  "nui/stars/8.png",  "nui/stars/9.png",
  "nui/stars/10.png", "nui/stars/11.png", "nui/stars/a.png",
  "nui/stars/b.png",  "nui/stars/c.png",  "nui/crimefree.png"
	"nui/pics/0.png",	  "nui/pics/1.png",	  "nui/pics/2.png",
	"nui/pics/3.png",	  "nui/pics/4.png",	  "nui/pics/5.png",
	"nui/pics/6.png",	  "nui/pics/7.png",	  "nui/pics/8.png",
	"nui/pics/9.png",	  "nui/pics/10.png",	"nui/pics/11.png",
	"nui/pics/12.png",	"nui/pics/13.png",	"nui/pics/14.png",
	"nui/pics/15.png",  "nui/pics/16.png",	"nui/pics/17.png",
	"nui/pics/18.png",	"nui/pics/19.png",	"nui/pics/20.png",
	"nui/pics/21.png",	"nui/pics/22.png",	"nui/pics/23.png",
	"nui/pics/24.png",	"nui/pics/25.png",	"nui/pics/26.png",
	"nui/pics/27.png",	"nui/pics/28.png",	"nui/pics/29.png",
	"nui/pics/30.png",	"nui/pics/31.png",	"nui/pics/32.png",
	"nui/pics/33.png",	"nui/pics/34.png",	"nui/pics/35.png",
	"nui/pics/36.png",	"nui/pics/37.png",	"nui/pics/38.png",
	"nui/pics/39.png",	"nui/pics/40.png",	"nui/pics/41.png",
	"nui/pics/42.png",	"nui/pics/43.png",	"nui/pics/44.png",
	"nui/pics/45.png",
}

client_scripts {"ent_enum.lua", "client/*.lua"}
server_scripts {"server/*.lua"}
shared_scripts {"config.lua","shared/*.lua"}

--[[----
	Exports; We want to use these functions from other resources
--]]----

server_exports {

  'GetMetaTable',         -- Retrieves the CNR gamemode metatable
  'SetMetaTable',         -- Adds [1] to CNR metatable at index [2] with data [3]

  'ConsolePrint',         -- Print to the console with "[CNR timestamp]"
  'CurrentZone',          -- Returns the currently active zone
  'UniqueId',             -- See function for more info (sv_cnrobbers.lua)
  'GetFullZoneName',      -- Returns the name as specified in shared/zones.lua
  'GetZoneNumber',
  'GetActiveZone',        -- Returns the currently active zone number (number)

  -- CRIME INFORMATION
  'GetCrimeName',         -- Returns the proper title of the crime
  'GetCrimeTime',         -- Returns the time (in seconds) of the crime's punishment
  'GetCrimeFine',         -- Returns the crime's fee (in dollars) of the crime's punishment
  'IsCrimeFelony',        -- Returns whether or not the crime is felony (able to go over 40 points)
  'GetCrimeWeight',       -- Returns the level of severity of the crime (higher = more severe)
  'DoesCrimeExist',       -- Returns true if the given parameter exists in the crimes list
  'AddCrime',             --[[ Allows other scripts to add crimes to the list
                               FORMAT:
                                args[1]: Name of Charge - Unbroken string (no spaces)
                                args[2]: Table
                                    title, weight, minTime, maxTime, isFelony, fine
                                    'fine' must be a function returning a value
                          Returns false if crime already exists or had an error
                          Returns true if crime was successfully added
]]

  -- UTILITY/HELPER FUNCTIONS
  'Round',                -- Rounds args[1] to args[2] decimal places
  'ternary',              -- Evaluats args[1], returns args[2] on true or args[3] on false
  'bitoper',              -- Returns TRUE if args[1] contains args[2] (bitoper A & B)
  'splitstring',          -- Returns a table of args[1] string split by args[2] char
  'ValidatePlate',        -- Removes all spaces and nonvalid characters from a license plate args[1]
  'FormatHTMLDate',       -- Converts an HTML date (args[1]) string to MM/DD/YYYY
}

exports {

  'GetMetaTable',         -- Retrieves the CNR gamemode metatable
  'SetMetaTable',         -- Adds [1] to CNR metatable at index [2] with data [3]

	'EnumerateObjects',
	'EnumerateVehicles',
	'EnumeratePeds',
	'EnumeratePickups',
  
  'DutyStatus',
  'GetActiveZone',        -- Returns the currently active zone number (number)
  'ChatNotification',     -- Native GTA 5 popup notification (icon, title, sub, msg)
  'GetClosestPlayer',     -- Gets the local client reference of the nearest player
  'GetFullZoneName',      -- Returns the name as specified in sh_cnrobbers.lua
  'GetWanteds',           -- Returns the wanted player list
  'ListZones',
  'InActiveZone',         -- Returns true if the player is in the active play zone
  'CrimeFreeZone',        -- Returns true if the player is in a Crime Free Zone

  -- UTILITY/HELPER FUNCTIONS
  'Round',                -- Rounds args[1] to args[2] decimal places
  'ternary',              -- Evaluats args[1], returns args[2] on true or args[3] on false
  'bitoper',              -- Returns TRUE if args[1] contains args[2] (bitoper A & B)
  'splitstring',          -- Returns a table of args[1] string split by args[2] char
  'ValidatePlate',        -- Removes all spaces and nonvalid characters from a license plate args[1]
  'FormatHTMLDate',       -- Converts an HTML date (args[1]) string to MM/DD/YYYY
}
