
--[[
  Cops and Robbers: Wanted Scripts (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  07/13/2019
  
  This file keeps track of various affects from being wanted, such as 
  the wanted player HUD, clear/most wanted messages, etc.
  
  This file does NOT contain the current wanted level, robbery missions,
  or other functions of criminal activity.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

RegisterNetEvent('cnr:cl_wanted_client')
AddEventHandler('cnr:cl_wanted_client', function(ply, wp)
  if GetPlayerFromServerId(ply) == PlayerId() then
    local wlevel = math.floor(wp/10) + 1
    if wp == 0 then 
      SendNUIMessage({ nostars = true })
    elseif wp > 100 then
      SendNUIMessage({ mostwanted = true })
    else
      SendNUIMessage({ stars = wlevel })
    end
  end
end)