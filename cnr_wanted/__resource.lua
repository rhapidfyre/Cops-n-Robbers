
--[[
  Cops and Robbers: Wanted Scripts
  Created by RhapidFyre

  These files handle players criminal activity, that isn't scripted or part of
  a job such as a robbery or heist. Handles things like carjacking, shooting
  at other players, and shooting in public.

  Contributors:
    -

  Created 07/12/2019
--]]

resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependencies  {'cnrobbers','ghmattimysql'}

files {
	"nui/ui.html",  "nui/ui.js",  "nui/ui.css",
  "nui/stars/1.png",  "nui/stars/2.png",
  "nui/stars/3.png",  "nui/stars/4.png",
  "nui/stars/5.png",  "nui/stars/6.png",
  "nui/stars/7.png",  "nui/stars/8.png",
  "nui/stars/9.png",  "nui/stars/10.png",
  "nui/stars/11.png", "nui/stars/a.png",
  "nui/stars/b.png",  "nui/stars/c.png",
}

client_scripts {
  "sh_wanted.lua",
  "cl_wanted.lua"
}

server_scripts {
  "sv_crimes.lua",
  "sh_wanted.lua",
  "sv_wanted.lua"
}

server_exports {
  'GetCrimeName',
  'GetCrimeFine',
  'GetCrimeTime',
  'GetCrimeWeight',
  'IsCrimeFelony',
  'DoesCrimeExist',
  'WantedLevel',
  'WantedPoints',
  'CrimePoints',
  'CrimeName',
  'CrimeList',
}

exports {
  'CrimeList',
  'GetCrimeName',
  'GetCrimeFine',
  'GetCrimeTime',
  'GetCrimeWeight',
  'IsCrimeFelony',
  'DoesCrimeExist',
  'GetWanteds',
  'WantedLevel',
  'WantedPoints',
  'CrimeName',
  'HasRightsToVehicle',
}

