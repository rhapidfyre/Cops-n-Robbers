
fx_version 'cerulean'
game 'gta5'

author 'RhapidFyre'
description '5MCNR Management Resource'
version '0.0.1'

dependency 'cnrobbers'

ui_page "nui/ui.html"

files {
	"nui/ui.css", "nui/ui.js", "nui/ui.html",
}

client_scripts {"client/*.lua"}
server_scripts {"server/*.lua"}
shared_scripts {"shared/*.lua"}

--[[----
	Exports; We want to use these functions from other resources
--]]----

server_exports {} -- Anything exportable should be plugged into 'cnrobbers'
exports {}        -- Anything exportable should be plugged into 'cnrobbers'
-- Otherwise this resource becomes a dependency