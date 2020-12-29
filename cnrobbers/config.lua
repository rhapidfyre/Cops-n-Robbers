
Config = {}

-- How many zones to use for gameplay
-- 1: Use the entire map all at once
-- 2: Use North/South County (Los Santos & Blaine Co)
-- 3: Los Santos, Blaine County, North County
-- 4: LS, Blaine East, Blaine West, North County
local zoneUse = 2

-- Default zone: If specified, the script will always start in this zone
local defaultZone = nil     -- Leave nil for random zone

-- How many minutes each zone should be active before chaning
local minutesPerZone = 180  -- Zero: Never change zones

-- How many wanted points someone loses when not being chased by the police
-- Set to zero to disable passive wanted level reduction
local reducePoints = 1.25   -- Zero through infinity

-- How many seconds until Wanted Points should be reduced by the above value
-- Set reducePoints to zero if you never want their wanted level to reduce automatically
local reduceTimer  = 30     -- Minimum of 30 seconds, no maximum











function Config.GetNumberOfZones()
  if      zoneUse < 1 then zoneUse = 1
  elseif  zoneUse > 4 then zoneUse = 4
  end
  return zoneUse
end


function Config.MinutesPerZone()
  if not minutesPerZone         then minutesPerZone =  60 end
  if      minutesPerZone < 30   then minutesPerZone =  30
  elseif  minutesPerZone > 720  then minutesPerZone = 720
  end
  return minutesPerZone
end


function Config.ReductionPoints()
  if not reducePoints   then reducePoints = 1.25 end
  if reducePoints < 0   then reducePoints =    0 end
  return reducePoints
end


function Config.ReductionTimer()
  if not reduceTimer    then reduceTimer = 30 end
  if reduceTimer < 30   then reduceTimer = 30 end
  return reduceTimer*60
end