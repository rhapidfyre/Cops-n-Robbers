
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


-- Wanted Points per action
local wp    = {
  carjack   = 25, -- Carjacking a Ped
  discharge = 5,  -- Shooting in public
}


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


-- Carjacking
Citizen.CreateThread(function()
  while true do
    local eVeh = GetVehiclePedIsTryingToEnter(PlayerPedId())
    if eVeh > 0 then 
      if IsControlJustPressed(0, 75) then 
        local ped = GetPedInVehicleSeat(eVeh, (-1))
        if ped > 0 then
          local vmdl = GetDisplayNameFromVehicleModel(GetEntityModel(eVeh))
          if policeCar[vmdl] then
            enteringCopCar = true
            Citizen.CreateThread(function()
              Citizen.Wait(6000)
              local v = GetVehiclePedIsIn(PlayerPedId())
              if v > 0 then 
                if GetPedInVehicleSeat(v, (-1)) == PlayerPedId() then 
                  exports['cnrobbers']:WantedPoints(40,
                    "Carjacking a Public Safety Official"
                  )
                end
              end
              enteringCopCar = false
            end)
          -- If people carjack regular vehicles (move later DEBUG - )
          else
            Citizen.CreateThread(function()
              Citizen.Wait(6000)
              local v = GetVehiclePedIsIn(PlayerPedId())
              if v > 0 and eVeh == v then 
                if GetPedInVehicleSeat(v, (-1)) == PlayerPedId() then 
                  exports['cnrobbers']:WantedPoints(wp.carjack,
                    "Carjacking"
                  )
                end
              end
            end)
          end
        else print("DEBUG - No ped in driver's seat.")
        end
      end
    end
    Citizen.Wait(10)
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