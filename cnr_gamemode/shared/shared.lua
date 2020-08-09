
-- Base Gamemode Metatable
local debugging = true
CNR = {
  active_zone  = 1
  zone_list    = {}
}


--- EXPORT: GetActiveZone()
-- Returns the currently active play zone
-- @return ID of the active zone (number)
function GetActiveZone()
  return CNR.active_zone
end


--- EXPORT: GetFullZoneName()
-- Returns the name for the zone
-- If one isn't found, returns "San Andreas"
-- @param abbrv The abbreviation of the zone name given by runtime
-- @return A string containing the proper zone name ("LS Airport")
function GetFullZoneName(abbrv)
  if not CNR.zones[abbrv] then return "San Andreas" end
  return (zoneByName[abbrv].name)
end


function GetZoneNumber(abbrv)
  if not zoneByName[abbrv] then return 1 end
  return (zoneByName[abbrv].z)
end


function RetrieveAllZones()
  return CNR.zone_list
end