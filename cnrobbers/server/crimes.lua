
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
  ['gta-npc'] = {
    title = "Grand Theft Auto",
    weight = 51, minTime = 0, maxTime = 0, isFelony = false,
    fine = function() return (math.random(10, 50)) end
  },
  ['gta'] = {
    title = "Grand Theft Auto",
    weight = 76, minTime = 0, maxTime = 0, isFelony = true,
    fine = function() return (math.random(10, 50)) end
  },
  ['carjack-npc'] = {
    title = "Carjacking",
    weight = 31, minTime = 0, maxTime = 0, isFelony = true,
    fine = function() return (math.random(100, 250)) end
  },
  ['carjack'] = {
    title = "Carjacking",
    weight = 61, minTime = 10, maxTime = 25, isFelony = true,
    fine = function() return (math.random(100, 400)) end
  },
  ['murder'] = {
    title = "Murder",
    weight = 190, minTime = 90, maxTime = 120, isFelony = true,
    fine = function() return (math.random(5000, 8000)) end
  },
  ['murder-leo'] = {
    title = "Murder of a LEO",
    weight = 220, minTime = 10, maxTime = 25, isFelony = true,
    fine = function() return (math.random(6250, 12000)) end
  },
  ['mans-veh'] = {
    title = "Vehicular Manslaughter",
    weight = 220, minTime = 10, maxTime = 25, isFelony = true,
    fine = function() return (math.random(6250, 12000)) end
  },
  ['manslaughter'] = {
    title = "Manslaughter",
    weight = 45, minTime = 5, maxTime = 10, isFelony = false,
    fine = function() return (math.random(1000, 2000)) end
  },
  ['adw'] = {
    title = "Assault with a Deadly Weapon",
    weight = 60, minTime = 5, maxTime = 20, isFelony = true,
    fine = function() return (math.random(500, 800)) end
  },
  ['assault'] = {
    title = "Simple Assault",
    weight = 10, minTime = 1, maxTime = 5, isFelony = false,
    fine = function() return (math.random(50, 100)) end
  },
  ['discharge'] = {
    title = "Firearm Discharge",
    weight = 12, minTime = 1, maxTime = 5, isFelony = false,
    fine = function() return (math.random(20, 40)) end
  },
  ['vandalism'] = {
    title = "Vandalism",
    weight = 5, minTime = 1, maxTime = 5, isFelony = false,
    fine = function() return (math.random(10, 20)) end
  },
  ['robbery'] = {
    title = "Armed Robbery",
    weight = 90, minTime = 20, maxTime = 30, isFelony = true,
    fine = function() return (math.random(500, 2000)) end
  },
  ['robbery-sa'] = {
    title = "Strong-Arm Robbery",
    weight = 42, minTime = 5, maxTime = 20, isFelony = true,
    fine = function() return (math.random(100, 140)) end
  },
  ['atm'] =  {
    title = "ATM Burglary",
    weight = 32, minTime = 5, maxTime = 15, isFelony = false,
    fine = function() return (math.random(600, 2000)) end
  },
  ['unpaid'] = {
    title = "Unpaid Ticket",
    weight = 50, minTime = 1, maxTime = 10, isFelony = true,
    fine = function() return (math.random(100, 500)) end
  },
  ['brandish'] = {
    title = "Weapon Brandished",
    weight = 5, minTime = 2, maxTime = 5, isFelony = false,
    fine = function() return (math.random(200, 1000)) end
  },
  ['brandish-npc'] = {
    title = "Weapon Brandished",
    weight = 5, minTime = 1, maxTime = 2, isFelony = false,
    fine = function() return (math.random(100, 500)) end
  },
  ['brandish-leo'] = {
    title = "Weapon Brandished on a LEO",
    weight = 50, minTime = 5, maxTime = 10, isFelony = true,
    fine = function() return (math.random(500, 1200)) end
  },
  ['prisonbreak'] = {
    title = "Prison Break",
    weight = 400, minTime = 20, maxTime = 30, isFelony = true,
    fine = function() return (math.random(12000, 20000)) end
  },
  ['jailbreak'] = {
    title = "Jailbreak",
    weight = 120, minTime = 5, maxTime = 10, isFelony = true,
    fine = function() return (math.random(5000, 8000)) end
  },
  ['traffic_drug'] = {
    title = "Drug Trafficking",
    weight = 30, minTime = 12, maxTime = 20, isFelony = true,
    fine = function() return (math.random(100, 500)) end
  },
  ['traffic_guns'] = {
    title = "Weapons Trafficking",
    weight = 30, minTime = 12, maxTime = 20, isFelony = true,
    fine = function() return (math.random(100, 500)) end
  },
  ['traffic_chop'] = {
    title = "Possession of Chopshop Parts",
    weight = 30, minTime = 5, maxTime = 12, isFelony = true,
    fine = function() return (math.random(100, 500)) end
  },
  ['trafficking'] = {
    title = "Human Trafficking",
    weight = 180, minTime = 15, maxTime = 40, isFelony = true,
    fine = function() return (math.random(6000, 9000)) end
  },
  ['kidnapping-npc'] = {
    title = "Kidnapping",
    weight = 90, minTime = 5, maxTime = 10, isFelony = true,
    fine = function() return (math.random(100, 500)) end
  },
  ['auto-export'] = {
    title = "Illegal Vehicle Sale",
    weight = 60, minTime = 5, maxTime = 10, isFelony = true,
    fine = function() return (math.random(2400, 8000)) end
  },
}

