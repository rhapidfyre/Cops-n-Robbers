
--[[
  Cops and Robbers: Radar Blips (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  08/12/2019
  
  This file handles radar blips for players, and radar locations not necessarily
  belonging to any script (random weapon pickups, etc)
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

local plyBlip = {}

function SetBlipGenericStyle(ply)
  if DoesBlipExist(plyBlip[ply]) then 
    SetBlipSprite(plyBlip[ply], 1)
    SetBlipScale(plyBlip[ply], 0.82)
  end
end

-- Ensures blips are created for all players
function DrawPlayerBlips()
  Citizen.Wait(3000)
  while true do 
    local plys = GetActivePlayers()
    for _,ply in ipairs (plys) do 
      if not DoesBlipExist(plyBlip[ply]) and ply ~= PlayerId() then
        plyBlip[ply] = AddBlipForEntity(ply)
        SetBlipGenericStyle(ply)
      end
    end
    Citizen.Wait(1000)
  end
end

-- Updates Blips based on circumstances
function UpdateBlipInfo()
  Citizen.Wait(5000)
  while true do 
    local plys = GetActivePlayers()
    for _, ply in ipairs (plys) do 
      if DoesBlipExist(plyBlip[ply]) then 
        local ped = GetPlayerPed(ply)
        if ped > 0 then
        
          -- Set appropriate blip color
          local wanted = exports['cnrobbers']:WantedLevel(GetPlayerServerId(ply))
          if wanted > 5 then     SetBlipColour(plyBlip[ply], 66)
          elseif wanted > 0 then SetBlipColour(plyBlip[ply], 47)
          else
            if exports['cnrobbers']:IsCop(ply) then 
                 SetBlipColour(plyBlip[ply], 8)
            else SetBlipColour(plyBlip[ply], 0)
            end
          end
          
          -- Set appropriate blip sprite
          if IsPedInAnyBoat(ped) then        SetBlipSprite(plyBlip[ply], 427)
          elseif IsPedInAnyPlane(ped) then   SetBlipSprite(plyBlip[ply], 423)
          elseif IsPedInAnyHeli(ped) then    SetBlipSprite(plyBlip[ply], 423)
          elseif IsPedInAnyVehicle(ped) then SetBlipSprite(plyBlip[ply], 326)
          else                               SetBlipGenericStyle(ply)
          end
          
        else SetBlipGenericStyle(ply)
        end
      end
    end
    Citizen.Wait(100)
  end
end

-- Starts functions / loops upon script load
Citizen.CreateThread(DrawPlayerBlips)
Citizen.CreateThread(UpdateBlipInfo)




