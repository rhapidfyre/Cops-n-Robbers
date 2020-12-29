
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


--- IsWanted()
-- Returns if the player is wanted (boolean)
-- Client: No Arguments
-- Server: Player Server ID Required
function IsWanted(ply)
  if not ply then ply = GetPlayerServerId(PlayerId()) end
  return CNR.wanted[ply]
end


--- GetMostWanted()
-- Returns the most wanted player's Server ID
-- Returns zero if there is no Most Wanted player
function GetMostWanted()
  local mw    = 0
  local mwMax = 40 -- Only consider felons
  for idPlayer,wantedPoints in pairs (CNR.wanted) do 
    if wantedPoints > mwMax then
      mw    = idPlayer
      mwMax = wantedPoints
    end
  end
  return mw
end


--- IsMostWanted()
-- Returns if the player is wanted (boolean)
-- Client: No Arguments
-- Server: Player Server ID Required
function IsMostWanted(client)
  local ply = -1
  if not client then ply = GetPlayerServerId(PlayerId())
  else ply = tonumber(client)
  end
  local mw = GetMostWanted()
  return (mw == ply and mw > 0)
end


function GetActiveZone()
  return CNR.activeZone
end


function GetMetaTable() return CNR end
function SetMetaTable(resName, metaName, metaData)
  if not CNR[resName] then CNR[resName] = {} end
  CNR[resName][metaName] = metaData
end

