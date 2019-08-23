
--[[
  Cops and Robbers: Character Creation - Server Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/20/2019
  
  This file handles all serversided interaction to verifying character
  information, and saving/recalling MySQL Information from the server.
  
--]]

RegisterServerEvent('cnr:create_player')  -- Client has connected
RegisterServerEvent('cnr:create_session') -- Client is ready to join

-- Whether the server should display connection/join messages --
local doTalk = true 
local doJoin = true
local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local dMsg   = true -- Display debug messages
----------------------------------------------------------------

local steams    = {} -- Collection of Steam IDs by Server ID.
local max_lines = 20 -- Maximum number of entries to save from the changelog.txt
local unique    = {} -- Unique IDs by player server ID


-- DEBUG - Whitelist
local whitelist = {
  ["steam:110000100c58e26"] = true, -- RhapidFyre (main)
  ["steam:1100001353615fc"] = true, -- RhapidFyre (laptop)
  ["steam:110000100ea2fbe"] = true, -- Justin Chapman
  ["steam:110000101e66d0e"] = true, -- Mark (Briglair)
}


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
    cprint("^2Access granted ^7for user "..name.."; Steam ID ["..steamIdentifier.."]")
    deferrals.done()
  else
    cprint("^1Access DENIED ^7for user"..name.."; Steam ID ["..steamIdentifier.."]")
    cprint(name.." Disconnected. Reason: Not whitelisted.")
    deferrals.done(
      "Server is being Developed and you are not whitelisted. "..
      "Please check back soon!"
    )
    exports['cnr_chat']:DiscordMessage(
      16711680, "Disconnect",
      name.." failed to validate. Disconnected.",
      "Whitelist Violation"
    )
  end
end
AddEventHandler("playerConnecting", OnPlayerConnecting)


--- GetPlayerSteamId()
-- Finds the player's Steam ID. We know it exists because of deferrals.
function GetPlayerSteamId(ply)
  if steams[ply] then return steams[ply] end
  local sid = nil
  for _,id in pairs(GetPlayerIdentifiers(ply)) do 
    if string.sub(id, 1, string.len("steam:")) == "steam:" then sid = id
    end
  end
  steams[ply] = sid
  if doTalk then
    cprint(GetPlayerName(ply).." Steam ID ["..tostring(steams[ply]).."]")
  end
  return sid
end


--- ReadChangelog()
-- Scans the change log and sends it to the player
function ReadChangelog(ply)
  if dMsg then
    cprint("Preparing to send changelog to "..GetPlayerName(ply))
  end
  local changeLog = io.open("changelog.txt", "r")
  local logLines  = {}
  if changeLog then 
    for line in io.lines("changelog.txt") do 
      if line ~= "" and line then
        n = #logLines + 1
        if n < (max_lines + 1) then logLines[n] = line
        end
      end
    end
  else
  if dMsg then
    cprint("Failed to open changelog.txt")
  end
  end 
  if dMsg then
    cprint("Sending changelog to "..GetPlayerName(ply))
  end
  TriggerClientEvent('cnr:changelog', ply, logLines)
  changeLog:close()
end


function CreateUniqueId(ply, stm)
  -- SQL: Insert new user account for new player
  -- DEBUG - Should really make this a stored procedure
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
          exports['cnrobbers']:UniqueId(ply, uid) -- Set UID for session
          cprint("Created Unique ID "..(uid).." for  "..GetPlayerName(ply))
        end
      )
    end
  )
end


--- EVENT 'cnr:create_player'
-- Received by a client when they're spawned and ready to click play
AddEventHandler('cnr:create_player', function()

  local ply     = source
  local stm     = GetPlayerSteamId(ply)
  local ustring = GetPlayerName(ply).." ("..ply..")"
  
  if doJoin then
    cprint("^2"..ustring.." connected.^7")
  end
  
  ReadChangelog(ply)
  
  if stm then
    if dMsg then
      cprint("Steam ID exists. Retrieving Unique ID.")
    end
  
    -- SQL: Retrieve character information
    exports['ghmattimysql']:scalar(
      "SELECT idUnique FROM players WHERE idSteam = @steam LIMIT 1",
      {['steam'] = stm},
      function(uid)
        if uid then 
          unique[ply] = uid
          cprint("Found Unique ID "..uid.." for "..ustring)
          exports['cnrobbers']:UniqueId(ply, uid)
        else
          CreateUniqueId(ply, stm)
        end
        Citizen.Wait(200) 
        cprint(ustring.." is ready to play.")
        TriggerClientEvent('cnr:create_ready', ply)
      end
    )
    
  else
    cprint("^1No Steam ID Found for "..ustring)
    cprint("^1"..ustring.." disconnected. ^7(No Steam Logon)")
    DropPlayer(ply,
      "Please log into steam, or make a FREE steam account at "..
      "www.steampowered.com so we can save your progress."
    )
  end
end)


--- EVENT 'cnr:create_session'
-- Received by a client when they're spawned and ready to load in
AddEventHandler('cnr:create_session', function()
  
  local ply   = source
  local pName = GetPlayerName(ply).. "("..ply..")"
  
  -- Retrieve all their character information
  exports['ghmattimysql']:execute(
    "SELECT * FROM characters WHERE idUnique = @uid",
    {['uid'] = unique[ply]},
    function(plyr) 
    
      -- If character exists, load it.
      if plyr[1] then
        local pName = GetPlayerName(ply).."'s"
        cprint("Reloading "..pName.." last known character information.")
        exports['cnr_chat']:DiscordMessage(
          65280, GetPlayerName(ply).." Connected", "", ""
        )
        TriggerClientEvent('cnr:create_reload', ply, plyr[1])
        TriggerClientEvent('cnr:wallet_value', ply, plyr[1]["cash"])
        TriggerClientEvent('cnr:bank_account', ply, plyr[1]["bank"])
      
      -- Otherwise, create it.
      else
        cprint("Sending "..GetPlayerName(ply).." to Character Creator.")
        exports['cnr_chat']:DiscordMessage(
          7864575, "New Player",
          "Please welcome our newest player, "..GetPlayerName(name).."!", ""
        )
        TriggerClientEvent('cnr:create_character', ply)
      end
    end
  )
  
end)


--- EVENT 'cnr:create_save_character'
-- Received by a client when they're spawned and ready to load in
RegisterServerEvent('cnr:create_save_character')
AddEventHandler('cnr:create_save_character',
  --[[function(parents, eyes, hair, perm, temp, feats, model, outfit)
  
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
  end]]
  function(pModel)
    local ply = source
    local uid = exports['cnrobbers']:UniqueId(ply)
    exports['ghmattimysql']:execute(
      "INSERT INTO characters (idUnique, model) VALUES (@uid, @mdl)",
      {['uid'] = uid, ['mdl'] = pModel},
      function()
        TriggerClientEvent('cnr:create_finished', ply)
      end
    )
  end
)


