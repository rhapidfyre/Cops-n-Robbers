
--[[
  Cops and Robbers: Wanted Script - Shared Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/20/2019
  
  This file's main purpose is the definition of criminal events.
  
  We don't want client modders to modify the fines or times they would receive.
  Thus, the variable is secure to this file and only accessible by accessors.
  
--]]


mw     = 101 -- The value a player becomes "Most Wanted"
felony = 40  -- The value a player becomes a Felon.
wanted = {} -- Table of wanted players (KEY: Server Id, VAL: Points)


--[[
  VAR: crimes
  INFO: Holds the crimes information.
  KEY: crime designation/event
  VALUE: (Table)
    title:    The title of the crime for display purposes/referencing
    weight:   Used for organizing seriousness of a crime (1 being most serious)
    minTime:  The minimum time that can be given for this crime
    maxTime:  The maximum time that can be given for this crime
    isFelony: This crime can make the player exceed Wanted Level 5
    fine:     The amount of the fine (if applicable)
]]
local crimes = {
  ['carjack'] = {
    title = "Carjacking",
    weight = 40, minTime = 10, maxTime = 25, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['murder'] = {
    title = "Murder",
    weight = 2, minTime = 90, maxTime = 120, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['murder-leo'] = {
    title = "Murder of a Law Enforcement Officer",
    weight = 1, minTime = 10, maxTime = 25, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['manslaughter'] = {
    title = "Manslaughter (Killing an NPC)",
    weight = 20, minTime = 5, maxTime = 10, isFelony = false,
    fine = function() return (math.random(100, 1000)) end
  },
  ['adw'] = {
    title = "Assault with a Deadly Weapon",
    weight = 10, minTime = 5, maxTime = 20, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['assault'] = {
    title = "Simple Assault",
    weight = 60, minTime = 1, maxTime = 5, isFelony = false,
    fine = function() return (math.random(100, 1000)) end
  },
  ['discharge'] = {
    title = "Discharging a Firearm",
    weight = 90, minTime = 1, maxTime = 5, isFelony = false,
    fine = function() return (math.random(100, 1000)) end
  },
  ['vandalism'] = {
    title = "Vandalism",
    weight = 100, minTime = 1, maxTime = 5, isFelony = false,
    fine = function() return (math.random(100, 1000)) end
  },
  ['robbery'] = {
    title = "Armed Robbery",
    weight = 32, minTime = 20, maxTime = 30, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['robbery-sa'] = {
    title = "Strong-Arm Robbery",
    weight = 42, minTime = 5, maxTime = 20, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
  ['atm'] =  {
    title = "ATM Robbery",
    weight = 50, minTime = 5, maxTime = 15, isFelony = true,
    fine = function() return (math.random(100, 1000)) end
  },
}

--- EXPORT: GetCrimeName()
-- Returns the proper name of the given crime.
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The name of the crime (always string, 'crime' if not found)
function GetCrimeName(crime)
  if not crime         then return "crime" end
  if not crimes[crime] then return "crime" end
  return crimes[crime]
end


--- EXPORT: GetCrimeTime()
-- Returns the generated time for the given crime
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The time (in minutes) to serve. If not found, returns 0 minutes
function GetCrimeTime(crime)
  if not crime         then return 0 end
  if not crimes[crime] then return 0 end
  local c = crimes[crime]
  return (math.random(c.minTime, c.maxTime))
end


--- EXPORT: GetCrimeFine()
-- Returns the generated fine for the crime
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The time (in minutes) to serve. If not found, returns 50 dollars
function GetCrimeFine(crime)
  if not crime         then return 0 end
  if not crimes[crime] then return 0 end
  return (crimes[crime].fine)
end


--- EXPORT: IsCrimeFelony()
-- Gets whether the given crime is a felony
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The time (in minutes) to serve. If not found, returns 50 dollars
function IsCrimeFelony(crime)
  if not crime         then return false end
  if not crimes[crime] then return false end
  return (crimes[crime].isFelony)
end


--- EXPORT: GetCrimeWeight()
-- Gets the severity of a crime
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The severity weight, where 1 is most severe and 100 is least severe
function GetCrimeWeight(crime)
  if not crime         then return 100 end
  if not crimes[crime] then return 100 end
  return (crimes[crime].weight)
end