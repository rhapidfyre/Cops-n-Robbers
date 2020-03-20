
RegisterNetEvent('cnr:police_stations') -- Receives info about stations

maleHash   = GetHashKey("mp_m_freemode_01")
femaleHash = GetHashKey("mp_f_freemode_01")

depts = {} -- Global Var for police scripts

--[[ 'agency':
  0:SWAT (In this case, 0 means anyone can use it including SWAT)
  1:LSPD 2:LSSD 3:BCSO 4:SAHP 5:PARK 6:USAF 7:FIB 8:PBPD
  'rank': 0 means any rank 
  'uc': If true, the occupants will NOT show up blue on the radar.
  'utilty': If true, vehicle can be used for restock
]]
local vIndex = 0 -- Increments to 1 when menu is opened
local pVehicles = {

  -- "scpd1" variations
  {mdl = GetHashKey("scpd1"), title = "Crown Victoria", subtitle = "BCSO Standard",
    agency = 3, rank = 0, livery = 1, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd1"), title = "Crown Victoria", subtitle = "BCSO Slicktop",
    agency = 3, rank = 2, livery = 1, extras = {2,3,4,5,6}, price = 1000, uc = true},
  {mdl = GetHashKey("scpd1"), title = "Crown Victoria", subtitle = "LSSD Standard",
    agency = 2, rank = 0, livery = 2, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd1"), title = "Crown Victoria", subtitle = "LSSD Slicktop",
    agency = 2, rank = 2, livery = 2, extras = {2,3,4,5,6}, price = 1000, uc = true},
  {mdl = GetHashKey("scpd1"), title = "Crown Victoria", subtitle = "PBPD Standard",
    agency = 8, rank = 0, livery = 3, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd1"), title = "Crown Victoria", subtitle = "PBPD Slicktop",
    agency = 8, rank = 2, livery = 3, extras = {2,3,4,5,6}, price = 1000, uc = true},
  {mdl = GetHashKey("scpd1"), title = "Crown Victoria", subtitle = "LSPD Standard",
    agency = 1, rank = 0, livery = 4, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd1"), title = "Crown Victoria", subtitle = "LSPD Slicktop",
    agency = 1, rank = 2, livery = 4, extras = {2,3,4,5,6}, price = 1000, uc = true},
  
  -- "scpd2" variations
  {mdl = GetHashKey("scpd2"), title = "Ford Taurus", subtitle = "BCSO Standard",
    agency = 3, rank = 0, livery = 1, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd2"), title = "Ford Taurus", subtitle = "BCSO Slicktop",
    agency = 3, rank = 2, livery = 1, extras = {2,3,4,5,6}, price = 1000, uc = true},
  {mdl = GetHashKey("scpd2"), title = "Ford Taurus", subtitle = "USAF Standard",
    agency = 6, rank = 0, livery = 2, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd2"), title = "Ford Taurus", subtitle = "USAF Slicktop",
    agency = 6, rank = 2, livery = 2, extras = {2,3,4,5,6}, price = 1000, uc = true},
  {mdl = GetHashKey("scpd2"), title = "Ford Taurus", subtitle = "FIB Standard",
    agency = 7, rank = 0, livery = 3, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd2"), title = "Ford Taurus", subtitle = "FIB Slicktop",
    agency = 7, rank = 2, livery = 3, extras = {2,3,4,5,6}, price = 1000, uc = true},
  {mdl = GetHashKey("scpd2"), title = "Ford Taurus", subtitle = "LSPD Standard",
    agency = 1, rank = 0, livery = 4, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd2"), title = "Ford Taurus", subtitle = "LSPD Slicktop",
    agency = 1, rank = 2, livery = 4, extras = {2,3,4,5,6}, price = 1000, uc = true},
  
  -- "scpd3" variations
  {mdl = GetHashKey("scpd3"), title = "Dodge Charger", subtitle = "LSPD Standard",
    agency = 1, rank = 0, livery = 1, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd3"), title = "Dodge Charger", subtitle = "LSPD Slicktop",
    agency = 1, rank = 2, livery = 1, extras = {2,3,4,5,6}, price = 1000, uc = true},
  {mdl = GetHashKey("scpd3"), title = "Dodge Charger", subtitle = "PARK Standard",
    agency = 5, rank = 0, livery = 2, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd3"), title = "Dodge Charger", subtitle = "PARK Slicktop",
    agency = 5, rank = 2, livery = 2, extras = {2,3,4,5,6}, price = 1000, uc = true},
  {mdl = GetHashKey("scpd3"), title = "Dodge Charger", subtitle = "PBPD Standard",
    agency = 8, rank = 0, livery = 3, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd3"), title = "Dodge Charger", subtitle = "PBPD Slicktop",
    agency = 8, rank = 2, livery = 3, extras = {2,3,4,5,6}, price = 1000, uc = true},
  {mdl = GetHashKey("scpd3"), title = "Dodge Charger", subtitle = "LSSD Standard",
    agency = 2, rank = 0, livery = 4, extras = {1,3,4,5,6}, price = 0},
  {mdl = GetHashKey("scpd3"), title = "Dodge Charger", subtitle = "LSSD Slicktop",
    agency = 2, rank = 2, livery = 4, extras = {2,3,4,5,6}, price = 1000, uc = true},
    
  -- "scpd4" variations
  {mdl = GetHashKey("scpd4"), title = "Ford Interceptor", subtitle = "BCSO Standard",
    agency = 3, rank = 0, livery = 0, extras = {1,3,4,5,6}, price = 0, utility = true},
  {mdl = GetHashKey("scpd4"), title = "Ford Interceptor", subtitle = "PARK Standard",
    agency = 5, rank = 0, livery = 0, extras = {1,3,4,5,6}, price = 0, utility = true},
  {mdl = GetHashKey("scpd4"), title = "Ford Interceptor", subtitle = "PBPD Standard",
    agency = 8, rank = 0, livery = 0, extras = {1,3,4,5,6}, price = 0, utility = true},
  {mdl = GetHashKey("scpd4"), title = "Ford Interceptor", subtitle = "USAF Standard",
    agency = 6, rank = 0, livery = 0, extras = {1,3,4,5,6}, price = 0, utility = true},
  
  -- "1200RT" variations
  {mdl = GetHashKey("1200RT"), title = "BMW Motorbike", subtitle = "LSPD Traffic Division",
    agency = 1, rank = 4, livery = 1, extras = {1,2,3}, price = 2250},
  {mdl = GetHashKey("1200RT"), title = "BMW Motorbike", subtitle = "BCSO Traffic Division",
    agency = 3, rank = 4, livery = 2, extras = {1,2,3}, price = 2250},
  
  -- Dodge Challenger Hellcat (UC)
  {mdl = GetHashKey("hellcat"), title = "Challenger Hellcat", subtitle = "Pursuit Intercept",
    agency = 0, rank = 7, livery = 1, extras = {1,2,3,4,12}, price = 6000, uc = true, pursuit = true},
  
  -- Chevy Corvette (UC)
  {mdl = GetHashKey("zr1"), title = "Chevy Corvette", subtitle = "Pursuit Intercept",
    agency = 0, rank = 10, livery = 1, extras = {1,2}, price = 8000, uc = true, pursuit = true},
  {mdl = GetHashKey("zr1"), title = "Chevy Corvette", subtitle = "Pursuit Intercept",
    agency = 0, rank = 10, livery = 1, extras = {}, price = 8000, pursuit = true},
    
  -- Shelby Mustang GT (UC)
  {mdl = GetHashKey("17gt500"), title = "Shelby Mustang", subtitle = "Pursuit Intercept",
    agency = 0, rank = 7, livery = 1, extras = {1,2}, price = 8000, uc = true, pursuit = true},
    
  -- Chevy Camaro (UC)
  {mdl = GetHashKey("camarorb"), title = "Chevy Camaro", subtitle  = "Pursuit Intercept",
    agency = 0, rank = 7, livery = 0, extras = {1}, price = 0, uc = true, pursuit = true},
  
  -- Highway Patrol Vehicles
  {mdl = GetHashKey("hwaycar"), title = "Ford Interceptor", subtitle = "SA Highway Patrol",
    agency = 0, rank = 0, livery = 0, extras = {1}, price = 0},
  {mdl = GetHashKey("hwaycar2"), title = "Dodge Charger", subtitle = "SA Highway Patrol",
    agency = 0, rank = 1, livery = 0, extras = {1}, price = 0},
  {mdl = GetHashKey("hwaycar4"), title = "Ford F150", subtitle = "Utility Vehicle",
    agency = 0, rank = 0, livery = 0, extras = {1}, price = 0, utility = true},

}


