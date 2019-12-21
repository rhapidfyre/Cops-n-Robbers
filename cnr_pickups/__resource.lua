
--[[
  Cops and Robbers: World Pickup Events
  Created by RhapidFyre

  These files contain all of the functionality regarding pickups around the map.
  A pickup is an item you can find on the ground in the game world that, if
  interacted with, awards the player with the item specified.

  Contributors:
    -

  Created 12/12/2019
--]]

resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

dependency 'cnrobbers'


client_scripts {
  "cl_pickups.lua"
}

server_scripts {
  "sv_config.lua",
  "sv_pickups.lua"
}

server_exports {
}

exports {
}
