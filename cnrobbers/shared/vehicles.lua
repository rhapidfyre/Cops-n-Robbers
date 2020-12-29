
-- 1: Law, 2: EMS, 4: Fire/Rescue, 8: Military
local vehicles = {
  [GetHashKey("POLICE")]    = 1,    [GetHashKey("POLICE2")]     = 1,
  [GetHashKey("POLICE3")]   = 1,    [GetHashKey("POLICE4")]     = 1,
  [GetHashKey("SHERIFF")]   = 1,    [GetHashKey("SHERIFF2")]    = 1,
  [GetHashKey("FBI")]       = 1,    [GetHashKey("FBI2")]        = 1,
  [GetHashKey("PRANGER")]   = 1,    [GetHashKey("FBIRANCHER")]  = 1,
  [GetHashKey("HYDRA")]     = 8,    [GetHashKey("RHINO")]       = 8,
  [GetHashKey("BARRACKS")]  = 8
}


function IsPoliceVehicle(ply)
  if not ply then ply = (-1) end
  local veh = GetVehiclePedIsIn(GetPlayerPed(ply))
  local mdl = GetEntityModel(veh)
  return bitoper(vehicles[mdl], 1)
end


function IsMedicalVehicle(ply)
  if not ply then ply = (-1) end
  local veh = GetVehiclePedIsIn(GetPlayerPed(ply))
  local mdl = GetEntityModel(veh)
  return bitoper(vehicles[mdl], 2)
end


function IsRescueVehicle(ply)
  if not ply then ply = (-1) end
  local veh = GetVehiclePedIsIn(GetPlayerPed(ply))
  local mdl = GetEntityModel(veh)
  return bitoper(vehicles[mdl], 4)
end


function IsMilitaryVehicle(ply)
  if not ply then ply = (-1) end
  local veh = GetVehiclePedIsIn(GetPlayerPed(ply))
  local mdl = GetEntityModel(veh)
  return bitoper(vehicles[mdl], 8)
end


