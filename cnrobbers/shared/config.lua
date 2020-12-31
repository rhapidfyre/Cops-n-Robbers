
CNR = {

  spawnpoints = {
    {x =   435.76, y =  -644.29, z = 28.74},
    {x =   169.24, y =  -993.29, z = 30.10},
    {x =  126.007, y = -1732.17, z = 30.11},
    {x = -1341.36, y = -1300.10, z =  4.84},
  },

  points = {
    mostWanted  = 100,
    felony      = 40,
  },
  
  timer = {
    nextZone    = Config.MinutesPerZone()
  },
  
  levels      = {},
  police      = {}, -- On Duty Police Officers
  wanted      = {}, -- Wanted Players
  crimes      = {}, -- List of crimes by player (index)
  prisoners   = {}, -- List of prisoners
  
  -- Wanted Points Reduction
  reduce = {
    points = Config.ReductionPoints(),
    timer  = Config.ReductionTimer()
  },
  
}

function GetActiveZone()
  return CNR.zones.active
end


function GetMetaTable() return CNR end
function SetMetaTable(resName, metaName, metaData)
  if not CNR[resName] then CNR[resName] = {} end
  CNR[resName][metaName] = metaData
end

