
--[[
  Cops and Robbers: Cash / Banking / Money Transaction(s)
  Created by RhapidFyre

  These files contain all of the chat functionality, such as chat templates,
  discord notifications, and more. Eventually, this resource will replace the
  FiveM default chat resource. In the interest of time, this currently just
  utilizes the base chat resource to get the game working.

  Contributors:
    -

  Created 08/19/2019
--]]

resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependencies {'cnrobbers', 'chat'}

files {
	"nui/ui.html",  "nui/ui.js",  "nui/ui.css",
}


client_scripts {
  "cl_chat.lua"
}

server_scripts {
  "sv_config.lua",
  "sv_chat.lua"
}

server_exports {
  'DiscordMessage' -- color (decimal), name, message, footer, isCopMessage
}

exports {
  -- Goes to the custom notification NUI
  'PushNotification', -- type(1=crime,2=law,3=general), title, message
  'ChatNotification'
}
