
--[[
  Cops and Robbers: Scoreboard / Overhead Name (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  07/13/2019
  
  This file handles all scoreboard functionality and overhead names
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]


Citizen.CreateThread(function()
	showList = false
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(0, 27) then -- INPUT_PHONE
			if not showList then
				local players = {}
				local plys = exports['cnrobbers']:GetPlayers()
				for _,i in ipairs(plys) do
        
					local uname    = GetPlayerName(i)
					local svid     = GetPlayerServerId(i)
          
					table.insert(players, '<tr>'..
            '<th>'..(GetPlayerServerId(i))..'</th>'..
            '<td>'..(rpname)..'</td>'..
            '</tr>'
          )
          
				end
				SendNUIMessage({ text = table.concat(players) })
				showList = true
				
				while showList do
					Citizen.Wait(0)
					if (IsControlReleased(0, 27)) then
						showList = false
						SendNUIMessage({
							meta = 'close'
						})
						break
					end
				end
			end
		end
	end
end)