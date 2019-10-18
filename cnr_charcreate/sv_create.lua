

RegisterServerEvent('cnr:create_player')  -- Client has connected
RegisterServerEvent('cnr:create_session') -- Client is ready to join

-- Whether the server should display connection/join messages --
local doTalk = true 
local doJoin = true
local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local dMsg   = true -- Display debug messages
----------------------------------------------------------------

local steams    = {} -- Collection of Steam IDs by Server ID.
local fivem     = {} -- Collection of FiveM License #s by Server ID.
local max_lines = 20 -- Maximum number of entries to save from the changelog.txt
local unique    = {} -- Unique IDs by player server ID


--[[ DEBUG - Whitelist
-- In the near future, this needs to use more than just a Steam verification
-- so people can play from multiple sources and not just rely upon Steam.
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
  if steamIdentifier then 
    cprint("^2Success; User is logged into Steam.")
    deferrals.done()
  
  else
    cprint("^1Failure; User is NOT logged into Steam.")
    cprint(name.." Disconnected. Reason: Not using Steam.")
    deferrals.done(
      "The current version of this gamemode requires that you use Steam."
    )
    exports['cnr_chat']:DiscordMessage(
      16711680, "Disconnect",
      name.." is not logged into Steam.",
      "No Steam Logon"
    )
  end
  
end
AddEventHandler("playerConnecting", OnPlayerConnecting)
]]

--- GetPlayerSteamId()
-- Finds the player's Steam ID. We know it exists because of deferrals.
function GetPlayerSteamId(ply)
  if steams[ply] then return steams[ply] end
  local sid = nil
  for _,id in pairs(GetPlayerIdentifiers(ply)) do 
    print("DEBUG - ^3"..tostring(id).."^7")
    if string.sub(id, 1, string.len("steam:")) == "steam:" then sid = id
    end
  end
  steams[ply] = sid
  if doTalk then
    cprint(GetPlayerName(ply).." Steam ID ["..tostring(steams[ply]).."]")
  end
  return sid
end


-- GetPlayerLicense()
-- Finds the player's FiveM License ID
function GetPlayerLicense(ply)
  if fivem[ply] then return fivem[ply] end
  local fid = nil
  for _,id in pairs(GetPlayerIdentifiers(ply)) do 
    if string.sub(id, 1, string.len("license:")) == "license:" then fid = id
    end
  end
  fivem[ply] = fid
  if doTalk then
    cprint(GetPlayerName(ply).." FiveM ID ["..tostring(fivem[ply]).."]")
  end
  return fid
end

--- ReadChangelog()
-- Scans the change log and sends it to the player
function ReadChangelog(ply)
  local changeLog = io.open("changelog.txt", "r")
  local logLines  = {}
  if changeLog then 
    for line in io.lines("changelog.txt") do 
      if line ~= "" and line then
        n = #logLines + 1
        if n < (max_lines + 1) then logLines[n] = line end
      end
    end
  else
    if dMsg then
      cprint("changelog.txt not found. You can safely ignore this warning.")
    end
  end 
  if changelog then
    if dMsg then cprint("Sending changelog to "..GetPlayerName(ply)) end
    changeLog:close()
  end
  TriggerClientEvent('cnr:changelog', ply, logLines)
end


--- CreateUniqueId()
-- Creates a new entry to the 'players' table of the SQL Database, and then 
-- assigns the Unique ID to the 'unique' table variable.
-- @param ply The Player's Server ID. If not given, function ends
function CreateUniqueId(ply)
  
  if not ply then return 0 end
  
  -- Filter username for special characters
  local filtered = GetPlayerName(ply)
  filtered = string.gsub(filtered, "[%W]", "")
  
  -- SQL: Insert new user account for new player
  -- If steamid and fiveid are nil, the procedure will return 0
  local uid = exports['ghmattimysql']:scalarSync(
    "SELECT new_player (@steamid, @fiveid, @ip, @user)",
    {
      ['steamid'] = GetPlayerSteamId(ply), 
      ['fiveid']  = GetPlayerLicense(ply),
      ['ip']      = GetPlayerEndpoint(ply),
      ['user']    = filtered
    }
  )
  if uid > 0 then 
    unique[ply] = uid
    exports['cnrobbers']:UniqueId(ply, tonumber(uid)) -- Set UID for session
    cprint("Unique ID ("..(uid)..") created for  "..GetPlayerName(ply))
  else
    cprint("^1A Fatal Error has occurred, and the player has been dropped.")
    print("5M:CNR was unable to ascertain a Unique ID for "..GetPlayerName(ply))
    print("The player is not logged into Steam, AND has an invalid FiveM ID.")
    DropPlayer(ply, "Fatal Error; Steam Logon or FiveM License required.")
  end
  return unique[ply]
end


--- EVENT 'cnr:create_player'
-- Received by a client when they're spawned and ready to click play
AddEventHandler('cnr:create_player', function()

  local ply     = source
  local sid     = GetPlayerSteamId(ply)
  local fid     = GetPlayerLicense(ply)
  local ustring = GetPlayerName(ply).." ("..ply..")"
  
  if not sid then sid = 0 end
  if not fid then fid = 0 end
  
  if doJoin then
    cprint("^2"..ustring.." connected.^7")
  end
  
  ReadChangelog(ply)
  
  if sid or fid > 0 then
    if dMsg then
      cprint("Steam ID or FiveM License exists. Retrieving Unique ID.")
    end
  
    -- SQL: Retrieve character information
    exports['ghmattimysql']:scalar(
      "SELECT idUnique FROM players "..
      "WHERE idSteam = @steam OR idFiveM = @five LIMIT 1",
      {['steam'] = sid, ['five'] = fid},
      function(uid)
        if uid then 
          print("DEBUG - UID Exists.")
          unique[ply] = uid
          cprint("Found Unique ID "..uid.." for "..ustring)
          exports['cnrobbers']:UniqueId(ply, uid)
        else
          print("DEBUG - UID Nonexistant")
          local uid = CreateUniqueId(ply)
          if uid < 1 then 
            cprint("^1A Fatal Error has Occurred.")
            cprint("No player ID given to CreateUniqueId() in sv_create.lua")
          else
            cprint(
              "Successfully created UID ("..tostring(uid)..
              ") for player "..GetPlayerName(ply)
            )
          end
        end
        Citizen.Wait(200) 
        cprint(ustring.." is loaded in, and ready to play!")
        TriggerClientEvent('cnr:create_ready', ply)
      end
    )
    
  else
    cprint("^1"..ustring.." disconnected. ^7(No ID Validation Obtained)")
    DropPlayer(ply,
      "Your FiveM License was invalid, and you are not using Steam. "..
      "Please relaunch FiveM, or log into Steam to play on this server."
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
        Citizen.CreateThread(function()
          exports['cnr_chat']:DiscordMessage(
            7864575, "New Player",
            "Please welcome our newest player, "..GetPlayerName(ply).."!", ""
          )
        end)
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
    print("DEBUG - INSERT INTO characters ("..tostring(uid)..", "..tostring(pModel)..").....")
    exports['ghmattimysql']:execute(
      "INSERT INTO characters (idUnique, model) VALUES (@uid, @mdl)",
      {['uid'] = uid, ['mdl'] = pModel},
      function()
        TriggerClientEvent('cnr:create_finished', ply)
      end
    )
  end
)


