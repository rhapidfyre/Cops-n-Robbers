
--[[
  Cops and Robbers Server Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/19/2019
  
  This file contains all information that will be stored, used, and
  manipulated by any CNR scripts in the gamemode. For example, a
  player's level will be stored in this file and then retrieved using
  an export; Rather than making individual SQL queries each time.
  
  No one may edit, redistribute, or otherwise use this script.
--]]


local unique = {}     -- List of Database Unique IDs (SQL) by Server ID
local scores = {}     -- Scores of players (KEYS: 'cop' and 'civ')
local wanted = {}     -- List of wanted players by Server ID


local zone = {
  timer  = 300,       -- Time in minutes between zone changes
  count  = 4,         -- Number of zones to use
  active = 1,         -- The currently active zone
  pick   = 18000000,  -- The next time to pick a zone
}


local reduce = {    -- Reduction of wanted level
  points   = 0.25,  -- Points each tick
  tickTime = 1      -- Time in seconds between reductions
}


--- EXPORT: UniqueId()
-- Assigns / Retrieves player's Unique ID (SQL Database ID Number)
-- @param ply The player (server ID) to get the UID for
-- @param uid If provided, sets player's UID
-- @return Returns the Unique ID, or 0 if not found
function UniqueId(ply, uid)
  if ply then 
  
    -- If UID is given, assign it.
    if uid then unique[ply] = uid
    
    -- Otherwise, find it.
    else
      local sid = nil
      -- If unique ID doesn't exist, find it
      -- We know they have one because of deferral check upon joining.
      for _,id in pairs(GetPlayerIdentifiers(ply)) do 
        if string.sub(id, 1, string.len("steam:")) == "steam:" then sid = id
        end
      end
      if sid then
        local steam = exports['ghmattimysql']:scalarSync(
          "SELECT idUnique FROM players WHERE idSteam = @steam LIMIT 1",
          {['steam'] = sid}
        )
           unique[ply] = steam
      else unique[ply] = 0
      end
    end
  else
    print("DEBUG - ERROR; 'ply' not given to 'UniqueId()' (sv_cnrobbers.lua)")
    return 0 -- No 'ply' given, return 0
  end
  return (unique[ply])
end)


--- EXPORT: CurrentZone()
-- Returns the current zone value
-- @return The current zone (always int)
function CurrentZone()
  return (zone.active)
end


--- EXPORT: GetFullZoneName()
-- Returns the name found for the zone in shared.lua
-- If one isn't found, returns "San Andreas"
-- @param abbrv The abbreviation of the zone name given by runtime
-- @return A string containing the proper zone name ("LS Airport")
function GetFullZoneName(abbrv)
  if not zoneByName[abbrv] then return "San Andreas" end
  return (zoneByName[abbrv])
end


--- EXPORT: ZoneNotification()
-- Called when the zone is changing / has changed / will be changed
function ZoneNotification(i, t, s, m)
  TriggerClientEvent('cnr:chat_notify', (-1), i, t, s, m)
end


--- EXPORT: GetUniqueId()
-- Returns the player's Unique ID. If not found, attempts to find it (SQL)
-- DEBUG - OBSOLETE; Use 'UniqueId(ply, uid)' instead
-- @return The player's UID, or 0 if not found (always int)
function GetUniqueId(ply)
  if not unique[ply] then 
    local sid = nil
    -- If unique ID doesn't exist, find it
    -- We know they have one because of deferral check upon joining.
    for _,id in pairs(GetPlayerIdentifiers(ply)) do 
      if string.sub(id, 1, string.len("steam:")) == "steam:" then sid = id
      end
    end
    if sid then
      local steam = exports['ghmattimysql']:scalarSync(
        "SELECT idUnique FROM players WHERE idSteam = @steam LIMIT 1",
        {['steam'] = sid}
      )
         unique[ply] = steam
    else unique[ply] = 0
    end
  end
  return unique[ply]
end