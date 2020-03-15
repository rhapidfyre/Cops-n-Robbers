
RegisterNetEvent('cnr:police_stations') -- Receives info about stations

maleHash   = GetHashKey("mp_m_freemode_01")
femaleHash = GetHashKey("mp_f_freemode_01")

depts = {} -- Global Var for police scripts

policeCars = {
  [GetHashKey("POLICE")]   = true,  [GetHashKey("POLICEB")]  = true,
  [GetHashKey("POLICE2")]  = true,  [GetHashKey("POLICE3")]  = true,
  [GetHashKey("POLICE4")]  = true,  [GetHashKey("POLICE5")]  = true,
  [GetHashKey("SHERIFF")]  = true,  [GetHashKey("SHERIFF2")] = true,
  [GetHashKey("PRANGER")]  = true,  [GetHashKey("FBI")]      = true,
  [GetHashKey("FBI2")]     = true,  [GetHashKey("PRANCHER")] = true,
}

function IsUsingPoliceVehicle()
  local ped = PlayerPedId()
  if IsPedInAnyVehicle(ped) then
    local veh = GetVehiclePedIsIn(ped)
    if GetVehicleClass(veh) == 18      then   return true   end
    if policeCars[GetEntityModel(veh)] then   return true   end
  end
  return false -- Base case
end


-- Builds a basic table of police stations
-- Does NOT build blips except for station position & duty location
AddEventHandler('cnr:police_stations', function(stations)

  depts = {} -- Reset / Resize 'depts'
  for k,v in pairs (stations) do 
  
    -- Temp var for settings.
    -- The garbage collector will dispose of it. This blip won't change.
    local newVector = vector3(v['x'], v['y'], v['z'])
    local temp = AddBlipForCoord(newVector)
    SetBlipSprite(temp, v['blip_sprite'])
    SetBlipColour(temp, v['blip_color'])
    SetBlipAsShortRange(temp, true)
    SetBlipDisplay(temp, 2)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Police Station")
    EndTextCommandSetBlipName(temp)
    
    -- Do it again, but for the duty position
    -- As before, dispose. It won't change.
    local dty        = json.decode(v['duty_point'])
    local dutyVector = vector3(dty['x'], dty['y'], dty['z'])
    local dutyBlip   = AddBlipForCoord(dutyVector)
    SetBlipSprite(dutyBlip, 466)
    SetBlipColour(dutyBlip, 42)
    SetBlipScale(dutyBlip, 1.12)
    SetBlipAsShortRange(dutyBlip, true)
    SetBlipDisplay(dutyBlip, 5)
    
    
    if DoesBlipExist(temp) then print("DEBUG - Blip: Successful.")
    else print("DEBUG - Blip: Failed") end
    
    local camInfo = json.decode(v['cams'])
    local camView = {
      pos = vector3(camInfo['view']['x'],camInfo['view']['y'],camInfo['view']['z']),
      rot = camInfo['view']['h']
    }
    local camExit = {
      pos = vector3(camInfo['exit']['x'],camInfo['exit']['y'],camInfo['exit']['z']),
      rot = camInfo['exit']['h']
    }
    local walkoff = {
      pos = vector3(camInfo['walk']['x'],camInfo['walk']['y'],camInfo['walk']['z']),
      rot = camInfo['walk']['h']
    }
    
    -- Build K->V table
    depts[ v['id'] ] = {
      agency  = v['agency_id'],
      pos     = newVector,
      duty    = dutyVector,
      cams    = {
        view = camView, leave = camExit, walk = walkoff
      }
    }
    
  end -- for
end) -- cnr:police_stations
