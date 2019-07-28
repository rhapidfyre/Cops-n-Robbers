
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
    title = "LTD Gasoline", area = "Little Seoul", h = 90.0, zone = 1,
    spawn = vector3(-705.999, -914.445, 19.215),
    stand = vector3(-707.797, -914.6, 19.215),
    bDoor = vector3(-708.032, -903.785, 19.215),
    alley = vector3(-702.993, -916.828, 19.214),
    safe  = vector3(-709.772, -904.173, 19.215)
  },
  [2] = {
    title = "Rob's Liquor", area = "Vespucci Beach", h = 50.0, zone = 1,
    spawn = vector3(-1221.34, -908.216, 12.326),
    stand = vector3(-1223.42, -907.185, 12.326),
    safe  = vector3(-1220.86, -915.987, 11.326)
  },
  [3] = {
    title = "Rob's Liquor", area = "Morningwood", h = 130.0, zone = 1,
    spawn = vector3(-1485.61, -378.147, 40.1634),
    stand = vector3(-1487.71, -378.751, 40.1634),
    safe  = vector3(-1478.99, -375.429, 39.1634)
  },
  [4] = {
    title = "24/7 Supermarket", area = "Strawberry", h = 180.0, zone = 1,
    spawn = vector3(24.3269, -1346.84, 29.497),
    stand = vector3(26.087, -1346.73, 29.497),
    safe  = vector3(28.3062, -1339.23, 29.497)
  },
  [5] = {
    title = "LTD Gasoline", area = "Grove Street", h = 75.0, zone = 1,
    spawn = vector3(-46.9504, -1758.19, 29.421),
    stand = vector3(-48.2451, -1757.34, 29.421),
    bDoor = vector3(-41.7812, -1748.97, 29.421),
    alley = vector3(-40.8349, -1747.9, 29.3235),
    safe  = vector3(-43.4315, -1748.45, 29.421)
  },
  [6] = {
    title = "Rob's Liquor", area = "Murrietta Heights", h = 270.0, zone = 1,
    spawn = vector3(1133.78, -981.921, 46.4158),
    stand = vector3(1135.73, -982.734, 46.4158),
    safe  = vector3(1126.86, -980.077, 45.4158)
  },
  [7] = {
    title = "LTD Gasoline", area = "Mirror Park", h = 90.0, zone = 1,
    spawn = vector3(1164.81, -323.051, 69.2051),
    stand = vector3(1163.12, -323.425, 69.2051),
    bDoor = vector3(1160.96, -313.148, 69.2051),
    alley = vector3(1160.64, -311.402, 69.2775),
    safe  = vector3(1159.56, -314.129, 69.2051)
  },
  [8] = {
    title = "24/7 Supermarket", area = "Vinewood", h = 256.0, zone = 1,
    spawn = vector3(372.385, 326.991, 103.566),
    stand = vector3(374.379, 326.203, 103.566),
    bDoor = vector3(380.936, 331.13, 103.566),
    alley = vector3(379.976, 357.01, 102.573),
    safe  = vector3(378.241, 333.341, 103.566)
  },
  [9] = {
    title = "24/7 Supermarket", area = "Palomino Freeway", h = 358.0, zone = 2,
    spawn = vector3(2556.82, 380.685, 108.623),
    stand = vector3(2556.586, 382.632, 108.623),
    bDoor = vector3(2550.97, 387.978, 108.623),
    alley = vector3(2553.08, 399.552, 108.59),
    safe  = vector3(2549.2, 384.888, 108.623)
  },
  [10] = {
    title = "24/7 Supermarket", area = "Senora Freeway", h = 340.0, zone = 2,
    spawn = vector3(2677.67, 3279.57, 55.2411),
    stand = vector3(2678.52, 3281.32, 55.2411),
    bDoor = vector3(2675.71, 3288.73, 55.2411),
    alley = vector3(2670.49, 3286.51, 55.2405),
    safe  = vector3(2672.74, 3286.56, 55.2411)
  },
  [11] = {
    title = "Rob's Liquor", area = "Route 68", h = 188.0, zone = 2,
    spawn = vector3(1166.32, 2710.85, 38.1577),
    stand = vector3(1165.83, 2708.94, 38.1577),
    safe  = vector3(1169.3, 2717.87, 37.1577)
  },
  [12] = {
    title = "24/7 Supermarket", area = "Harmony", h = 90.0, zone = 2,
    spawn = vector3(549.5, 2670.75, 42.1565),
    stand = vector3(547.439, 2670.51, 42.1565),
    bDoor = vector3(543.583, 2663.67, 42.1565),
    alley = vector3(540.909, 2663.39, 42.1636),
    safe  = vector3(546.396, 2662.75, 42.1565)
  },
  [13] = {
    title = "Liquor Ace", area = "Sandy Shores", h = 165.0, zone = 2,
    spawn = vector3(1393.12, 3606.68, 39.9808),
    stand = vector3(1393.86, 3604.93, 39.9808),
  },
  [14] = {
    title = "24/7 Supermarket", area = "Sandy Shores", h = 310.0, zone = 2,
    spawn = vector3(1959.69, 3740.56, 32.3437),
    stand = vector3(1961.64, 3741.29, 32.3437),
    bDoor = vector3(1962.85, 3749.15, 32.3437),
    alley = vector3(1964.46, 3750.81, 32.3437),
    safe  = vector3(1959.34, 3748.92, 32.3437)
  },
  [15] = {
    title = "LTD Gasoline", area = "Grapeseed", h = 306.0, zone = 3,
    spawn = vector3(1697.63, 4923.15, 42.0637),
    stand = vector3(1698.82, 4924.76, 42.0637),
    bDoor = vector3(1707.15, 4918.88, 42.0637),
    alley = vector3(1702.19, 4916.11, 42.0781),
    safe  = vector3(1707.79, 4920.46, 42.0637)
  },
  [16] = {
    title = "24/7 Supermarket", area = "Braddock", h = 225.0, zone = 3,
    spawn = vector3(1727.92, 6415.65, 35.0372),
    stand = vector3(1729.56, 6414.59, 35.0372),
    bDoor = vector3(1737.03, 6418.02, 35.0373),
    alley = vector3(1741.56, 6419.79, 35.0425),
    safe  = vector3(1734.74, 6420.85, 35.0373)
  },
  [17] = {
    title = "24/7 Supermarket", area = "N. Chumash", h = 0.0, zone = 4,
    spawn = vector3(-3242.75, 999.957, 12.8307),
    stand = vector3(-3242.43, 1001.86, 12.8307),
    safe  = vector3(-3250.03, 1004.36, 12.8307)
  },
  [18] = {
    title = "Rob's Liquor", area = "Chumash", h = 90.0, zone = 4,
    spawn = vector3(-2966.32, 390.397, 15.0433),
    stand = vector3(-2968.15, 390.602, 15.0433),
    safe  = vector3(-2959.61, 387.152, 14.0433)
  },
  [19] = {
    title = "24/7 Supermarket", area = "Chumash", h = 18.0, zone = 4,
    spawn = vector3(-3039.26, 584.362, 7.909),
    stand = vector3(-3039.81, 585.854, 7.909),
    bDoor = vector3(-3047.37, 589.026, 7.909),
    alley = vector3(-3047.9, 590.623, 7.754),
    safe  = vector3(-3047.77, 585.51, 7.909)
  },
  [20] = {
    title = "LTD Gasoline", area = "Richman Glen", h = 132.0, zone = 4,
    spawn = vector3(-1819.76, 793.864, 138.118),
    stand = vector3(-1821.12, 792.997, 138.118),
    bDoor = vector3(-1828.34, 800.186, 138.19),
    alley = vector3(-1829.69, 801.39, 138.411),
    safe  = vector3(-1829.11, 798.741, 138.19)
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