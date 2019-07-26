
--[[
  Cops and Robbers: Scoreboard / Overhead Name (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  07/13/2019
  
  This file handles all scoreboard functionality and overhead names
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

local disIdentifier = 128
local ignorePlayerNameDistance = false
local wantedPlayers = {}
local copPlayers    = {}
local plyBlips      = {}

local copColors = {
  [1]  = {190,200,255}, [2]  = {185,185,255},
  [3]  = {160,160,255}, [4]  = {140,140,255},
  [5]  = {120,120,255}, [6]  = {100,100,255},
  [7]  = {80,80,255},   [8]  = {60,60,255},
  [9]  = {40,40,255},   [10] = {0,0,255},
}

local wantedColors = {
  [1]  = {255,225,125},  [2]  = {255,200,100},
  [3]  = {255,190,86},  [4]  = {255,146,70},
  [5]  = {255,130,60},  [6]  = {255,122,45},
  [7]  = {255,112,32},  [8]  = {255,105,25},
  [9]  = {255,90,15},   [10] = {255,78,0},
  [11] = {255, 40, 0}
}

local blipWanted = {
  [1] = 16, [2] = 5, [3] = 0, [4] = 0, [5] = 0
}

local blipCops   = {
  [1] = 16, [2] = 5, [3] = 0, [4] = 0, [5] = 0
}

function sanitize(txt)
    local replacements = {
        ['&' ] = '&amp;', 
        ['<' ] = '&lt;', 
        ['>' ] = '&gt;', 
        ['\n'] = '<br/>'
    }
    return txt
        :gsub('[&<>\n]', replacements)
        :gsub(' +', function(s) return ' '..('&nbsp;'):rep(#s-1) end)
end


-- Scoreboard
Citizen.CreateThread(function()
	showList = false
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(0, 27) then -- INPUT_PHONE
			if not showList then
				local players = {}
				local plys = GetActivePlayers()
				for _,i in ipairs(plys) do
					local uname = GetPlayerName(i)
					local svid  = GetPlayerServerId(i)
          
          if wantedPlayers[svid] then
            print("DEBUG - has WP value.")
            -- Is a cop
            if wantedPlayers[svid] < 0 then
              print("DEBUG - is a cop.")
              table.insert(players, '<div class="ply_info">'..
                '<h3>'..(uname)..'</h3><h5>'..(svid)..'</h5><table>'..
                '<tr><thead><th colspan="2">Law Enforcement</th></thead></tr>'..
                '<tr><th>Cop Level</th><td>1</td></tr>'..
                '<tr><th>Civ Level</th><td>1</td></tr>'..
                '</table></div>'
              )
            -- Is Wanted
            elseif wantedPlayers[svid] > 0 then
              print("DEBUG - is wanted.")
              if wantedPlayers[svid] > 10 then -- Most Wanted
                print("DEBUG - is most wanted.")
                table.insert(players, '<div class="ply_info">'..
                  '<h3>'..(uname)..'</h3><h5>'..(svid)..
                  '</h5><table class="wanted10">'..
                  '<tr><thead><th colspan="2">Most Wanted</th></thead></tr>'..
                  '<tr><th>Cop Level</th><td>1</td></tr>'..
                  '<tr><th>Civ Level</th><td>1</td></tr>'..
                  '</table></div>'
                )
              else -- Wanted
                print("DEBUG - is basic wanted.")
                table.insert(players, '<div class="ply_info">'..
                  '<h3>'..(uname)..'</h3><h5>'..(svid)..
                  '</h5><table class="wanted'..(wantedPlayers[svid])..'">'..
                  '<tr><thead><th colspan="2">Wanted Level '..
                  (wantedPlayers[svid])..
                  '</th></thead></tr>'..
                  '<tr><th>Cop Level</th><td>1</td></tr>'..
                  '<tr><th>Civ Level</th><td>1</td></tr>'..
                  '</table></div>'
                )
              end
            else -- Is Not Wanted
              print("DEBUG - is not wanted.")
              table.insert(players, '<div class="ply_info">'..
                '<h3>'..(uname)..'</h3><h5>'..(svid)..'</h5><table>'..
                '<tr><thead><th colspan="2">Not Wanted</th></thead></tr>'..
                '<tr><th>Cop Level</th><td>1</td></tr>'..
                '<tr><th>Civ Level</th><td>1</td></tr>'..
                '</table></div>'
              )
            end
          -- Is Not Wanted
          else
            print("DEBUG - no WP value found; Not wanted.")
            table.insert(players, '<div class="ply_info">'..
              '<h3>'..(uname)..'</h3><h5>'..(svid)..'</h5><table>'..
              '<tr><thead><th colspan="2">Not Wanted</th></thead></tr>'..
              '<tr><th>Cop Level</th><td>1</td></tr>'..
              '<tr><th>Civ Level</th><td>1</td></tr>'..
              '</table></div>'
            )
          end
          
				end
        print("DEBUG - dispatching to jquery.")
				SendNUIMessage({ text = table.concat(players) })
				showList = true
				while showList do
					Citizen.Wait(0)
					if (IsControlReleased(0, 27)) then
						showList = false
						SendNUIMessage({exitMenu = true})
						break
					end
				end
			end
		end
	end
end)


Citizen.CreateThread(function()
  while true do 
    local plyTable = GetActivePlayers()
    for _,i in ipairs (plyTable) do
      local ped = GetPlayerPed(i)
      if ped ~= PlayerPedId() then
        blip = GetBlipFromEntity(ped)
        -- Blip does not exist, create it, and we'll fix it next frame (DEBUG - )
        if not DoesBlipExist(blip) then 
          local sv = GetPlayerServerId(i)
          blip = AddBlipForEntity(ped)
          SetBlipScale(blip, 0.8)
          SetBlipDisplay(blip, 8)
          SetBlipShrink(blip, true)
        end
      end
      Citizen.Wait(1)
    end
    Citizen.Wait(10)
  end
end)


-- Draws the text above the head
function DrawText3D(x,y,z, text, scale, col) -- some useful function, use it if you want!
  local onScreen,_x,_y = World3dToScreen2d(x,y,z)
  if not scale then
    scale = {[1] = 0.4, [2] = 0.4}
  end 
  if onScreen then
    --SetTextScale(0.0*scale, 0.55*scale)
    SetTextScale(scale[1], scale[2])
    SetTextFont(0)
    SetTextProportional(1)
    -- SetTextScale(0.0, 0.55)
    SetTextColour(col[1], col[2], col[3], 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextDropShadow()
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
  end
end

function NameColoring(sv)

  if wantedPlayers[sv] then 
    local wl = wantedPlayers[sv]
    if wl > 0 then 
      return wantedColors[wl]
    end
  end
  
  if copPlayers[sv] then 
    local wl = (math.floor(copPlayers[sv]/12))
    if copPlayers[sv] > 0 and copPlayers[sv] < 101 then 
      if wl <= 9 then 
        return copColors[1]
      else 
        return copColors[wl]
      end
    elseif copPlayers[sv] > 100 then
      return copColors[11]
    end
  end
  
  return {255,255,255}
  
end

-- Detects players and prepares to draw text above their head
Citizen.CreateThread(function()
  while true do
    local plyTable = GetActivePlayers()
    for _,i in ipairs (plyTable) do
      local ped = GetPlayerPed(i)
      if ped ~= PlayerPedId() then
      
        local sv        = GetPlayerServerId(i)
        local nameColor = NameColoring(sv)
        
        x1, y1, z1 = table.unpack(GetEntityCoords( PlayerPedId(), true ))
        x2, y2, z2 = table.unpack(GetEntityCoords( ped, true ))
        distance   = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
      
        if HasEntityClearLosToEntity(PlayerPedId(), ped, 17) then
          if (ignorePlayerNameDistance) then
            DrawText3D(x2, y2, z2 + 1.2,
              (sv),
              {0.185,0.185}, nameColor
            )
          else
            if ((distance < disIdentifier)) then
              local a = 1 - distance/128
              local b = distance/128
              if b < 0.2 then b = 0.2 end
              if IsPedInAnyVehicle(ped) then 
                DrawText3D(x2, y2, z2 + (b * 5.2),
                  (sv)..'\n'..GetPlayerName(i),
                  {a*0.25,a*0.25}, nameColor
                )
              else
                DrawText3D(x2, y2, z2 + 1.2,
                  (sv)..'\n'..GetPlayerName(i),
                  {a*0.25,a*0.25}, nameColor
                )
              end
            end
          end
        end
      end
    end
    Citizen.Wait(0)
  end
end)

-- DEBUG - OBSOLETE?
AddEventHandler('cnr:client_unload', function()
  loaded = false
end)


--- EVENT: 'cl_wanted_player'
-- Updates a single entry for a single player.
-- Triggers 'is_wanted' (if 0 -> X) and 'is_clear' (X -> 0) events respectively
-- Also triggers 'is_most_wanted' if wp exceeds 100
-- @param ply The server ID
-- @param wps The wanted points value
RegisterNetEvent('cnr:cl_wanted_client')
AddEventHandler('cnr:cl_wanted_client', function(ply, wp)
  if wp <= 0.0 then
    wantedPlayers[ply] = 0
  elseif wp > 100 then
    wantedPlayers[ply] = 11
  else
    wantedPlayers[ply] = math.floor(wp / 10) + 1
  end
  print("DEBUG - New wanted level ("..wantedPlayers[ply]..") for ply ("..ply..")")
end)


--- EVENT: 'cl_wanted_list'
-- Updates the client's entire table with the current server wanted list
-- @param wanteds The list (table) of wanted players (K: Server ID, V: Points)
RegisterNetEvent('cnr:cl_wanted_list')
AddEventHandler('cnr:cl_wanted_list', function(wanteds)
  wantedPlayers = wanteds
  for k,v in pairs(wantedPlayers) do 
    local temp = v
    if v < 1 then       wantedPlayers[ply] = 0
    elseif v > 100 then wantedPlayers[ply] = 11
    else wantedPlayers[ply] = (math.floor((wantedPlayers[ply])/10) + 1)
    end
  end
end)

