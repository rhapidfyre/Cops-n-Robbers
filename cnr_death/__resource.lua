
--[[
  Cops and Robbers: Death Scripts
  Created by RhapidFyre

  These files contain handling death, since we don't quite want to use the
  base spawnmanager method of death handling.

  As this resource is not currently developed, the plan is:
    - Player dies, and can choose two options:
      1) Wait for EMS. Player will respawn with all their belongings
      2) Respawn at hospital, and lose anything on hand (weapons, cash)

  Contributors:
    -

  Created 09/09/2019
--]]

resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

dependency 'cnrobbers'

files {
  "nui/ui.html", "nui/ui.js", "nui/ui.css", "nui/img/passive.png"
}

client_scripts {
  "cl_death.lua"
}

server_scripts {
  "sv_death.lua"
}

server_exports {
  "IsPassive",
}

exports {
}
