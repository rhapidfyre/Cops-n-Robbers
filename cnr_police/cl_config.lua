
--[[
  Cops and Robbers: Law Enforcement Scripts (CONFIG)
  Created by Michael Harris (mike@harrisonline.us)
  07/12/2019
  
  This file handles all configuration variables, coordinates, and settings
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

copUniform = {
  [3]  = {draw =   0, text = 0},
  [4]  = {draw =  35, text = 0},
  [6]  = {draw =  54, text = 0},
  [8]  = {draw = 122, text = 0},
  [11] = {draw =  55, text = 0}
}

-- Agencies:
-- [1] LSPD [2] LSSD [3] BCSO [4] HP [5] Ranger [6] MP [7] FIB
depts = {
  [1] = { -- Mission Row
    zone    = 1, title   = "LSPD Station", agency = 1,
    duty    = vector3(452.811, -989.455, 30.689), -- Duty spot detection
    walkTo  = vector3(447.79, -986.319, 30.689),  -- Where to walk out to
    leave   = nil, -- Optional (TP here before leaving)
    camview = vector3(410.313, -961.877, 32.4769), -- Camera view on duty switch
    exitcam = vector3(445.723, -988.74, 30.25), -- Cam position on exit
    caminfo = {
      h     = 235.00, fov   = 60.0,
      eh    = 235.00, efov  = 80.0,
      rotx  =    0.0, roty  =  0.0, rotz = 235.0,
      erotx =    0.0, eroty =  0.0, erotz = 292.0
    }
  },
  [2] = { -- Vespucci Beach
    zone    = 1, title   = "Police Station", agency = 1,
    duty    = vector3(-1060.22, -826.492, 19.212),
    leave   = vector3(-1107.84, -846.551, 19.317),
    walkTo  = vector3(-1114.27, -841.893, 19.317),
    camview = vector3(-1085.09, -783.761, 21.150),
    exitcam = vector3(-1117.06, -856.142, 22.694),
    caminfo = {
      h     = 188.00, fov   = 60.0,
      eh    = 342.00, efov  = 80.0,
      rotx  =    0.0, roty  =  0.0, rotz  = 188.0,
      erotx =    0.0, eroty =  0.0, erotz = 342.0
    }
  },
  [3] = { -- Vinewood Station
    zone    = 1, title   = "Police Station", agency = 1,
    duty    = vector3(639.60, 1.343, 82.787),
    leave   = vector3(620.156, 18.32, 87.91),
    walkTo  = vector3(621.442, 21.902, 88.341),
    camview = vector3(662.551, -13.46, 83.58),
    exitcam = vector3(618.47, 28.510, 88.741),
    caminfo = {
      h     =  90.0, fov   =   80.0,
      eh    = 180.0, efov  =   60.0,
      rotx  =   0.0, roty  =   0.0, rotz  =  90.0,
      erotx =   0.0, eroty =   0.0, erotz = 180.0
    }
  },
  [4] = { -- Davis Station
    zone    = 1, title   = "Sheriff's Office", agency = 2,
    duty    = vector3(360.73, -1584.57, 29.292),
    leave   = vector3(369.89, -1607.80, 29.292),
    walkTo  = vector3(375.20, -1615.17, 29.292),
    camview = vector3(386.57, -1571.61, 33.342),
    exitcam = vector3(380.17, -1624.35, 31.61),
    caminfo = {
      h     = 162.0, fov   =   80.0,
      eh    =  36.0, efov  =   60.0,
      rotx  =   0.0, roty  =   0.0, rotz  = 162.0,
      erotx =   0.0, eroty =   0.0, erotz =  36.0
    }
  },--[[
  [5] = { -- Beaver Bush Station
    zone    = 1, title   = "Ranger Station", agency = 5,
    duty    = vector3(),
    leave   = vector3(),
    walkTo  = vector3(),
    camview = vector3(),
    exitcam = vector3(),
    caminfo = {
      h     =   0.0, fov   =   0.0,
      eh    =   0.0, efov  =   0.0,
      rotx  =   0.0, roty  =   0.0, rotz  =   0.0,
      erotx =   0.0, eroty =   0.0, erotz =   0.0
    }
  },
  [6] = { -- Sandy Shores Station
    zone    = 1, title   = "Sheriff's Office", agency = 3,
    duty    = vector3(),
    leave   = vector3(),
    walkTo  = vector3(),
    camview = vector3(),
    exitcam = vector3(),
    caminfo = {
      h     =   0.0, fov   =   0.0,
      eh    =   0.0, efov  =   0.0,
      rotx  =   0.0, roty  =   0.0, rotz  =   0.0,
      erotx =   0.0, eroty =   0.0, erotz =   0.0
    }
  },
  [7] = { -- Fort Zancudo Station
    zone    = 1, title   = "MP Station", agency = 6,
    duty    = vector3(),
    leave   = vector3(),
    walkTo  = vector3(),
    camview = vector3(),
    exitcam = vector3(),
    caminfo = {
      h     =   0.0, fov   =   0.0,
      eh    =   0.0, efov  =   0.0,
      rotx  =   0.0, roty  =   0.0, rotz  =   0.0,
      erotx =   0.0, eroty =   0.0, erotz =   0.0
    }
  },
  [8] = { -- Paleto Bay Station
    zone    = 1, title   = "Sheriff's Office", agency = 3,
    duty    = vector3(),
    leave   = vector3(),
    walkTo  = vector3(),
    camview = vector3(),
    exitcam = vector3(),
    caminfo = {
      h     =   0.0, fov   =   0.0,
      eh    =   0.0, efov  =   0.0,
      rotx  =   0.0, roty  =   0.0, rotz  =   0.0,
      erotx =   0.0, eroty =   0.0, erotz =   0.0
    }
  },
  [9] = { -- Federal Bureau of Investigations
    zone    = 1, title   = "FBI Headquarters", agency = 7,
    duty    = vector3(),
    leave   = vector3(),
    walkTo  = vector3(),
    camview = vector3(),
    exitcam = vector3(),
    caminfo = {
      h     =   0.0, fov   =   0.0,
      eh    =   0.0, efov  =   0.0,
      rotx  =   0.0, roty  =   0.0, rotz  =   0.0,
      erotx =   0.0, eroty =   0.0, erotz =   0.0
    }
  },
  [10] = { -- Highway Patrol Station
    zone    = 1, title   = "Highway Patrol", agency = 4,
    duty    = vector3(),
    leave   = vector3(),
    walkTo  = vector3(),
    camview = vector3(),
    exitcam = vector3(),
    caminfo = {
      h     =   0.0, fov   =   0.0,
      eh    =   0.0, efov  =   0.0,
      rotx  =   0.0, roty  =   0.0, rotz  =   0.0,
      erotx =   0.0, eroty =   0.0, erotz =   0.0
    }
  } ]]
}

-- Add Police Blips
Citizen.CreateThread(function()
  for _,v in pairs(depts) do
    local blip = AddBlipForCoord(v.duty)
    SetBlipSprite(blip, 526)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 1.0)
    if v.agency == 1 then SetBlipColour(blip, 67)     -- Blue   (LSPD)
    elseif v.agency == 2 then SetBlipColour(blip, 10) -- Brown  (LSSD)
    elseif v.agency == 3 then SetBlipColour(blip, 70) -- Brown  (BCSO)
    elseif v.agency == 4 then SetBlipColour(blip, 16) -- Tan    (SAHP)
    elseif v.agency == 5 then SetBlipColour(blip, 25) -- Green  (Ranger)
    else SetBlipColour(blip, 62)                      -- Silver (MP/Federal)
    end
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString(v.title)
    EndTextCommandSetBlipName(blip)
  end
end)

policeCar = {
  ["POLICE"]   = true,
  ["POLICEB"]  = true,
  ["POLICE2"]  = true,
  ["POLICE3"]  = true,
  ["POLICE4"]  = true,
  ["POLICE5"]  = true,
  ["SHERIFF"]  = true,
  ["SHERIFF2"] = true,
  ["PRANGER"]  = true,
  ["FBI"]      = true,
  ["FBI2"]     = true,
  ["PRANCHER"] = true,
  ["POLICE"]   = true,
  ["POLICE"]   = true,
  ["POLICE"]   = true,
  ["POLICE"]   = true,
  ["POLICE"]   = true,
}