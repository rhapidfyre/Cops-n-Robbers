
--[[
  Cops and Robbers: Wanted Scripts (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  07/13/2019
  
  This file keeps track of various affects from being wanted, such as 
  the wanted player HUD, clear/most wanted messages, etc.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

local carUse  = {}   -- Key: Server ID, Val = Vehicle ID
local wanteds = {}   -- List of wanted players on the server
local paused  = {}   -- List of players whose wanted points are locked
local felony  = 39   -- Point threshold of felony level crimes

--- EXPORT: WantedPoints()
-- Sets the player's wanted level. 
-- @param ply      The player's server ID
-- @param crime    The crime that was committed
-- @param msg      If true, displays "Crime Committed" message
-- @param isFelony Points can only go >= felony if this is true, else caps at 39
function WantedPoints(ply, crime, msg, isFelony)

  if not ply   then return 0 end
  if not wanteds[ply] then wanteds[ply] = 0 end -- Creates ply index
  
  if not crime then return 0 end
  
  local n = weights[crime]
  if not n then return 0 end
  
  -- Sends a crime message to the perp
  if msg then
    local cn = crimeName[crime]
    if cn then
      TriggerClientEvent('chat:addMessage', ply,
        {templateId = 'crimeMsg', args = {crimeName[crime]}
      )
    end
  end
  
  -- Calculates wanted points increase by each point individually
  -- This makes higher wanted levels harder to obtain
  while n > 0 do -- e^-(0.02x/2)
    local addPoints = true
    
    if not isFelony then 
      -- If the next point would make them a felon, do nothing.
      if wanteds[ply] + 1 >= felony then addPoints = false end
    end
    
    if addPoints then 
    
      local modifier = math.exp( -1 * ((0.02 * wanteds[ply])/2))
      local formula  = math.floor((modifier * 1)*100000)
      wanteds[ply] = (wanteds[ply] + formula/100000)
      
    else n = 0
    end
    
    n = n - 1
    Wait(0)
    
  end
  
  -- Tell other scripts about the change
  TriggerEvent('cnr:wanted_points', ply, wanteds[ply])
  TriggerClientEvent('cnr:wanted_level', (-1), ply, wanteds[ply])
  
end


--- EXPORT WantedLevel()
-- Returns the wanted level of the player for easier calculation
-- @param ply Server ID, if provided
-- @return The wanted level based on current wanted points
function WantedLevel(ply)

  -- If ply not given, return 0
  if not ply          then return 0 end
  if not wanteds[ply] then wanteds[ply] = 0 end -- Create entry if not exists
  
  if     wanteds[ply] <   1 then return  0
  elseif wanteds[ply] > 100 then return 11
  else                           return (math.floor((wanteds[ply])/10) + 1)
  end
  
  return 0
end


-- Reduces wanted points per tick
Citizen.CreateThread(function()
  while true do 
    for k,v in pairs (wanteds) do
      if v > 0 then
        if not paused[k] then v = v - (reduce.points)
        end
      end
      Citizen.Wait(1)
    end
    Citizen.Wait((reduce.tickTime)*1000)
  end
end)



--[[
  BASE EVENTS CALLS (entering vehicles, etc)
]]

-- Attempting to enter a vehicle
RegisterServerEvent('baseevents:enteringVehicle')
AddEventHandler('baseevents:enteringVehicle', function(veh, seat, mdl, netVeh)
  local ply = source
  carUse[ply] = veh
  -- Ask client to check if the vehicle is locked, or if there's a driver
  TriggerClientEvent('cnr:wanted_check_vehicle', ply, veh, mdl)
end)


RegisterServerEvent('baseevents:enteringAborted')
AddEventHandler('baseevents:enteringAborted', function(veh, seat, mdl, netVeh)
  local ply = source
  carUse[ply] = nil
end)


RegisterServerEvent('baseevents:enteredVehicle')
AddEventHandler('baseevents:enteredVehicle', function(veh, seat, mdl, netVeh)
  local ply = source
  if carUse[ply] == veh then 
    -- Send message to the client to check if they own it,
    -- and evaluate the type of crime committed (break in, carjack, etc)
    TriggerClientEvent('cnr:wanted_enter_vehicle', ply, veh, seat)
  end
end)