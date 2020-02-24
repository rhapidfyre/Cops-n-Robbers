
--[[
  Cops and Robbers: Inventory Resource
  Created by Michael Harris ( mike@harrisonline.us )
  02/24/2020

  This file contains all inventory related information as well as
  interfaces. Adding, removing, manipulating items as well as 24/7 purchasing
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
  "nui/crimefree.png"
}

client_scripts {
  "sh_config.lua",
  "cl_config.lua",
  "sh_inventory.lua",
  "cl_inventory.lua"
}

server_scripts {
  "sh_config.lua",
  "sv_config.lua",
  "sh_inventory.lua",
  "sv_inventory.lua"
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