--- IsUsingPoliceVehicle()
-- If the vehicle isn't identified as a police veh by the script, it will
-- refer to the above list to determine if it is infact a police vehicle
-- @return True if ped is inside a police vehicle
function IsUsingPoliceVehicle()
  local ped = PlayerPedId()
  if IsPedInAnyVehicle(ped) then
    local veh = GetVehiclePedIsIn(ped)
    if GetVehicleClass(veh) == 18 then return true end
    for k,_ in pairs (pVehicles) do 
      if k == veh then return true end
    end
  end
  return false -- Base case
end


--- GetPoliceVehicle()
-- Returns the next or prevous vehicle in succession
-- @agency The player's police agency. If not given, function returns empty table
-- @i (-1): Previous Index (0): Next Index (1): Current Index
-- @return A table of vehicle information
function GetPoliceVehicle(agency, i)
  
  local noVehicles = {
    mdl = GetHashKey("police"), title = "No Vehicles",
    subtitle = "This Station has no Vehicles!",
    agency = 0, rank = 0, livery = 0, extras = {}, price = 0
  }
    
  if not agency then return noVehicles end
  
  local triedAttempts = 1
  local maxAttempts   = #pVehicles + 1
  local validVehicle  = false
  if i < 1 then
    repeat
      if i < 0 then vIndex = vIndex - 1
      else vIndex = vIndex + 1 -- if i == 0 increment
      end
      if vIndex < 1 then vIndex = #pVehicles
      elseif vIndex > #pVehicles then vIndex = 1
      end
      -- Stop when the vehicle chosen is the same agency or all agencies
      if pVehicles[vIndex].agency == agency then validVehicle = true
      elseif pVehicles[vIndex].agency == 0 then validVehicle = true
      end
      triedAttempts = triedAttempts + 1
      Citizen.Wait(1)
    until ((validVehicle) or (triedAttempts > maxAttempts))
  end
  
  if not pVehicles[vIndex] then return noVehicles end
  return pVehicles[vIndex]
  
end


function ResetPoliceVehicleIndex()
  vIndex = 0 -- Increments to 1 when vehicle menu is opened
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
