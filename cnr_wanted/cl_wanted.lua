
--[[
  Cops and Robbers: Wanted Scripts (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  07/13/2019
  
  This file keeps track of various affects from being wanted, such as 
  the wanted player HUD, clear/most wanted messages, etc.
  
  While this file does not contain most calls to criminal charges,
  some basic things like carjacking, killing peds, etc are found here.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]


local isShooting = false
local isCop      = false
local stoleCars  = {} -- Keep track of cars stolen so they don't get charged x2
local entering   = {
  id = 0,     -- Local vehicle ID
  locked = false,
  public = false,
  driver = 0
}

local isPoliceCar = {
  ["POLICE"]   = true,  ["POLICEB"]  = true,  ["POLICE2"]  = true,
  ["POLICE3"]  = true,  ["POLICE4"]  = true,  ["POLICE5"]  = true,
  ["SHERIFF"]  = true,  ["SHERIFF2"] = true,  ["PRANGER"]  = true,
  ["FBI"]      = true,  ["FBI2"]     = true,  ["PRANCHER"] = true,
}

-- Wanted Points per action
local wp    = {
  carjack   = 25, -- Carjacking a Ped
  discharge = 5,  -- Shooting in public
}

RegisterNetEvent('cnr:wanted_check_vehicle')
AddEventHandler('cnr:wanted_check_vehicle', function(veh, mdl)
  if veh then 
    if veh > 0 then 
      entering.id = veh
      print("DEBUG - entering.id = "..(entering.id))
    end
  end
  if entering.id > 0 then 
    entering.locked = GetVehicleDoorLockStatus(entering.id)
    entering.driver = GetPedInVehicleSeat(entering.id, (-1))
    entering.public = isPoliceCar[mdl]
    print("DEBUG - Variables SET.")
  end
end)

RegisterNetEvent('cnr:wanted_enter_vehicle')
AddEventHandler('cnr:wanted_enter_vehicle', function(veh, seat)
  if entering.id > 0 and not stoleCars[veh] then 
    print("DEBUG - Vehicle entry completed.")
    if not exports['cnr_police']:DutyStatus() then 
      print("DEBUG - Not a cop, checking crimes.")
      Citizen.CreateThread(function()
        Citizen.Wait(3000)
        local crime = {points = 0, msg = ""}
        -- Getting into public safety vehicle
        if entering.public then 
          print("DEBUG - Entered publicly owned vehicle")
          -- Vehicle has a driver
          if entering.driver > 0 then
            print("DEBUG - There was a driver.")
            -- If entering driver seat or driver is not a player, carjack crime
            if entering.seat == (-1) or not IsPedAPlayer(entering.driver) then
              print("DEBUG - Preparing criminal charges for CARJACKING (PS)")
              crime = {
                points = 50,
                msg = "Carjacking a Public Official (215 PC)"
              }
            end
            
          else
            print("DEBUG - Unoccupied PS vehicle, checking lock.")
            -- Stealing locked police vehicle
            if entering.locked and seat == (-1) then 
              print("DEBUG -  Vehicle was locted. Preparing VANDALISM")
              crime.point =  8
              crime.msg   = "Vandalism of a Public Vehicle (594 VC)"
              -- Check if engine is running, because if it is, they can take it
              if GetIsVehicleEngineRunning(entering.id) then 
                print("DEBUG - Engine running, double charging for GTA")
                crime.p2   = 12
                crime.msg2 = "GTA of a Public Vehicle (10851 VC)"
              end
              
            -- Stealing unlocked police vehicle
            elseif not entering.locked and seat == (-1) then
              if GetIsVehicleEngineRunning(entering.id) then 
                print("DEBUG - Not locked.")
                crime.points = 12
                crime.msg  = "GTA of a Public Vehicle (10851 VC)"
              end
            end
          end
        
        -- Entering an occupied vehicle (carjacking, not public safety)
        elseif entering.driver > 0 then 
          print("DEBUG - Carjacking a civilian.")
          crime = {
            points = 34,
            msg = "Carjacking (215 PC)"
          }
          
        -- Entering a locked vehicle (not public safety)
        elseif entering.locked then
          print("DEBUG - GTA/VANDALISM - Civilian.")
          crime.point =  8
          crime.msg   = "Vandalism (594 VC)"
          crime.p2   = 12
          crime.msg2 = "Motor Vehicle Theft/GTA (10851 VC)"
          
        end
        if crime.points > 0 then 
          print("DEBUG - Issuing charges.")
          exports['cnrobbers']:WantedPoints(crime.points, crime.msg)
          -- Secondary crime
          if crime.p2 then 
            print("DEBUG - Issuing secondary charges.")
            exports['cnrobbers']:WantedPoints(crime.p2, crime.msg2)
          end
        end
        entering = {id = 0, locked = false, public = false, driver = 0}
      end)
    end
    print("DEBUG - Adding vehicle #"..tostring(veh).." to list of already affected vehicles.")
    stoleCars[veh] = true
  elseif entering.id > 0 and stoleCars[veh] then 
    print("DEBUG - Vehicle already affected.")
    entering = {id = 0, locked = false, public = false, driver = 0}
  else
    print("DEBUG - Not found.")
    entering = {id = 0, locked = false, public = false, driver = 0}
  end
end)


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


AddEventHandler('cnr:loaded', function()
  NotCopLoops()
end)

AddEventHandler('cnr:police_duty', function(onDuty)
  isCop = onDuty
  NotCopLoops()
end)


function NotCopLoops()
  if not isCop then
    Citizen.CreateThread(function()
      while not isCop do 
        if IsPedShooting(PlayerPedId()) then 
          if not isShooting then 
            isShooting = true
            Citizen.CreateThread(function()
              Citizen.Wait(30000)
              isShooting = false
            end)
            exports['cnrobbers']:WantedPoints(wp.discharge,
              "Discharging a Firearm in Public"
            )
          end
        end
        Citizen.Wait(1)
      end
    end)
  end
end