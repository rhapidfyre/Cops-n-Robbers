
-- Multipliers for crimes committed
worth = {attempt = 0.33,law = 1.425,}

-- Called to get the wanted point weight of a crime
weights = {
  ['jailed']       =  99,
  ['carjack']      =  25,
  ['murder']       =  90,
  ['manslaughter'] =  60,
  ['adw']          =  20,
  ['assault']      =   3,
  ['discharge']    =   6,
  ['vandalism']    =   5,
  ['atm']          =  30,
  ['brandish']     =  20,
  ['robbery']      =  50,
  ['prisonbreak']  = 200
}

felonies = {
  ['carjack']      = true,
  ['murder']       = true,
  ['adw']          = true,
  ['atm']          = true,
  ['robbery']      = true,
  ['prisonbreak']  = true,
}

--- EXPORT: CrimePoints()
-- Returns the point worth of given crime.
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The wanted point weight of the crime (always int, 0 if not found)
function CrimePoints(crime)
  if not crime          then return 0 end
  if not weights[crime] then return 0 end
  return weights[crime]
end


--- EXPORT: CrimeName()
-- Returns the proper name of the given crime.
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The name of the crime (always string, 'crime' if not found)
function CrimeName(crime)
  if not crime            then return "crime" end
  if not crimeName[crime] then return "crime" end
  return crimeName[crime]
end