
CNR = {

  points = {
    mostWanted  = 100,
    felony      = 40,
  },
  
  timer = {
    nextZone    = Config.MinutesPerZone()
  }
  
  wanted = {},
  levels = {},
}


function GetActiveZone()
  return CNR.activeZone
end


function GetMetaTable() return CNR end
function SetMetaTable(resName, metaName, metaData)
  if not CNR[resName] then CNR[resName] = {} end
  CNR[resName][metaName] = metaData
end

