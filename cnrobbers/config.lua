
Config = {}

-- How many zones to use for gameplay
-- 1: Use the entire map all at once
-- 2: Use North/South County (Los Santos & Blaine Co)
-- 3: Los Santos, Blaine County, North County
-- 4: LS, Blaine East, Blaine West, North County
local zoneUse = 2

-- How many minutes each zone should be active before chaning
local minutesPerZone = 180 -- Any number between 30 and 720 (30 minutes and 12 hours)














function Config.GetNumberOfZones()
  if      zoneUse < 1 then zoneUse = 1
  elseif  zoneUse > 4 then zoneUse = 4
  end
  return zoneUse
end


function Config.MinutesPerZone()
  if      minutesPerZone < 30   then minutesPerZone = 30
  elseif  minutesPerZone > 720  then minutesPerZone = 720
  end
  return minutesPerZone
end