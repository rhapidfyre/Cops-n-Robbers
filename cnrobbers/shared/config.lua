
CNR = {

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

