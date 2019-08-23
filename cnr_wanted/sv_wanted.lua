
--[[
  Cops and Robbers: Wanted Script - Server Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/19/2019
  
  This file contains all information that will be stored, used, and
  manipulated by any CNR scripts in the gamemode. For example, a
  player's level will be stored in this file and then retrieved using
  an export; Rather than making individual SQL queries each time.
--]]


RegisterServerEvent('baseevents:enteringVehicle')
RegisterServerEvent('baseevents:enteringAborted')
RegisterServerEvent('baseevents:enteredVehicle')
RegisterServerEvent('cnr:wanted_points')


local carUse = {}  -- Keeps track of vehicle theft actions
local paused = {}  -- Players to keep from wanted points being reduced
local reduce = {
  tickTime = 30,   -- Time in seconds between each reduction in wanted points
  points   = 1.25, -- Amount of wanted points to reduce upon (reduce.time)
}

--- EXPORT: WantedPoints()
-- Sets the player's wanted level. 
-- @param ply      The player's server ID
-- @param crime    The crime that was committed
-- @param msg      If true, displays "Crime Committed" message
function WantedPoints(ply, crime, msg)

  if not ply   then return 0 end
  if not wanted[ply] then wanted[ply] = 0 end -- Creates ply index
  
  if not crime then return 0 end
  if crime == 'jailed' then 
    wanted[ply] = 0
    TriggerClientEvent('cnr:wanted_client', (-1), ply, 0)
    TriggerClientEvent('chat:addMessage', ply, {args={
      "^2Your wanted level has been cleared."
    }})
    return 0
  end
  
  local n = weights[crime]
  if not n then return 0 end
  
  local lastWanted = wanted[ply]
  
  -- Sends a crime message to the perp
  if msg then
    local cn = crimeName[crime]
    if cn then
      TriggerClientEvent('chat:addMessage', ply,
        {templateId = 'crimeMsg', args = {crimeName[crime]}}
      )
    end
  end
  
  -- Calculates wanted points increase by each point individually
  -- This makes higher wanted levels harder to obtain
  while n > 0 do -- e^-(0.02x/2)
    local addPoints = true
    
    -- Ensure crime is NOT a felony
    if (not felonies[crime]) then 
      -- If the next point would make them a felon, do nothing.
      if wanted[ply] + 1 >= felony then addPoints = false end
    end
    
    -- Crime is a felony, or would not make player a felon (if not a felony)
    if addPoints then 
    
      local modifier = math.exp( -1 * ((0.02 * wanted[ply])/2))
      local formula  = math.floor((modifier * 1)*100000)
      wanted[ply] = (wanted[ply] + formula/100000)
      
    else n = 0
    end
    
    n = n - 1
    Wait(0)
    
  end
  
  -- Check for broadcast
  if lastWanted ~= wanted[ply] then 
    -- Wanted level went up by at least 10 (1 level)
    if lastWanted < wanted[ply] - 10 and lastWanted >= 0 then 
      local wants = WantedLevel(ply)
      if wants > 10 then
        exports['cnr_chat']:DiscordMessage(
          16732160, "San Andreas' Most Wanted",
          GetPlayerName(ply).." is now on the Most Wanted list!",
          "San Andreas Most Wanted"
        )
      else
        exports['cnr_chat']:DiscordMessage(
          16747520, "",
          GetPlayerName(ply).." is now Wanted Level "..(wants).."!",
          ""
        )
      end
    -- Player's wanted level reduced
    elseif lastWanted > wanted[ply] - 10 and lastWanted >= 10 and lastWanted < 101 then
      exports['cnr_chat']:DiscordMessage(
        16762880, "",
        GetPlayerName(ply).." is now Wanted Level "..(wants)..".",
        ""
      )
    
    -- Player is no longer wanted
    elseif lastWanted > 0 and wanted[ply] <= 0 then 
      exports['cnr_chat']:DiscordMessage(
        13158600 , "",
        GetPlayerName(ply).." is no longer wanted by police.",
        ""
      )
    
    end
  end
  
  -- Tell other scripts about the change
  TriggerClientEvent('cnr:wanted_client', (-1), ply, wanted[ply])
  
end
AddEventHandler('cnr:wanted_points', function(crime, msg)
  local ply = source
  if crime then 
    WantedPoints(ply, crime, msg)
  end
end)  


--- EXPORT WantedLevel()
-- Returns the wanted level of the player for easier calculation
-- @param ply Server ID, if provided
-- @return The wanted level based on current wanted points
function WantedLevel(ply)

  -- If ply not given, return 0
  if not ply          then return 0 end
  if not wanted[ply] then wanted[ply] = 0 end -- Create entry if not exists
  
  if     wanted[ply] <   1 then return  0
  elseif wanted[ply] > 100 then return 11
  else                           return (math.floor((wanted[ply])/10) + 1)
  end
  return 0
  
end


--- AutoReduce()
-- Reduces wanted points per tick
function AutoReduce()
  while true do 
    for k,v in pairs (wanted) do
      if v > 0 then
        -- If wanted level is not paused/locked, allow it to reduce
        if not paused[k] then
          v = v - (reduce.points)
          TriggerClientEvent('cnr:wanted_client', (-1), k, v)
        end
      end
      Citizen.Wait(10)
    end
    Citizen.Wait((reduce.tickTime)*1000)
  end
end
Citizen.CreateThread(AutoReduce)


--- CheckIfWanted()
-- Checks if player is wanted in SQL (Logged off while wanted)
-- If SQL wanted is zero, does nothing. If wanted, sets 'wanted_client' event
-- @param ply The player's server ID. If not given, function returns
function CheckIfWanted(ply)
  local uid = GetUniqueId(ply)
  
  if uid then
    exports['ghmattimysql']:scalar(
      "SELECT wanted FROM players WHERE idUnique = @uid",
      {['uid'] = uid},
      function(wp)
        -- If player being checked is wanted, send update for that player
        if not wp then 
          print("^1[CNR ERROR] ^7SQL gave no response for wanted level query.")
          return
        end
        if wp > 0 then
          wanted[ply] = wp
          TriggerClientEvent('cnr:wanted_client', (-1), ply, wp)
        end
      end
    )
  else
    print("^1[CNR ERROR] ^7Unique ID was invalid ("..tostring(uid)..").")
  end
end


--[[
  BASE EVENTS CALLS (entering vehicles, etc)
]]


-- Attempting to enter a vehicle
AddEventHandler('baseevents:enteringVehicle', function(veh, seat)
  local ply = source
  carUse[ply] = veh
  -- Ask client to check vehicle info (driver, faction, etc)
  TriggerClientEvent('cnr:wanted_check_vehicle', ply, veh)
end)


AddEventHandler('baseevents:enteringAborted', function(veh, seat)
  local ply = source
  carUse[ply] = nil
end)


AddEventHandler('baseevents:enteredVehicle', function(veh, seat)
  local ply = source
  if carUse[ply] == veh then 
    -- Send message to the client to check if they own it,
    -- and evaluate the type of crime committed (break in, carjack, etc)
    TriggerClientEvent('cnr:wanted_enter_vehicle', ply, veh, seat)
  end
end)