
RegisterNetEvent('cnr:police_stations') -- Receives info about stations

maleHash   = GetHashKey("mp_m_freemode_01")
femaleHash = GetHashKey("mp_f_freemode_01")

depts = {} -- Global Var for police scripts

local policeCars = {
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

AddEventHandler('cnr:police_stations', function(stations)

  depts = {} -- Reset / Resize 'depts'
  for k,v in pairs (stations) do 
  
    -- Temp var for settings.
    -- The garbage collector will dispose of it. This blip won't change.
    local temp = AddBlipForCoord(pos)
    SetBlipSprite(temp, v['blip_sprite'])
    SetBlipColour(temp, v['blip_color'])
    SetBlipAsShortRange(temp, true)
    SetBlipDisplay(temp, 2)
    
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Police Station")
    EndTextCommandSetBlipName(temp)
    
    -- Build K->V table
    depts[ v['id'] ] = {
      agency  = v['agency_id'],
      pos     = vector3(v['x'], v['y'], v['z'])
    }
    
  end -- for
end) -- cnr:police_stations
