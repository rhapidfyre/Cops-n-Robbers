
--[[
  Cops and Robbers: Wanted Script - Client Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/19/2019
  
  This file contains all information that will be stored, used, and
  manipulated by any CNR scripts in the gamemode. For example, a
  player's level will be stored in this file and then retrieved using
  an export; Rather than making individual SQL queries each time.
--]]


-- Networking
RegisterNetEvent('cnr:wanted_list') -- Updates 'wanted' table with server table
RegisterNetEvent('cnr:wanted_client')


TriggerEvent('chat:addTemplate', 'crimeMsg',
  '<font color="#F80"><b>CRIME COMMITTED:</b></font> {0}'
)


TriggerEvent('chat:addTemplate', 'levelMsg',
  '<font color="#F80"><b>WANTED LEVEL:</b></font> {0} - ({1})'
)


local marked = {}  -- Table of killed peds ([Ped_Id] = true)


--- EVENT: 'wanted_list'
-- Received by server; Entire wanted list with key-value pair (Line 19)
-- @param warrant_list The table of wanted persons ([Server_Id] = Points)
AddEventHandler('cnr:wanted_list', function(warrant_list)
  wanted = warrant_list
end)


--- EVENT: 'wanted_client'
-- Updates the wanted points for a single given client
-- Triggers client events 'is_wanted', 'is_clear', 'is_most_wanted' accordingly
-- @param ply The server ID
-- @param wps The wanted points value
RegisterNetEvent('cnr:wanted_client')
AddEventHandler('cnr:wanted_client', function(ply, wp)

  -- If no wanted points or player is given, assume or return
  if not wp  then wp = 0     end
  if not ply then return 0   end
  
  -- If the player being passed is the local client, check for events
  if ply == GetPlayerServerId(PlayerId()) then 
    
    -- If no wanted table entry, create one.
    if not wanted[ply] then wanted[ply] = 0
    end
    
    -- If player goes innocent -> wanted or vice versa, trigger event
    if     wanted[ply] == 0 and wp  > 0 then TriggerEvent('cnr:is_wanted')
    elseif wanted[ply]  > 0 and wp <= 0 then TriggerEvent('cnr:is_clear')
    end
    
    -- If player was not most wanted, and will be, trigger 'is_most_wanted'
    if wanted[ply] < mw and wp > mw then TriggerEvent('cnr:is_most_wanted')
    end
    
  end
  
  wanted[ply] = wp -- Update wanted list entry
end)


--- EXPORT GetWanteds()
-- Returns the table of wanted players
-- @return table The list of wanteds (KEY: Server ID, VAL: Wanted Points)
function GetWanteds() return wanted end


--- EXPORT GetClosestPlayer()
-- Finds the closest player
-- @return Player local ID. Must be turned into a ped object or server ID from there.
function GetClosestPlayer()
	local ped   = PlayerPedId()
  local myPos = GetEntityCoords(ped)
	local cPly  = nil
	local cDst  = math.huge
  for i = 1, #GetActivePlayers() do 
    local tgt = GetPlayerPed(v)
    if tgt ~= ped then
      local dist = #(myPos - GetEntityCoords(tgt)
      if cDst > dist then cPly = v; cDst = dist end
    end
  end
	return cPly
end


--- UpdateWantedStars()
-- Checks to see if the player's wanted points change to adjust the NUI.
-- If they differ from the NUI display, it will update the NUI.
function UpdateWantedStars()
  local prevWanted = 0
  local tickCount  = 0
  while not () do Wait(100) end
  while true do 
    local wanted = WantedLevel()
    
    -- Wanted Level has changed
    if wanted ~= prevWanted then 
      prevWanted = wanted -- change to reflect it
      tickCount  = 0      -- Restart flash if changes again during flash
      
    else
      -- Make it flash, end on the solid version
      if tickCount < 10 then          tickCount = tickCount + 1
        if wanted == 0 then           SendNUIMessage({nostars = true})
        else
          -- Normal version (light saturation)
          if tickCount % 2 == 0 then  SendNUIMessage({stars = wanted})
          else
            -- Performs the flash (dark saturation)
            if     wanted > 10 then   SendNUIMessage({stars = "c"})
            elseif wanted >  5 then   SendNUIMessage({stars = "b"})
            else                      SendNUIMessage({stars = "a"})
            end
          end
        end
      end
    end
    Wait(600)
  end
end



--- NotCopLoops()
-- Runs loops if the player is not a cop. Terminates if they go onto cop duty
-- Used to detect crimes that civilians can commit when off duty.
function NotCopLoops()
  if not isCop then
    while true do 
      -- Shooting a firearm near peds
      
      -- Breaking into a vehicle
      
      -- Killing a Ped NPC
      
      Citizen.Wait(0)
    end
  end
end

Citizen.CreateThread(function()
  Citizen.CreateThread(UpdateWantedStars)
  --Citizen.CreateThread(NotCopLoops)
end)