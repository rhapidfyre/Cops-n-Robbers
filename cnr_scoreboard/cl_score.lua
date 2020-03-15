
RegisterNetEvent('cnr:score_receive')


local disIdentifier = 128
local ignorePlayerNameDistance = false
local wantedPlayers = {}
local copPlayers    = {}

local levels = {}

local copColors = {
  [1]  = {190,200,255}, [2]  = {185,185,255},
  [3]  = {160,160,255}, [4]  = {140,140,255},
  [5]  = {120,120,255}, [6]  = {100,100,255},
  [7]  = {80,80,255},   [8]  = {60,60,255},
  [9]  = {40,40,255},   [10] = {0,0,255},
}

local wantedColors = {
  [1]  = {255,225,125}, [2]  = {255,200,100},
  [3]  = {255,190,86},  [4]  = {255,146,70},
  [5]  = {255,130,60},  [6]  = {255,122,45},
  [7]  = {255,112,32},  [8]  = {255,105,25},
  [9]  = {255,90,15},   [10] = {255,78,0},
  [11] = {255, 40, 0}
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

function GetPlayerWantedScore(client)
  if not client then return 0 end
  if not wantedPlayers[client] then wantedPlayers[client] = 0 end
  return wantedPlayers[client]
end

function GetClientScore(client, copScore)

  if not client then client = GetPlayerServerId(PlayerId()) end
  if type(client) ~= "number" then tonumber(client) end
  if not levels[client] then SetClientScore(client) end
  
  if copScore then  return (levels[client].cop)
  else              return (levels[client].civ)
  end
  
  return (-1) -- Error, return -1
end

function SetClientScore(client, scores)
  if not client then client = GetPlayerServerId(PlayerId()) end
  if type(client) ~= "number" then client = tonumber(client) end
  if not scores then 
    levels[client] = {cop = 1, civ = 1}
    return {cop = 1, civ = 1}
    
  else
    if not levels[client] then
      levels[client] = {cop = 0, civ = 0}
    end
    
    levels[client] = {civ = scores.civ, cop = scores.cop}
    return {cop = levels[client].cop, civ = levels[client].civ}
    
  end
end
AddEventHandler('cnr:score_receive', function(client, scores)
  SetClientScore(client, scores)
end)


-- Scoreboard
Citizen.CreateThread(function()
	showList = false
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(0, 27) then -- INPUT_PHONE
			if not showList then
				local players = {}
				local clients = GetActivePlayers()
				for _,i in ipairs(clients) do
        
					local uname  = GetPlayerName(i)
					local svid   = GetPlayerServerId(i)
          local myself = ""
          local svwp   = GetPlayerWantedScore(svid)
          local copScore = GetClientScore(svid, true)
          local civScore = GetClientScore(svid, false)
  
          if i == PlayerId() then myself = ' class="myself"' end
          
          if svwp and not copPlayers[svid] then
          
            -- Is Wanted
            if svwp > 0 then
            
              if svwp > 10 then -- Most Wanted
              
                table.insert(players, '<div class="ply_info">'..
                  '<h3'..myself..'>'..(uname)..'</h3><h5'..myself..'>'..(svid)..
                  '</h5><table class="wanted10">'..
                  '<tr><thead><th colspan="2">Most Wanted</th></thead></tr>'..
                  '<tr><th>Cop Level</th><td>'..copScore..'</td></tr>'..
                  '<tr><th>Civ Level</th><td>'..civScore..'</td></tr>'..
                  '</table></div>'
                )
              else -- Wanted
              
                table.insert(players, '<div class="ply_info">'..
                  '<h3'..myself..'>'..(uname)..'</h3><h5'..myself..'>'..(svid)..
                  '</h5><table class="wanted'..(svwp)..'">'..
                  '<tr><thead><th colspan="2">Wanted Level '..
                  (svwp)..'</th></thead></tr>'..
                  '<tr><th>Cop Level</th><td>'..copScore..'</td></tr>'..
                  '<tr><th>Civ Level</th><td>'..civScore..'</td></tr>'..
                  '</table></div>'
                )
              end
            else -- Is Not Wanted
            
              table.insert(players, '<div class="ply_info">'..
                '<h3'..myself..'>'..(uname)..'</h3><h5'..myself..'>'..(svid)..'</h5><table>'..
                '<tr><thead><th colspan="2">Not Wanted</th></thead></tr>'..
                '<tr><th>Cop Level</th><td>'..copScore..'</td></tr>'..
                '<tr><th>Civ Level</th><td>'..civScore..'</td></tr>'..
                '</table></div>'
              )
            end
          elseif copPlayers[svid] then
            -- Is a cop
            local temp = copScore
            if copScore > 10 then temp = 10 end
            table.insert(players, '<div class="ply_info">'..
              '<h3'..myself..'>'..(uname)..'</h3><h5'..myself..'>'..(svid)..'</h5>'..
              '<table class="police'..(temp)..'">'..
              '<tr><thead><th colspan="2">Law Enforcement</th></thead></tr>'..
              '<tr><th>Cop Level</th><td>'..copScore..'</td></tr>'..
              '<tr><th>Civ Level</th><td>'..civScore..'</td></tr>'..
              '</table></div>'
            )

          -- Is Not Wanted
          else
          
            table.insert(players, '<div class="ply_info">'..
              '<h3'..myself..'>'..(uname)..'</h3><h5'..myself..'>'..(svid)..'</h5><table>'..
              '<tr><thead><th colspan="2">Not Wanted</th></thead></tr>'..
              '<tr><th>Cop Level</th><td>'..copScore..'</td></tr>'..
              '<tr><th>Civ Level</th><td>'..civScore..'</td></tr>'..
              '</table></div>'
            )
          end

				end
        
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


-- Draws the text above the head
function DrawText3D(x,y,z, text, col) -- some useful function, use it if you want!
  local onScreen,_x,_y = GetScreenCoordFromWorldCoord(x,y,z)
  local dist = GetDistanceBetweenCoords(GetGameplayCamCoords(), x, y, z, 1)
  local scale = (4.00001 / dist) * 0.3
  if     scale >  0.2 then scale = 0.20
  elseif scale < 0.15 then scale = 0.15
  end

  if onScreen then
    --SetTextScale(0.0*scale, 0.55*scale)
    SetTextScale(scale + 0.12, scale + 0.12)
    SetTextFont(4)
    SetTextProportional(true)
    -- SetTextScale(0.0, 0.55)
    SetTextColour(col[1], col[2], col[3], 255)
    SetTextDropshadow(0, 0, 0, 0, 255)
    SetTextEdge(2, 0, 0, 0, 150)
    SetTextCentre(true)
    SetTextDropShadow()
    SetTextOutline()

    SetTextEntry("STRING")
    AddTextComponentString(text)
    DrawText(_x,_y - 0.025)

  end
end

function NameColoring(sv)

  if wantedPlayers[sv] then
    local wl = wantedPlayers[sv]
    if wl > 0 then
      return wantedColors[wl]
    end
  end

  local cplayer = copPlayers[sv]
  if cplayer then
    local ccolor = copColors[cplayer]
    if ccolor then return ccolor end
  end

  return {255,255,255}

end

-- Detects players and prepares to draw text above their head
Citizen.CreateThread(function()
  while true do
    local clientTable = GetActivePlayers()
    for _,i in ipairs (clientTable) do
      local ped = GetPlayerPed(i)
      if ped ~= PlayerPedId() then

        local sv        = GetPlayerServerId(i)
        local nameColor = NameColoring(sv)

        x1, y1, z1 = table.unpack(GetEntityCoords( PlayerPedId(), true ))
        x2, y2, z2 = table.unpack(GetEntityCoords( ped, true ))
        distance   = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))

        if HasEntityClearLosToEntity(PlayerPedId(), ped, 17) then
          if (ignorePlayerNameDistance) then
            DrawText3D(x2, y2, z2+1, sv, nameColor)
          else
            if ((distance < disIdentifier)) then
              DrawText3D(x2, y2, z2+1, GetPlayerName(i).." ["..sv.."]", nameColor)
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


--- EVENT: 'wanted_client'
-- Updates the client's entire table with the current server wanted list
-- @param wanteds The list (table) of wanted players (K: Server ID, V: Points)
RegisterNetEvent('cnr:wanted_client')
AddEventHandler('cnr:wanted_client', function(client, wp)
  -- If client not given, return 0
  if not client      then return 0 end
  if not wp       then wantedPlayers[client] =  0 end -- Create entry if not exists
  if     wp <   1 then wantedPlayers[client] =  0
  elseif wp > 100 then wantedPlayers[client] = 11
  else wantedPlayers[client] = (math.floor((wp/10)) + 1)
  end
end)


RegisterNetEvent('cnr:police_officer_duty')
AddEventHandler('cnr:police_officer_duty', function(client, isDuty, cLevel)
  if isDuty then copPlayers[client] = cLevel
  else copPlayers[client] = nil end
end)

