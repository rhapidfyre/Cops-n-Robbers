
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
  "UpdateInventory",        -- Called anytime a script modifies the inventory
  "ItemAdd",                -- See notes below
  "ItemRemove",             -- See notes below  
  "ItemModify",             -- See notes below
  "ItemCount",
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