
--[[
  Cops and Robbers: Inventory Resource
  Created by Michael Harris ( mike@harrisonline.us )
  02/24/2020

  This file contains all inventory related information as well as
  interfaces. Adding, removing, manipulating items
--]]


resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependencies  {'cnrobbers','ghmattimysql'}

files {
	"nui/ui.html",  "nui/ui.js",  "nui/ui.css",
}

client_scripts {
  "sh_config.lua",
  "cl_inventory.lua"
}

server_scripts {
  "sh_config.lua",
  "sv_inventory.lua"
}

server_exports {
  "UpdateInventory",      -- Called anytime a script modifies the inventory
  "ItemAdd",              -- See notes below
  "ItemRemove",           -- See notes below
  "GetInventory",
  "GetWeight"
}

exports {
  "GetInventory",
  "GetWeight"
}

--[[

  NOTES
    itemInfo:
      ['id']      = Database ID # of the item (not an option for 'ADD')
      ['name']    = The game name of the item ('drink_beer')
      ['title']   = The proper name of them item ('Beer')
      ['consume'] = True if useable, false if not
      
]]