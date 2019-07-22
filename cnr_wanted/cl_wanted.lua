
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
local wp       = {
  carjack      = 25,  -- Carjacking a Ped
  discharge    = 5,   -- Shooting in public
  murder       = 90,  -- Killing another player
  manslaughter = 15,  -- Killing an NPC ped
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
      Citizen.CreateThread(function()
        Citizen.Wait(3000)
        local crime = {points = 0, msg = ""}
        -- Getting into public safety vehicle
        if entering.public then 
          -- Vehicle has a driver
          if entering.driver > 0 then
            -- If entering driver seat or driver is not a player, carjack crime
            if entering.seat == (-1) or not IsPedAPlayer(entering.driver) then
              crime = {
                points = 50,
                msg    = "Carjacking a Public Official"
              }
            end
            
          else
            -- Stealing locked police vehicle
            if entering.locked and seat == (-1) then 
              crime.point =  8
              crime.msg   = "Vandalism; Police Vehicle Enhancement"
              -- Check if engine is running, because if it is, they can take it
              if GetIsVehicleEngineRunning(entering.id) then 
                crime.p2   = 12
                crime.msg2 = "Grand Theft Auto; Police Vehicle Enhancement"
              end
              
            -- Stealing unlocked police vehicle
            elseif not entering.locked and seat == (-1) then
              if GetIsVehicleEngineRunning(entering.id) then 
                crime.points = 12
                crime.msg  = "Grand Theft Auto; Police Vehicle Enhancement"
              end
            end
          end
        
        -- Entering an occupied vehicle (carjacking, not public safety)
        elseif entering.driver > 0 then 
          crime = {
            points = 34,
            msg = "Carjacking"
          }
          
        -- Entering a locked vehicle (not public safety)
        elseif entering.locked then
          crime.point =  8
          crime.msg   = "Vandalism"
          crime.p2   = 12
          crime.msg2 = "Grand Theft Auto"
          
        end
        if crime.points > 0 then 
          exports['cnrobbers']:WantedPoints(crime.points, crime.msg)
          -- Secondary crime
          if crime.p2 then 
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


-- Keep a list of kills that player has been charged for already
local marked = {}
function NotCopLoops()
  if not isCop then
    Citizen.CreateThread(function()
      while not isCop do 
        if IsPedShooting(PlayerPedId()) then 
          -- Charge people for shooting a gun in public
          -- DEBUG - Optimize later to only star them if someone flees from it
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
        Citizen.Wait(0)
      end
    end)
  end
end


Citizen.CreateThread(function()
  while true do 
    if not isCop then 
      for ent in exports['cnrobbers']:EnumeratePeds() do 
        if IsPedDeadOrDying(ent) then 
          local killer = GetPedSourceOfDeath(ent)
          if killers == PlayerPedId() then 
            if not IsPedAPlayer(ent) then
              if not DecorExistOn(ent, "KilledBy") then 
                DecorRegister("KilledBy", 2)
                DecorSetBool(ent, "KillCharge", true)
                Citizen.CreateThread(function()
                  Wait(3000)
                  exports['cnrobbers']:WantedPoints(wp.manslaughter,
                    "Manslaughter (Killed an NPC)"
                  )
                end)
              end
            end
          end
        end
        Wait(1)
      end
      Citizen.Wait(1000)
    end
  end
end)
