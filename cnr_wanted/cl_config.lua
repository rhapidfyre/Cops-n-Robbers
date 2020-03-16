
-- Index weapons that player SHOULD NOT be charged with for aiming
local isSafe = {
  [GetHashKey("WEAPON_UNARMED")] = true,
  [GetHashKey("WEAPON_FIST")] = true,
  [GetHashKey("WEAPON_BALL")] = true,
  [GetHashKey("WEAPON_SNOWBALL")] = true,
  [GetHashKey("WEAPON_TEARGAS")] = true,
  [GetHashKey("WEAPON_JERRYCAN")] = true,
  [GetHashKey("WEAPON_FLARE")] = true,
  [GetHashKey("WEAPON_BZGAS")] = true,
}

--- IsAimCrime()
-- Checks if the weapon being aimed should be a Brandishing Crime
-- @return True if the player SHOULD be charged with Firearm Brandishing
function IsAimCrime(weaponHash)
  if not weaponHash then return false end
  return isSafe[weaponHash]
end