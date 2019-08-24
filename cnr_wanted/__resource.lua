
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
  'WantedLevel',
  'WantedPoints',
  'CrimePoints',
  'CrimeName',
}

exports {
  'CrimeList',
  'GetCrimeName',
  'GetCrimeFine',
  'GetCrimeTime',
  'GetCrimeWeight',
  'IsCrimeFelony',
  'GetWanteds',
  'WantedLevel',
  'WantedPoints',
  'CrimeName',
}

