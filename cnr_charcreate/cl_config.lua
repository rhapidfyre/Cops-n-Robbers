
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


defaultOutfits = {
  [maleHash]   = {
    [1] = { -- Default David
      {slot = 3, draw = 0, text = 0},    {slot =  4, draw = 0, text = 0},
      {slot = 6, draw = 0, text = 0},    {slot = 11, draw = 0, text = 0}, 
    },
    [2] = { -- Cali Sun
      {slot = 3, draw = 5,   text = 0},  {slot =  4, draw = 104, text = 0},
      {slot = 6, draw = 5,   text = 0},  {slot = 11, draw = 17,  text = 4}, 
    },
    [3] = { -- Lumberjack
      {slot = 3, draw = 8,  text = 0},   {slot =  4, draw = 0,  text = 1},
      {slot = 6, draw = 20, text = 0},   {slot = 11, draw = 43, text = 0}, 
    },
    [4] = { -- Club Stalker
      {slot = 3, draw = 0,   text = 0},  {slot =  4, draw = 1,   text = 0},
      {slot = 6, draw = 8,   text = 2},  {slot = 11, draw = 273, text = 17}, 
    },
    [5] = { -- Golfer Dad
      {slot = 3, draw = 0,   text = 0},  {slot =  4, draw = 0,   text = 14},
      {slot = 6, draw = 18,  text = 0},  {slot = 11, draw = 242, text = 3}, 
    },
    [6] = { -- Gym Buddy
      {slot = 3, draw = 5,   text = 0},  {slot =  4, draw = 14,  text = 1},
      {slot = 6, draw = 9,   text = 1},  {slot = 11, draw = 237, text = 2}, 
    },
  },
  [femaleHash] = {
    [1] = { -- Default Denise
      {slot = 3, draw = 0, text = 0},  {slot =  4, draw = 0, text = 0},
      {slot = 6, draw = 0, text = 0},  {slot = 11, draw = 0, text = 0}, 
    },                                 
    [2] = { -- Cali Girl
      {slot = 3, draw = 4, text = 0},  {slot =  4, draw = 25,  text = 1},
      {slot = 6, draw = 5, text = 0},  {slot = 11, draw = 195, text = 25}, 
    },                                 
    [3] = { -- Sister Cousin
      {slot = 3, draw = 4, text = 0},   {slot =  4, draw = 74,  text = 4},
      {slot = 6, draw = 7, text = 13},  {slot = 11, draw = 171, text = 1}, 
    },                                 
    [4] = { -- Morning Regret
      {slot = 3, draw = 15, text = 0},  {slot =  4, draw = 71,  text = 1},
      {slot = 6, draw = 14, text = 0},  {slot = 11, draw = 283, text = 2}, 
    },                                 
    [5] = { -- Soccer Mom
      {slot = 3, draw = 0, text = 0},   {slot =  4, draw = 4, text = 8},
      {slot = 6, draw = 10, text = 1},  {slot = 11, draw = 9, text = 9}, 
    },                                 
    [6] = { -- Beach Body
      {slot = 3, draw = 15, text = 0},  {slot =  4, draw = 17, text = 9},
      {slot = 6, draw = 5, text = 1},   {slot = 11, draw = 18, text = 9}, 
    },
  }
}


maxOverlays = {
  [0]  = 23, [1]  = 28, [2]	 = 33,
  [3]  = 14, [4]  = 74, [5]	 = 6,
  [6]  = 11, [7]  = 10, [8]	 = 9,
  [9]  = 17, [10] = 16, [11] = 11,
  [12] = 1
}

spPoints = {
  [1] = { -- Los Santos Spawn Areas
    vector3(435.76, -644.29, 28.74), -- Bus Depot
    vector3(169.24, -993.29, 30.10), -- South Legion Square
    vector3(126.007, -1732.17, 30.11), -- South Central Subway Station
    vector3(-1341.36, -1300.10, 4.84), -- South Vespucci Beach
  },
  [2] = { -- Senora Desert Spawn Areas
  },
  [3] = { -- Paleto Bay Spawn Areas
  }
}