--- EXPORT: GetCrimeName()
-- Returns the proper name of the given crime.
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The name of the crime (always string, 'crime' if not found)
function GetCrimeName(crime)
  if not crime               then  return  "crime"  end
  if not crimes[crime]       then  return  "crime"  end
  if not crimes[crime].title then  return  "crime"  end
  return crimes[crime].title
end


--- EXPORT: GetCrimeTime()
-- Returns the generated time for the given crime
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The time (in minutes) to serve. If not found, returns 0 minutes
function GetCrimeTime(crime)
  if not crime         then return 0 end
  if not crimes[crime] then return 0 end
  local c = crimes[crime]
  if not c.minTime then c.minTime =  5 end
  if not c.maxTime then c.maxTime = 10 end
  local cTime = math.random(c.minTime, c.maxTime)
  return cTime
end


--- EXPORT: GetCrimeFine()
-- Returns the generated fine for the crime
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The time (in minutes) to serve. If not found, returns 50 dollars
function GetCrimeFine(crime)
  if not crime              then  return 0 end
  if not crimes[crime]      then  return 0 end
  if not crimes[crime].fine then  return 0 end
  return (crimes[crime].fine())
end


--- EXPORT: IsCrimeFelony()
-- Gets whether the given crime is a felony
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The time (in minutes) to serve. If not found, returns 50 dollars
function IsCrimeFelony(crime)
  if not crime                  then  return false  end
  if not crimes[crime]          then  return false  end
  if not crimes[crime].isFelony then  return false  end
  return (crimes[crime].isFelony)
end


--- EXPORT: GetCrimeWeight()
-- Gets the severity of a crime
-- @param crime The string of the title of the crime (carjack, murder, etc)
-- @return The severity weight, where 1 is least severe
function GetCrimeWeight(crime)
  if not crime                 then  return 1 end
  if not crimes[crime]         then  return 1 end
  if not crimes[crime].weight  then  return 1 end
  return (crimes[crime].weight)
end


--- EXPORT: DoesCrimeExist()
-- Checks if the given crime index exists in the table
-- @param crime The string to check for
-- @return True if the crime exists, false if it does not
function DoesCrimeExist(crime)
  if crimes[crime] then
    if crimes[crime].title then
      return true
    else
      cprint("^1Crime '"..tostring(crime).."' did not exist in sh_wanted.lua")
      return false
    end
  else
    cprint("^1Crime '"..tostring(crime).."' did not exist in sh_wanted.lua")
    return false
  end
end


--- EXPORT: AddCrime()
-- Allows other scripts to add a crime to the list
function AddCrime(cName, cTable)
  if crimes[cName] then return false end
  if not cTable then
    ConsolePrint("^1No table (args[2]) was given to AddCrime()")
    return false
  end
  if not cTable.title then 
    ConsolePrint("^1No title in args[2] was given to AddCrime()")
    return false
  end
  if not cTable.weight then cTable.weight = 1 end
  if not cTable.minTime then cTable.minTime = 5 end
  if not cTable.maxTime then cTable.maxTime = 15 end
  if not cTable.fine then
    cTable.fine = function() return math.random(1000,5000) end
  end
  crimes[cName] = cTable
  return true
end


