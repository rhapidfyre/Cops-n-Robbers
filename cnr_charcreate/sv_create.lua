

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


function GetPlayerInformation(ply)
  local plyInfo = GetPlayerIdentifiers(ply)
  local infoTable = {
    ['stm'] = "", ['soc'] = "", ['five'] = "", ['discd'] = "",
    ['ip'] = GetPlayerEndpoint(ply)
  }
  for _,id in pairs (plyInfo) do
    if string.sub(id, 1, string.len("steam:")) == "steam:" then
      infoTable['stm'] = id
    elseif string.sub(id, 1, string.len("license:")) == "license:" then
      infoTable['soc'] = id
    elseif string.sub(id, 1, string.len("five:")) == "five:" then
      infoTable['five'] = id
    elseif string.sub(id, 1, string.len("discord:")) == "steam:" then
      infoTable['discd'] = id
    end
  end

  infoTable['user'] = string.gsub(GetPlayerName(ply), "[%W]", "")
  return infoTable
end


--- CreateUniqueId()
-- Creates a new entry to the 'players' table of the SQL Database, and then
-- assigns the Unique ID to the 'unique' table variable.
-- @param ply The Player's Server ID. If not given, function ends
function CreateUniqueId(ply)

  if not ply then return 0 end

  -- Filter username for special characters

  -- SQL: Insert new user account for new player
  -- If steamid and fiveid are nil, the procedure will return 0
  local ids = GetPlayerInformation(ply)
  local uid = exports['ghmattimysql']:scalarSync(
    "SELECT new_player (@stm, @soc, @five, @disc, @ip, @user)",
    {
      ['stm'] = ids['stm'], ['soc'] = ids['soc'], ['five'] = ids['five'],
      ['disc'] = ids['discd'], ['ip'] = ids['ip'], ['user'] = ids['user']
    }
  )
  if uid > 0 then
    unique[ply] = uid
    exports['cnrobbers']:UniqueId(ply, tonumber(uid)) -- Set UID for session
    cprint("Unique ID ("..(uid)..") created for  "..GetPlayerName(ply))
  else
    cprint("^1A Fatal Error has occurred, and the player has been dropped.")
    print("5M:CNR was unable to ascertain a Unique ID for "..GetPlayerName(ply))
    print("The player is not using any methods of identification.")
    DropPlayer(ply, "Fatal Error; Steam, Social Club, FiveM, or Discord License required on this server for stats tracking.")
  end
  return unique[ply]
end


--- EVENT 'cnr:create_player'
-- Received by a client when they're spawned and ready to click play
AddEventHandler('cnr:create_player', function()

  local ply     = source
  local ids     = GetPlayerInformation(ply)
  local ustring = GetPlayerName(ply).." ("..ply..")"
  local name    = GetPlayerName(ply)

  if doJoin then
    cprint("^2"..ustring.." connected.^7")
  end

  if ids then
    if dMsg then
      cprint("Steam ID or FiveM License exists. Retrieving Unique ID.")
    end

    -- SQL: Retrieve character information
    local uid = exports['ghmattimysql']:scalarSync(
      "SELECT idUnique FROM players "..
      "WHERE idSteam = @steam OR idFiveM = @five OR idSocialClub = @soc "..
      "OR idDiscord = @disc LIMIT 1",
      {['steam'] = ids['stm'], ['five'] = ids['five'], ['soc'] = ids['soc'], ['disc'] = ids['discd']}
    )
    
    if uid then
        
      local banInfo = exports['ghmattimysql']:executeSync(
        "SELECT perms,bantime,reason FROM players WHERE idUnique = @uid",
        {['uid'] = uid}
      )
      print(json.encode(banInfo))
      
      if banInfo[1]["bantime"] then
      
        local nowDate = os.time()
        local banRelease = banInfo[1]["bantime"]/1000
        if nowDate >= banRelease then
          exports['ghmattimysql']:executeSync(
            "UPDATE players SET perms = 1, bantime = NULL, reason = NULL "..
            "WHERE idUnique = @uid", {['uid'] = uid}
          )
          banInfo[1]["perms"] = 1
          print("[CNR ADMIN] "..ustring.."'s ban time is up. They've been unbanned.")
        
        end
      end
      
      -- Player is Banned
      if banInfo[1]["perms"] < 1 then
        cprint(ustring.." Disconnected. Banned: "..banInfo[1]["reason"])
        DropPlayer(ply, "Banned") --[[
        exports['cnr_chat']:DiscordMessage(
          16711680, "Disconnect", name.." failed to join the game.",
          "User was banned from this server"
        )]]
    
      -- Player is not banned
      else
        print("DEBUG - UID Exists.")
        unique[ply] = uid
        cprint("Found Unique ID "..uid.." for "..ustring)
        exports['cnrobbers']:UniqueId(ply, uid)
        
        Citizen.Wait(200)
        cprint(ustring.." is loaded in, and ready to play!")
        TriggerClientEvent('cnr:create_ready', ply)
        CreateSession(ply)
        
      end
    
      
    else
      print("DEBUG - UID Nonexistant")
      uid = CreateUniqueId(ply)
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
function CreateSession(ply)

  -- Retrieve all their character information
  local plyr = exports['ghmattimysql']:executeSync(
    "SELECT * FROM characters WHERE idUnique = @uid",
    {['uid'] = unique[ply]}
  )

  -- If character exists, load it.
  if plyr[1] then
    local pName = GetPlayerName(ply).."'s"
    cprint("Reloading "..pName.." last known character information.")
    exports['cnr_chat']:DiscordMessage(
      65280, GetPlayerName(ply).." has joined the game!", "", ""
    )
    TriggerClientEvent('cnr:create_reload', ply, plyr[1])

  -- Otherwise, create it.
  else
    Citizen.Wait(1000)
    cprint("Sending "..GetPlayerName(ply).." to Character Creator.")
    Citizen.CreateThread(function()
      --exports['cnr_chat']:DiscordMessage(
      --  7864575, "New Player",
      --  "**Please welcome our newest player, "..GetPlayerName(ply).."!**", ""
      --)
    end)
    TriggerClientEvent('cnr:create_character', ply)
  end

end


--- EVENT 'cnr:create_save_character'
-- Received by a client when they're spawned and ready to load in
RegisterServerEvent('cnr:create_save_character')
AddEventHandler('cnr:create_save_character', function(pModel)
  local ply = source
  local uid = unique[ply]
  print("DEBUG - INSERT INTO characters ("..tostring(uid)..", "..tostring(pModel)..").....")
  exports['ghmattimysql']:execute(
    "INSERT INTO characters (idUnique, model) VALUES (@uid, @mdl)",
    {['uid'] = uid, ['mdl'] = pModel},
    function()
      TriggerClientEvent('cnr:create_finished', ply)
    end
  )
end)


