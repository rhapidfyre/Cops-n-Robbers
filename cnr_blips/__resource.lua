
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

dependencies  {'cnrobbers'}


client_scripts {
  "cl_blips.lua"
}

server_scripts {
  "sv_blips.lua"
}

server_exports {

}

exports {
  'CreateBlipForPlayer',
  'RemoveBlipForPlayer',
  'GetPlayerBlip'
}
