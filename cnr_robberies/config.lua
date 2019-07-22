
--[[
  Cops and Robbers: Convenience Robberies (SHARED CONFIG)
  Created by Michael Harris (mike@harrisonline.us)
  07/19/2019
  
  Contains coordinates and other shared variable information.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

--[[ OPTIONALS:
  safe: If exists, bonus safe for extra cash
  bDoor: If exists, backdoor exit point
    alley: Where bDoor gets out. One way. If bDoor exists then alley exists
]]

clerkModels = {"a_f_y_indian_01","a_f_o_indian_01"}

rob = {
  [1] = {
    title = "LTD Gasoline", area = "Little Seoul", h = 90.0,
    spawn = vector3(-705.999, -914.445, 19.215),
    stand = vector3(-707.797, -914.6, 19.215),
    bDoor = vector3(-708.032, -903.785, 19.215),
    alley = vector3(-702.993, -916.828, 19.214),
    safe  = vector3(-709.772, -904.173, 19.215)
  },
  [2] = {
    title = "Rob's Liquor", area = "Vespucci Beach", h = 50.0,
    spawn = vector3(-1221.34, -908.216, 12.326),
    stand = vector3(-1223.42, -907.185, 12.326),
    safe  = vector3(-1220.86, -915.987, 11.326)
  }
}

