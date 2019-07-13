
--[[
  Cops and Robbers Client Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  05/11/2019
  
  This file contains all information that will be stored, used, and
  manipulated by any CNR scripts in the gamemode. For example, a
  player's level will be stored in this file and then retrieved using
  an export; Rather than making individual SQL queries each time.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

function ChatNotification(icon, title, subtitle, message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	SetNotificationMessage(icon, icon, false, 2, title, subtitle, "")
	DrawNotification(false, true)
	PlaySoundFrontend(-1, "GOON_PAID_SMALL", "GTAO_Boss_Goons_FM_SoundSet", 0)
  return true
end
RegisterNetEvent('cnr:chat_notify')
AddEventHandler('cnr:chat_notify', function(icon, title, subt, msg)
  ChatNotification(icon, title, subt, msg)
end)

RegisterCommand('zones', function()
  TriggerEvent('chat:addMessage', {
    color = {0,200,0},
    multiline = false,
    args = {
      "Zone 1",
      "Los Santos (All), LS Airport, Port of L.S., Racetrack, Mirror Park"
    }
  })
  TriggerEvent('chat:addMessage', {
    color = {0,200,0},
    multiline = false,
    args = {
      "Zone 2",
      "Palomino, Tataviam, Senora Desert, Sandy Shores, Harmony, Prison."
    }
  })
  TriggerEvent('chat:addMessage', {
    color = {0,200,0},
    multiline = false,
    args = {
      "Zone 3",
      "Zancudo, Chumash, Great Chaparral, Mount Josiah, Vinewood Hills, Stab City."
    }
  })
  TriggerEvent('chat:addMessage', {
    color = {0,200,0},
    multiline = false,
    args = {
      "Zone 4",
      "Paleto Bay, Mount Chiliad, Chiliad Wilderness, Mount Gordo, Grapeseed."
    }
  })
  local myPos = GetEntityCoords(PlayerPedId())
  local zn    = GetNameOfZone(myPos.x, myPos.y, myPos.z)
  local zName = zoneByName[zn]
  if zName.z then 
    TriggerEvent('chat:addMessage', {
      color = {0,200,0},
      multiline = false,
      args = {
        "Your Position",
        (zName.name).." (Zone #"..(zName.z)..")"
      }
    })
  else
    TriggerEvent('chat:addMessage', {
      color = {0,200,0},
      multiline = false,
      args = {
        "Your Zone",
        "Not located; You might be in the sky, at sea, or in an area unscripted."
      }
    })
  end
end)