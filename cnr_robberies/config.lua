
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

-- Where index is the zone number
dropSpots = {
  [1] = {
    {vector3(-14.6003, -1439.58, 31.1015)}, -- Franklin's House in Strawberry
    {vector3(149.797, -1961.45, 19.0893)},  -- Random house on Roy Lowenstein
    {vector3(-57.8424, -1531.77, 34.362)},  -- Drug Den Apartment, Apt #6
    {vector3(-1078.39, -1678.78, 4.575)},   -- Vagos HQ south Garage
    {vector3(-690.074, -893.10, 24.4991)},  -- Apt behind LTD Gas Little Seoul
    {vector3(-1579.13, -441.046, 37.965)},  -- Shady apartments in Richmond
    {vector3(244.892, 369.263, 105.738)},   -- Epsilon Storage Unit
    {vector3(1274.64, -1720.81, 54.681)},   -- Lester's House
    {vector3(753.594, -3182.51, 7.405)},    -- Warehouse in Port of L.S.
    {vector3(-941.21, -2954.27, 19.845)},   -- Devin Weston's Hangar
  },
  [2] = {
    {vector3(1395.34, 1141.9, 114.637)},    -- Mondrago Ranch House
    {vector3(2357.11, 2608.96, 46.370)},    -- Trailer Park "Prop 208"
    {vector3(570.398, 2671.65, 42.005)},    -- Liquor Market (Harmony)
    {vector3(1551.2, 3800.03, 34.411)},     -- The Boat House (Sandy)
    {vector3(26.18, 3275.08, 55.738)},      -- House near YouTool
    {vector3(1972.77, 3817.77, 33.428)},    -- Trevor's Trailer
    {vector3(2728.55, 4287.13, 48.961)},    -- Trailer in East Joshua
    {vector3(3817.42, 4482.47, 5.993)},     -- Coast House in East
  },
  [3] = {
    {vector3(1644.29, 4857.83, 42.011)},    -- Abandoned Shop in NW Grapeseed
    {vector3(2448.44, 4978.05, 51.565)},    -- Grapeseed Drug House
    {vector3(1417.25, 6339.29, 24.398)},    -- Communist Camp
    {vector3(-58.16, 6441.54, 32.685)},     -- Open garage in North Paleto Bay
    {vector3(-400.172, 6377.89, 14.051)},   -- Paleto Bay Beach Shack
    {vector3(-538.07, 5288.4, 75.3631)},    -- Lumbermill Gang House
    {vector3(3311.05, 5176.2, 19.614)},     -- Hooker House in East
  },
  [4] = {
    {vector3(42.133, 3706.45, 39.749)},    -- Stab City
    {vector3(-2188.03, 3323.00, 32.837)},  -- Ft. Zancudo (North)
    {vector3(195.107, 3030.73, 43.886)},   -- Yellow House on Joshua Rd
    {vector3(-1929.22, 1778.94, 173.096)}, -- Redwood Cigarettes Shack
    {vector3(-2797.92, 1431.53, 100.928)}, -- Banham Canyon House
    {vector3(-3194.97, 1220.74, 10.048)},  -- Chumash (North)
    {vector3(-3099.8, 211.702, 14.07)},    -- Chumash (South)
  },
}