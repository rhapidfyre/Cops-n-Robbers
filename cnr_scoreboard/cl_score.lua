
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

Citizen.CreateThread(function()
	showList = false
	while true do
		Citizen.Wait(0)
		if IsControlJustPressed(0, 27) then -- INPUT_PHONE
      print("DEBUG - Key pressed.")
			if not showList then
				local players = {}
        print("DEBUG - calling export.")
				local plys = exports['cnrobbers']:GetPlayers()
				for _,i in ipairs(plys) do
          print("DEBUG - Building variables.")
					local uname    = GetPlayerName(i)
					local svid     = GetPlayerServerId(i)
          print("DEBUG - Building html.")
          
          if wantedPlayers[svid] then
            -- Is a cop
            if wantedPlayers[svid] < 0 then 
              table.insert(players, '<div class="ply_info">'..
                '<h3>'..(uname)..'</h3><h5>'..(svid)..'</h5><table>'..
                '<tr><thead><th colspan="2">Law Enforcement</th></thead></tr>'..
                '<tr><th>Cop Level</th><td>1</td></tr>'..
                '<tr><th>Civ Level</th><td>1</td></tr>'..
                '</table></div>'
              )
            -- Is wanted
            elseif wantedPlayers[svid] > 0 then
              local modLevel = math.floor(wantedPlayers[svid]/10)
              if modLevel < 1 then modLevel = 1
              elseif wantedPlayers[svid] > 100 then modLevel = 101 end
              if modLevel == 101 then -- Most Wanted
                table.insert(players, '<div class="ply_info">'..
                  '<h3>'..(uname)..'</h3><h5>'..(svid)..'</h5><table class="wanted10">'..
                  '<tr><thead><th colspan="2">Wanted by FIB</th></thead></tr>'..
                  '<tr><th>Cop Level</th><td>1</td></tr>'..
                  '<tr><th>Civ Level</th><td>1</td></tr>'..
                  '</table></div>'
                )
              else -- Wanted
                table.insert(players, '<div class="ply_info">'..
                  '<h3>'..(uname)..'</h3><h5>'..(svid)..'</h5><table class="wanted'..(modLevel)..'">'..
                  '<tr><thead><th colspan="2">Wanted Level '..(modLevel)..'</th></thead></tr>'..
                  '<tr><th>Cop Level</th><td>1</td></tr>'..
                  '<tr><th>Civ Level</th><td>1</td></tr>'..
                  '</table></div>'
                )
              end
            else -- Is Not Wanted
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
            table.insert(players, '<div class="ply_info">'..
              '<h3>'..(uname)..'</h3><h5>'..(svid)..'</h5><table>'..
              '<tr><thead><th colspan="2">Not Wanted</th></thead></tr>'..
              '<tr><th>Cop Level</th><td>1</td></tr>'..
              '<tr><th>Civ Level</th><td>1</td></tr>'..
              '</table></div>'
            )
          end
          
				end
        print("DEBUG - Displaying HTML.")
				SendNUIMessage({ text = table.concat(players) })
				showList = true
				print("DEBUG - creating loop.")
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
    local plyTable = exports['cnrobbers']:GetPlayers()
    for k,v in pairs (plyTable) do
      local ped = GetPlayerPed(v)
      --if ped ~= PlayerPedId() then
        blip = GetBlipFromEntity(ped)
        -- Blip does not exist, create it, and we'll fix it next frame (DEBUG - )
        if not DoesBlipExist(blip) then 
          local sv = GetPlayerServerId(v)
          blip = AddBlipForEntity(ped)
          SetBlipScale(blip, 0.8)
          SetBlipDisplay(blip, 8)
          SetBlipShrink(blip, true)
        -- Blip exists, check wanted level, cop status, etc (DEBUG - )
        else
          if wantedPlayers[v] then 
            local wl = math.floor(wantedPlayers[v]/10)
            if wl < 1 then wl = 1
            elseif wl > 10 then wl = 11 end
            -- is wanted
            if wantedPlayers[v] > 0 and GetBlipColor(blip) ~= blipWanted[wl] then 
              --SetBlipAlpha(blip, 0)
              SetBlipColor(blip, blipWanted[wl])
              local myPos = GetEntityCoords(PlayerPedId())
              local plPos = GetEntityCoords(GetPlayerPed(v))
              if (myPos.z - plPos.z) > 10.0 then 
                SetBlipSprite(blip, 0)
              elseif (myPos.z - plPos.z) < (-10.0) then 
                SetBlipSprite(blip, 2)
              else
                SetBlipSprite(blip, 58)
              end
            else
              -- is a cop
              if wantedPlayers[v] < 0 then 
                SetBlipColor(blip, blipCops[10])
                SetBlipSprite(blip, 41)
              -- is not wanted
              else
                SetBlipColor(blip, 37)
                SetBlipSprite(blip, 163)
                --SetBlipAlpha(blip, 0)
              end
            end
          else 
            wantedPlayers[v] = 0
          end
        end
      --end
      Citizen.Wait(10)
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
    local wl = (math.floor(wantedPlayers[sv]/10))
    if wantedPlayers[sv] > 0 and wantedPlayers[sv] < 101 then 
      if wantedPlayers[sv] <= 9 then 
        return wantedColors[1]
      else 
        return wantedColors[wl]
      end
    elseif wantedPlayers[sv] > 100 then
      return wantedColors[11]
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
    local plyTable = {}
    for i=0,99 do
        N_0x31698aa80e0223f8(i)
    end
    for id = 0, 255 do
      if GetPlayerPed(id) ~= 0 then 
        plyTable[id] = GetPlayerPed(id)
      end
    end
    for k,v in pairs (plyTable) do
      if v ~= PlayerPedId() then
      
        local sv        = GetPlayerServerId(k)
        local nameColor = NameColoring(sv)
        
        x1, y1, z1 = table.unpack(GetEntityCoords( PlayerPedId(), true ))
        x2, y2, z2 = table.unpack(GetEntityCoords( v, true ))
        distance   = math.floor(GetDistanceBetweenCoords(x1,  y1,  z1,  x2,  y2,  z2,  true))
      
        if HasEntityClearLosToEntity(PlayerPedId(), v, 17) then
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
              if IsPedInAnyVehicle(v) then 
                DrawText3D(x2, y2, z2 + (b * 5.2),
                  (sv)..'\n'..GetPlayerName(k),
                  {a*0.25,a*0.25}, nameColor
                )
              else
                DrawText3D(x2, y2, z2 + 1.2,
                  (sv)..'\n'..GetPlayerName(k),
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

Citizen.CreateThread(function()
  while true do 
    wantedPlayers = exports['cnrobbers']:GetWanteds()
    Citizen.Wait(100)
    --wantedPlayers = exports['cnr_police']:GetPolice()
    Citizen.Wait(100)
  end
end)

RegisterCommand('testprint', function(s,a,r)
  print("^1Test - ^7Test - ^3Test")
end)

