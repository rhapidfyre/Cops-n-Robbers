
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
    ped  = vector3(-1756.53, -1117.24, 0.0),
    view = vector3(-1756.53, -1117.24, 18.0),
    h    = 280.0,
    rotx = 6.0,
    roty = 0.0,
    rotz = 0.0
  }
}
