
--[[
  Cops and Robbers: Character Creation (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  05/11/2019
  
  This file handles all client-sided configuration settings, and
  variable declarations for use by client scripts in this resource.
  
  No one may edit, redistribute, or otherwise use this script other than
  for the purpose of playing on a server that is utilizing this script.
--]]


-- Hash key's used for storing indexes and comparing
maleHash	 = GetHashKey("mp_m_freemode_01")
femaleHash = GetHashKey("mp_f_freemode_01")

cams = {
  start = {
    ped  = vector3(-1756.53, -1117.24, 0.0),  -- Where ped spawns
    view = vector3(-1756.53, -1117.24, 18.0), -- Where camera goes
    h    = 280.0,
    rotx = 6.0,
    roty = 0.0,
    rotz = 0.0
  },
  creator = {
    ped  = vector3(399.82, -997.438, -99.004),
    view = vector3(402.80, -999.16, -98.72),
    walk = vector3(402.80, -996.66, -99.004), -- Where to walk to
    h    = 270.0,
    rotx = 0.0,
    roty = 0.0,
    rotz = 0.0
  }
}

creation = {
  dict = "mp_character_creation@lineup@male_a",
  anim = "intro",
  done = "outro",
}

maxOverlays = {
  [0]   = 23, [1]	  = 28, [2]	  = 33,
  [3]   = 14, [4]	  = 74, [5]	  = 6,
  [6]   = 11, [7]   = 10, [8]	  = 9,
  [9]   = 17, [10]  = 16, [11]	= 11,
  [12]	= 1
}