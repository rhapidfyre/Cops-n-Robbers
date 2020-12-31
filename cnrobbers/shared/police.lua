
--[[ 'agency':
  0:SWAT (In this case, 0 means anyone can use it including SWAT)
  1:LSPD 2:LSSD 3:BCSO 4:SAHP 5:PARK 6:USAF 7:FIB 8:PBPD
  'rank': 0 means any rank
  'uc': If true, the occupants will NOT show up blue on the radar.
  'utilty': If true, vehicle can be used for restock
]]
local LSPD,LSSD,BCSO,SAHP,PARK,USAF,FIB,PBPD = 1,2,3,4,5,6,7,8

local stations = {
  [1] = {
    title     = "Mission Row Police Dept", agency = LSPD,
    pos       = vector3(451.96,-988.58,30.67),
    armory    = vector3(452.17,-980.09,30.67),
    walkTo    = vector3(448.48,-986.27,30.67),
    camera    = {
      pos = vector3(415.05,-957.09,34.21), rot  = 220.0,
      x   = vector3(445.58,-988.13,30.91), xrot = 282.0
    },
    vehicles  = {
      [1]  = {rank =  0, pos = vector3(446.26,-1025.04,28.21), h =   0.0, mdl = GetHashKey("POLICE")},
      [2]  = {rank =  0, pos = vector3(442.77,-1025.41,28.28), h =   0.0, mdl = GetHashKey("POLICE")},
      [3]  = {rank =  0, pos = vector3(438.90,-1024.91,28.33), h =   0.0, mdl = GetHashKey("POLICE")},
      [4]  = {rank =  0, pos = vector3(434.94,-1026.12,28.43), h =   0.0, mdl = GetHashKey("POLICE")},
      [5]  = {rank =  0, pos = vector3(431.27,-1026.03,28.48), h =   0.0, mdl = GetHashKey("POLICE")},
      [6]  = {rank =  0, pos = vector3(427.71,-1025.79,28.53), h =   0.0, mdl = GetHashKey("POLICE")},
      [7]  = {rank =  0, pos = vector3(413.51,-1018.80,28.90), h =  90.0, mdl = GetHashKey("POLICE")},
      [8]  = {rank =  0, pos = vector3(407.98,-998.25,28.87),  h =  50.0, mdl = GetHashKey("POLICE")},
      [9]  = {rank =  0, pos = vector3(408.12,-993.39,28.87),  h =  50.0, mdl = GetHashKey("POLICE")},
      [10] = {rank =  0, pos = vector3(408.12,-989.07,28.87),  h =  50.0, mdl = GetHashKey("POLICE")},
      [11] = {rank =  0, pos = vector3(408.12,-984.37,28.87),  h =  50.0, mdl = GetHashKey("POLICE")},
      [12] = {rank =  0, pos = vector3(408.17,-979.89,28.87),  h =  50.0, mdl = GetHashKey("POLICE")},
      [13] = {rank =  0, pos = vector3(475.14,-1020.19,27.67), h =  50.0, mdl = GetHashKey("POLICE")},
    }
  },--[[
  [2] = {
    title     = "Blaine County Sheriff", agency = BCSO,
    pos       = vector3(),
    armory    = vector3(),
    vehicles  = {
      [1] = {rank = 0, pos = vector3(), h = 0.0, mdl = GetHashKey("")},
    }
  },
  [3] = {
    title     = "Federal Investigation Bureau", agency = FIB,
    pos       = vector3(),
    armory    = vector3(),
    vehicles  = {
      [1] = {rank = 0, pos = vector3(), h = 0.0, mdl = GetHashKey("")},
    }
  },
  [4] = {
    title     = "Paleto Bay Police Dept", agency = PBPD,
    pos       = vector3(),
    armory    = vector3(),
    vehicles  = {
      [1] = {rank = 0, pos = vector3(), h = 0.0, mdl = GetHashKey("")},
    }
  }]]
}


function GetPoliceStation(n)
  if not n then n = 1 end
  return stations[n]
end


function GetPoliceStations(n)
  if n then return GetPoliceStation(n) end
  return stations
end


function GetDutyPoint(n)
  if not n then n = 1 end
  return stations[n].duty
end


function GetStationAgency(n)
  if not n then n = 1 end
  return stations[n].agency
end


function DutyStatus(ply)
  if not ply then ply = GetPlayerServerId(PlayerPedId()) end
  return CNR.police[ply]
end
