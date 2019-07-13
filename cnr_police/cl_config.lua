
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

depts = {
  [1] = { -- Mission Row
    zone    = 1,
    duty    = vector3(452.811, -989.455, 30.689),
    walkTo  = vector3(447.79, -986.319, 30.689),
    blip    = vector3(452.811, -989.455, 30.689),
    camview = vector3(410.313, -961.877, 32.4769),
    exitcam = vector3(445.723, -988.74, 30.25),
    holding = vector3(458.675, -991.484, 30.689),
    caminfo = {
      h     = 235.00, fov   = 60.0,
      eh    = 235.00, efov  = 80.0,
      rotx  =    0.0, roty  =  0.0, rotz = 235.0,
      erotx =    0.0, eroty =  0.0, erotz = 292.0
    }
  }
}
