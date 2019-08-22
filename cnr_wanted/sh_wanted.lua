
--[[
  Cops and Robbers: Wanted Script - Shared Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/20/2019
  
  This file contains the wanted info (level, points, etc) for players.
  
  For example, if you try to change the client coordinates for a money drop,
  when your client requests verification, the server will deny you're there.
--]]


mw     = 101 -- The value a player becomes "Most Wanted"
felony = 40  -- The value a player becomes a Felon.
wanted = {} -- Table of wanted players (KEY: Server Id, VAL: Points)


-- Called to get the proper name of a crime
crimeName = {
  ['carjack']      = "Carjacking",
  ['murder']       = "Murder",
  ['manslaughter'] = "Manslaughter",
  ['adw']          = "Assault with a Deadly Weapon",
  ['assault']      = "Assault",
  ['discharge']    = "Discharging a Firearm",
  ['vandalism']    = "Vandalism",
  ['robbery']      = "Robbery",
  ['atm']          = "ATM Heist",
}


--- EXPORT: CrimeName()
-- Returns the proper name of the given crime.
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The name of the crime (always string, 'crime' if not found)
function CrimeName(crime)
  if not crime            then return "crime" end
  if not crimeName[crime] then return "crime" end
  return crimeName[crime]
end