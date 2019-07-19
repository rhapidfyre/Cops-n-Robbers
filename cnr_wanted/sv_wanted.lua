
--[[
  Cops and Robbers: Wanted Scripts (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  07/13/2019
  
  This file keeps track of various affects from being wanted, such as 
  the wanted player HUD, clear/most wanted messages, etc.
  
  While this file does not contain most calls to criminal charges,
  some basic things like carjacking, killing peds, etc are found here.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

local carUse  = {} -- Key: Server ID, Val = Vehicle ID


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