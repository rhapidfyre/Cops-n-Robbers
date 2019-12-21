
--[[
  Cops and Robbers: Clans Resource
  Created by RhapidFyre

  These files contain the functionality to allow players to create clans,
  groups, and be able to team up together either temporarily or on a more
  permanent basis. Anything relating to clans should be in these files; Sending
  clan-only messages should be handled here, but the script may use the chat
  resource to actually display the message.

  ** ** ** ** -- DEBUG -
  NOTE: This resource is currently highly dysfunctional. It is recommended
  to not use this resource until it is more functional

  As such, the primary files for this resource have been commented out.
  ** ** ** **

  Contributors:
    -

  Created 07/22/2019
--]]

resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependency 'cnrobbers'

files {
	"nui/ui.html",
  "nui/ui.js",
  "nui/ui.css"
}

client_scripts {
  --"sh_config.lua",
  --"cl_clans.lua"
}

server_scripts {
  --"sh_config.lua",
  --"sv_clans.lua"
}

server_exports {
  'GetClanTag',     -- Returns the clan tag for the player
}

exports {
}
