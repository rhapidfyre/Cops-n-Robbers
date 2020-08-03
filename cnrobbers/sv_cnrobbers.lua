
local unique = {}     -- List of Database Unique IDs (SQL) by Server ID

local zone = {
  timer  = 300,       -- Time in minutes between zone changes
  count  = 4,         -- Number of zones to use
  active = 1,         -- The currently active zone
  pick   = 18000000,  -- The next time to pick a zone (in ms)
}

--[[ --------------------------------------------------------------------------
  ~ BEGIN POSITION AQUISITION SCRIPTS
  1) Players, when loaded, will submit their position every 12 seconds
  2) The server, every 30 seconds, loops through the positions table
  3) For each entry found, it will update their last known position in SQL
  4) When the update succeeds, it will remove the position entry
  5) When a player drops, it will send and immediate update.
]]-----------------------------------------------------------------------------
local positions = {}

RegisterServerEvent('cnr:save_pos')
AddEventHandler('cnr:save_pos', function(pos)
  local ply = source
  local uid = unique[ply]
  if uid then
    positions[uid] = pos
  end
end)


function SavePlayerPos(uid,pos)
  if uid then
    if not pos then pos = positions[uid] end
    if pos then
      exports['ghmattimysql']:execute(
        "UPDATE characters SET position = @p WHERE idUnique = @uid",
        {['p'] = pos, ['uid'] = uid},
        function()
          -- Once updated, remove entry
          positions[uid] = nil
        end
      )
    end
  end
end


AddEventHandler('playerDropped', function(reason)
  local ply = source
  local uid = unique[ply]
  local plyInfo = GetPlayerName(ply)
  if uid then
    SavePlayerPos(uid, positions[uid])
  end
  ConsolePrint(
    "^1"..tostring(plyInfo).." disconnected. ^7("..tostring(reason)..")"
  )
  exports['cnr_chat']:DiscordMessage(
    16711680, tostring(plyInfo).." Disconnected", tostring(reason), ""
  )
end)


--[[---------------------------------------------------------------------------
  ~ END OF POSITION ACQUISITION SCRIPTS
--]]


--- ConsolePrint()
-- Nicely formatted console print with timestamp
-- @param msg The message to be displayed
function ConsolePrint(msg)
  if msg then
    local dt = os.date("%H:%M", os.time())
    print("[CNR "..dt.."] ^7"..(msg).."^7")
  end
end
AddEventHandler('cnr:print', ConsolePrint)


--- EXPORT: UniqueId()
-- Assigns / Retrieves player's Unique ID (SQL Database ID Number)
-- @param ply The player (server ID) to get the UID for
-- @param uid If provided, sets player's UID. If nil, returns UID
-- @return Returns the Unique ID, or 0 if not found
function UniqueId(client, uid)
  local ply = tonumber(client)
  if ply then

    -- If UID is given, assign it.
    if uid then
      unique[ply] = tonumber(uid)
      print("[CNROBBERS] ^2Unique ID Set ^7("..uid..") for Player #"..ply)
    else
      if not unique[ply] then
        print("^3[CNROBBERS] ^7- ^1ERROR; ^7Resource "..GetInvokingResource()..
          "' requested Player #"..ply.."'s Unique ID, but it was not found (nil)."
        )
      end
    end

  else

    print("DEBUG - ERROR; No 'ply' given to 'UniqueId()' (sv_cnrobbers.lua)")
    return 0 -- No 'ply' given, return 0

  end
  return (unique[ply])
end


--- EXPORT: CurrentZone()
-- Returns the current zone value
-- @return The current zone (always int)
function CurrentZone()
  return (zone.active)
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

    -- If unique ID doesn't exist, find it
    -- We know they have one because of deferral check upon joining.
    local sid = nil
    for _,id in pairs(GetPlayerIdentifiers(ply)) do
      if string.sub(id, 1, string.len("steam:")) == "steam:" then sid = id
      end
    end

    -- If Steam ID was found, retrieve player's UID.
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


--- ZoneChange()
-- Handles changing over the zone. No params, no return.
function ZoneChange()
  local newZone = math.random(zone.count)
  while newZone == zone.active do
    newZone = math.random(zone.count); Wait(1)
  end

  local n = 300 -- 5 Minutes, in seconds
  ConsolePrint("^3Zone "..(newZone).." will unlock in 5 minutes.")

  while n > 30 do
    if n % 60 == 0 then
      local mins = (n/60).." minutes"
      if     n/60 == 1 then mins = "1 minute"
      elseif n/60  < 1 then mins = n.." seconds"
      end
      TriggerClientEvent('chat:addMessage', (-1), {args = {"ZONE CHANGE",
        "^3"..mins.."^1 until zone change!"}
      })
      ZoneNotification("CHAR_SOCIAL_CLUB",
        "Zone Change", "~r~"..mins,
        "Active zone is changing soon!"
      )
    end
    n = n - 1
    Wait(1000)
  end

  Citizen.Wait(20000)

  for i = 0, 9 do
    TriggerClientEvent('chat:addMessage', (-1),
      {args = {"^1Zone ^3#"..newZone.." ^1activates in ^3"..(10-i).." Second(s)^1!!"}}
    )
    Citizen.Wait(1000)
  end

  zone.active = newZone
  ConsolePrint("^2Zone "..(newZone).." is now active.")

  TriggerClientEvent('chat:addMessage', (-1),
    {args = {"^2Zone ^7#"..(newZone).." ^2is now the active Zone! (^7/zones^2)"}}
  )

  ZoneNotification("CHAR_SOCIAL_CLUB",
    "Zone Change", "~g~New Zone Active",
    "Zone #"..newZone.." is active."
  )

  -- Tell clients and server the zone has changed
  -- This gives the option to use exports['cnrobbers']:CurrentZone(), or to wait for event
  -- DO NOT MAKE THIS EVENT SAFE FOR NETWORKING
  TriggerClientEvent('cnr:zone_change', (-1), newZone)
  TriggerEvent('cnr:zone_change', newZone)
end


-- Runs the zone change timer for choosing which zone is being played
function ZoneLoop()
  while true do
    if GetGameTimer() > zone.pick then

      zone.pick = GetGameTimer() + (zone.timer * 60 * 1000)

      --[[
        Threaded to ensure the (zone.timer) is consistent, and doesn't add
        5 minutes of tick every time the script decides to change the zone.
      ]]
      Citizen.CreateThread(ZoneChange)
    end
    Citizen.Wait(1000)
  end
end
Citizen.CreateThread(ZoneLoop)


-- When a client has loaded in the game, send them relevant script details
RegisterServerEvent('cnr:client_loaded')
AddEventHandler('cnr:client_loaded', function()
  TriggerClientEvent('cnr:active_zone', source, zone.active)
end)

SetGameType('5M Cops and Robbers')



