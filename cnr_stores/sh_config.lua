

-- ID # is important, so let's index it
storeItems = {
  [1] = { ['name'] = "item_window_breaker", ['title'] = "Window Breaker", ['img'] = "wbreaker",
    ['price'] = 1000, ['consume'] = true, ['model'] = nil },
    
  [2] = { ['name'] = "item_fishing_bait", ['title'] = "Fishing Bait", ['img'] = "fish_bait_poor",
    ['price'] = 10, ['consume'] = true, ['model'] = nil },
    
  [3] = { ['name'] = "item_fishing_rod", ['title'] = "Fishing Rod", ['img'] = "fish_rod_poor",
    ['price'] = 10, ['consume'] = true, ['model'] = nil },
    
  [4] = { ['name'] = "drink_water", ['title'] = "Water", ['img'] = "water_bottle",
    ['price'] = 3, ['consume'] = true, ['model'] = nil },
    
  [5] = { ['name'] = "food_hamburger", ['title'] = "Burger", ['img'] = "hamburger",
    ['price'] = 10, ['consume'] = true, ['model'] = nil },
    
  [6] = { ['name'] = "food_bag_of_chips", ['title'] = "Chips", ['img'] = "chip_bag",
    ['price'] = 1, ['consume'] = true, ['model'] = nil },
    
  [7] = { ['name'] = "drink_sprunk", ['title'] = "Sprunk", ['img'] = "soda_sprunk",
    ['price'] = 1, ['consume'] = true, ['model'] = nil },
    
  [8] = { ['name'] = "liquor_beer", ['title'] = "Beer", ['img'] = "beer_bottle",
    ['price'] = 5, ['consume'] = true, ['model'] = nil },
    
  [9] = { ['name'] = "lotto_ticket", ['title'] = "Lotto Ticket", ['img'] = "lotto_ticket",
    ['price'] = 100, ['consume'] = true, ['model'] = nil },
    
  [10] = { ['name'] = "lotto_scratcher", ['title'] = "Scratcher", ['img'] = "scratchers",
    ['price'] = 100, ['consume'] = true, ['model'] = nil },
}


-- The Store # must be consistent across all clients & server,
-- so we want to be sure to index it.
stores = {
  [1] = {
    title = "LTD Gasoline", area = "Little Seoul",
    pos = vector3(-707.797, -914.6, 19.215)
  },
  [2] = {
    title = "Rob's Liquor", area = "Vespucci Beach",
    pos = vector3(-1223.42, -907.185, 12.326)
  },
  [3] = {
    title = "Rob's Liquor", area = "Morningwood",
    pos = vector3(-1487.71, -378.751, 40.1634)
  },
  [4] = {
    title = "24/7 Supermarket", area = "Strawberry",
    pos = vector3(26.087, -1346.73, 29.497)
  },
  [5] = {
    title = "LTD Gasoline", area = "Grove Street",
    pos = vector3(-48.2451, -1757.34, 29.421)
  },
  [6] = {
    title = "Rob's Liquor", area = "Murrietta Heights",
    pos = vector3(1135.73, -982.734, 46.4158)
  },
  [7] = {
    title = "LTD Gasoline", area = "Mirror Park",
    pos = vector3(1163.12, -323.425, 69.2051)
  },
  [8] = {
    title = "24/7 Supermarket", area = "Vinewood",
    pos = vector3(374.379, 326.203, 103.566)
  },
  [9] = {
    title = "24/7 Supermarket", area = "Palomino Freeway",
    pos = vector3(2556.586, 382.632, 108.623)
  },
  [10] = {
    title = "24/7 Supermarket", area = "Senora Freeway",
    pos = vector3(2678.52, 3281.32, 55.2411)
  },
  [11] = {
    title = "Rob's Liquor", area = "Route 68",
    pos = vector3(1165.83, 2708.94, 38.1577)
  },
  [12] = {
    title = "24/7 Supermarket", area = "Harmony",
    pos = vector3(547.439, 2670.51, 42.1565)
  },
  [13] = {
    title = "Liquor Ace", area = "Sandy Shores",
    pos = vector3(1393.86, 3604.93, 39.9808)
  },
  [14] = {
    title = "24/7 Supermarket", area = "Sandy Shores",
    pos = vector3(1961.64, 3741.29, 32.3437)
  },
  [15] = {
    title = "LTD Gasoline", area = "Grapeseed",
    pos = vector3(1698.82, 4924.76, 42.0637)
  },
  [16] = {
    title = "24/7 Supermarket", area = "Braddock",
    pos = vector3(1729.56, 6414.59, 35.0372)
  },
  [17] = {
    title = "24/7 Supermarket", area = "N. Chumash",
    pos = vector3(-3242.43, 1001.86, 12.8307)
  },
  [18] = {
    title = "Rob's Liquor", area = "Chumash",
    pos = vector3(-2968.15, 390.602, 15.0433)
  },
  [19] = {
    title = "24/7 Supermarket", area = "Chumash",
    pos = vector3(-3039.81, 585.854, 7.909)
  },
  [20] = {
    title = "LTD Gasoline", area = "Richman Glen",
    pos = vector3(-1821.12, 792.997, 138.118)
  }
}

