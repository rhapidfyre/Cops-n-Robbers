
--[[
  Cops and Robbers: Character Creation (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  05/11/2019
  
  This file handles all serversided interaction to verifying character
  information, and saving/recalling MySQL Information from the server.
  
  No one may edit, redistribute, or otherwise use this script.
--]]

-- A table consisting of player's database unique id numbers
local unique    = {}
local steams    = {}

-- DEBUG - Whitelist
local whitelist = {
  ["steam:110000100c58e26"] = true, -- RhapidFyre (main)
  ["steam:1100001353615fc"] = true, -- RhapidFyre (laptop)
  ["steam:110000100ea2fbe"] = true, -- Justin Chapman
  ["steam:110000101e66d0e"] = true, -- Mark (Briglair)
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

function LogTime()
  return (os.date("%H:%M:%S", os.time()))
end

RegisterServerEvent('cnr:save_pos')
AddEventHandler('cnr:save_pos', function(pos)
  local ply = source
  local uid = unique[ply]
  if uid then
    positions[uid] = pos
  end
end)


function SavePlayerPos(uid)
  if uid then
    if positions[uid] then 
      exports['ghmattimysql']:execute(
        "UPDATE characters SET position = @p WHERE idUnique = @uid",
        {['p'] = positions[uid], ['uid'] = uid},
        function()
          positions[uid] = nil
        end
      )
    end
  end
end

function SaveAllPositions()
  for k,v in pairs (positions) do
    SavePlayerPos(k)
    Citizen.Wait(100)
  end
end

AddEventHandler('playerDropped', function(rsn)
  local ply = source
  local uid = unique[ply]
  if uid then 
    if positions[uid] then 
      SavePlayerPos(uid)
    end
  end
end)

Citizen.CreateThread(function()
  while true do
    SaveAllPositions()
    Citizen.Wait(30000)
  end
end)
--[[---------------------------------------------------------------------------
  ~ END OF POSITION ACQUISITION SCRIPTS
--]]---------------------------------------------------------------------------


-- DEBUG - Whitelist
local function OnPlayerConnecting(name, setKickReason, deferrals)
  local identifiers, steamIdentifier = GetPlayerIdentifiers(source)
  deferrals.defer()
  deferrals.update(string.format("Checking Whitelist for user %s", name))
  for _,v in pairs(identifiers) do
    if string.find(v, "steam") then 
      steamIdentifier = v
      break
    end
  end
  if whitelist[steamIdentifier] then 
    deferrals.done()
  else
    deferrals.done(
      "Server is being Developed and you are not whitelisted. "..
      "Please check back soon!"
    )
    print("Player was disconnected; "..name.." ["..steamIdentifier.."] is not whitelisted.")
  end
end
AddEventHandler("playerConnecting", OnPlayerConnecting)


--- EXPORT: GetUniqueId()
-- Returns the player's Unique ID
-- @return The player's UID or nil
function GetUniqueId(ply)
  return unique[ply]
end


function GetPlayerSteamId(ply)
  if steams[ply] then return steams[ply] end
  local sid = nil
  for _,id in pairs(GetPlayerIdentifiers(ply)) do 
    if string.sub(id, 1, string.len("steam:")) == "steam:" then
      sid = id
    end
  end
  steams[ply] = sid
  return sid
end

function ReadChangelog(ply)
  local changeLog = io.open("changelog.txt", "r")
  local logLines  = {}
  if changeLog then 
    for line in io.lines("changelog.txt") do 
      if line ~= "" and line then
        logLines[#logLines + 1] = line
      end
    end
  end 
  TriggerClientEvent('cnr:changelog', ply, logLines)
  changeLog:close()
end


--- EVENT 'cnr:create_player'
-- Received by a client when they're spawned and ready to load in
RegisterServerEvent('cnr:create_player')
AddEventHandler('cnr:create_player', function()

  local ply     = source
  local stm     = GetPlayerSteamId(ply)
  local ustring = GetPlayerName(ply).." ("..ply..")"
  print("[CNR "..LogTime().."] ^2"..ustring.." connected^7.")
  
  ReadChangelog(ply)
  
  if stm then
  
    -- SQL: Retrieve character information
    exports['ghmattimysql']:scalar(
      "SELECT idUnique FROM players WHERE idSteam = @steam LIMIT 1",
      {['steam'] = stm},
      function(uid)
        if uid then 
          unique[ply] = uid
          print("[CNR "..LogTime().."] Unique ID ["..uid.."] found for "..ustring)
          TriggerEvent('cnr:unique_id', ply, uid)
        end
        Citizen.Wait(200) 
        print("[CNR "..LogTime().."] "..ustring.." is ready.")
        TriggerClientEvent('cnr:create_ready', ply)
      end
    )
    
  else
    local t = LogTime()
    print("[CNR "..t.."] ^7No Steam ID Found for ^7"..ustring)
    print("[CNR "..t.."] ^1"..ustring.." disconnected. (No Steam Logon)^7")
    DropPlayer(ply,
      "Please log into steam, or make a FREE steam account at "..
      "www.steampowered.com so we can save your progress."
    )
  end
end)


--- EVENT 'cnr:create_session'
-- Received by a client when they're spawned and ready to load in
RegisterServerEvent('cnr:create_session')
AddEventHandler('cnr:create_session', function()
  
  local ply   = source
  local pName = GetPlayerName(ply).. "("..ply..")"
  local dt    = os.date("%H:%M:%S", os.time())
  
  -- If no idUnique, then they have never played here before
  if not unique[ply] then 
    
    -- SQL: Insert new user account for new player
    exports['ghmattimysql']:execute(
      "INSERT INTO players (idSteam, ip, username, created, lastjoin) "..
      "VALUES (@steamid, @ip, @user, NOW(), NOW())",
      {
        ['steamid'] = GetPlayerSteamId(ply), 
        ['ip']      = GetPlayerEndpoint(ply),
        ['user']    = GetPlayerName(ply)
      },
      function()
        -- SQL: Get idUnique of new player
        exports['ghmattimysql']:scalar(
          "SELECT idUnique FROM players WHERE idSteam = @steamid",
          {['steamid'] = GetPlayerSteamId(ply)},
          function(uid)
            unique[ply] = uid
            TriggerEvent('cnr:unique_id', ply, uid)
            local nt = os.date("%H:%M:%S", os.time())
            print(
              "[CNR "..nt.."] Unique ID "..uid.." for  "..pName.." created."
            )
          end
        )
      end
    )
    
    print("[CNR "..dt.."] Sending "..pName.." to Character Designer.")
    TriggerClientEvent('cnr:create_character', ply)
  
  -- Otherwise, they've played before
  else
  
    -- Retrieve all their character information
    exports['ghmattimysql']:execute(
      "SELECT * FROM characters WHERE idUnique = @uid",
      {['uid'] = unique[ply]},
      function(plyr) 
        
        -- If character exists, load it.
        if plyr[1] then
          print("[CNR "..dt.."] Stats exist. Reloading "..
            GetPlayerName(ply).."'s ("..ply..") information."
          )
          TriggerClientEvent('cnr:create_reload', ply, plyr[1])
        
        -- Otherwise, create it
        else
          print("[CNR "..dt.."] No existing stats retrieved. "..
            GetPlayerName(ply).." ("..ply..") is going to Character Creator."
          )
          TriggerClientEvent('cnr:create_character', ply)
        end
      end
    )
  
  end
  
end)


--- EVENT 'cnr:create_save_character'
-- Received by a client when they're spawned and ready to load in
RegisterServerEvent('cnr:create_save_character')
AddEventHandler('cnr:create_save_character',
  function(parents, eyes, hair, perm, temp, feats, model, outfit)
  
    local ply = source
    local uid = unique[ply]
    
    -- SQL: Insert new player character
    exports['ghmattimysql']:execute(
      "INSERT INTO characters "..
      "(idUnique, model, blenddata, hairstyle, bodystyle, overlay, clothes, preset1, preset2, preset3) "..
      "VALUES (@uid, @mdl, @blend, @hair, @body, @tmp, @wear, @wear, @wear, @wear)",
      {
        ['uid']   = uid,     ['mdl']  = model,
        ['blend'] = parents, ['hair'] = hair,   ['body'] = perm,
        ['tmp']   = temp,    ['wear'] = outfit
      },
      function()
        TriggerClientEvent('chat:addMessage', (-1), {
          color     = {245,220,60},
          multiline = false,
          args      = {
            "Please welcome our newest player",
            GetPlayerName(ply)
          }
        })
        TriggerClientEvent('cnr:create_finished', ply)
      end
    )
  end
)

