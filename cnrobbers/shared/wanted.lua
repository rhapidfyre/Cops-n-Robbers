

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


--- EXPORT GetWanteds()
-- Returns the table of wanted players
-- @return table The list of wanteds (KEY: Server ID, VAL: Wanted Points)
function GetWanteds() return CNR.wanted end


--- EXPORT WantedLevel()
-- Returns the wanted level of the player for easier calculation
-- @param ply Server ID, if provided. Local client if not provided.
-- @return The wanted level based on current wanted points
function WantedLevel(ply)

  -- If ply not given, return 0
  if not ply then ply = GetPlayerServerId(PlayerId()) end
  if not CNR.wanted[ply] then CNR.wanted[ply] = 0 end -- Create entry if not exists

  if     CNR.wanted[ply] <   1 then return  0
  elseif CNR.wanted[ply] > 100 then return 11
  end
  return (math.ceil((CNR.wanted[ply])/10))

end


