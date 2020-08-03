

RegisterServerEvent('cnr:create_player')  -- Client has connected
RegisterServerEvent('cnr:create_session') -- Client is ready to join

-- Whether the server should display connection/join messages --
--local doTalk = true
local doJoin = true
local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local dMsg   = true -- Display debug messages
----------------------------------------------------------------

--local steams    = {} -- Collection of Steam IDs by Server ID.
--local fivem     = {} -- Collection of FiveM License #s by Server ID.
local max_lines = 20 -- Maximum number of entries to save from the changelog.txt
local unique    = {} -- Unique IDs by player server ID


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
    ['stm'] = "", ['soc'] = "", ['five'] = "", ['disc'] = "",
    ['ip'] = GetPlayerEndpoint(ply),
    ['user'] = string.gsub(GetPlayerName(ply), "[%W]", "")
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

  return infoTable
end


--- CreateUniqueId()
-- Creates a new entry to the 'players' table of the SQL Database, and then
-- assigns the Unique ID to the 'unique' table variable.
-- @param ply The Player's Server ID. If not given, function ends
function CreateUniqueId(ply)

  if not ply then
    print("^1[CNR CHARCREATE] ^7- No player ID given to CreateUniqueId()")
    return 0
  end

  -- SQL: Insert new user account for new player
  -- If steamid and fiveid are nil, the procedure will return 0
  local ids = GetPlayerInformation(ply)
  local uid = exports['ghmattimysql']:scalarSync(
    "SELECT new_player (@stm, @soc, @five, @disc, @ip, @user)", ids
  )
  if uid then
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
  --local ids     = GetPlayerInformation(ply)
  local ustring = GetPlayerName(ply).." ("..ply..")"

  if doJoin then cprint("^2"..ustring.." connected.^7") end


  -- SQL: Retrieve character information
  local uid = CreateUniqueId(ply)

  if uid then

    local banInfo = exports['ghmattimysql']:executeSync(
      "SELECT perms,bantime,reason FROM players WHERE idUnique = @uid",
      {['uid'] = uid}
    )

    if banInfo[1]["bantime"] > 0 then

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
      DropPlayer(ply, "You have been banned from playing on this server.")
      exports['cnr_chat']:DiscordMessage(
        16711680, "Disconnect", name.." failed to join the game.",
        "User was previously banned from this server"
      )

    -- Player is not banned
    else
      unique[ply] = uid
      cprint("Found Unique ID "..uid.." for "..ustring)
      exports['cnrobbers']:UniqueId(ply, uid)

      Citizen.Wait(200)
      cprint(ustring.." is loaded in, and ready to play!")
      TriggerClientEvent('cnr:create_ready', ply)
      CreateSession(ply)

    end

  else
    DropPlayer(ply,
      "You must use a Steam, Social Club, FiveM, or Discord license key "..
      "to play on this server, so that we can track your stats!"
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
      exports['cnr_chat']:DiscordMessage(
        7864575, "New Player",
        "**Please welcome our newest player, "..GetPlayerName(ply).."!**", ""
      )
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
      TriggerClientEvent('chat:addMessage', (-1), {templateId = 'sysMsg', args = {
        "Welcome, ^3"..GetPlayerName(ply).."^7! Hey everyone! We got a new kid!"
      }})
      TriggerClientEvent('chat:addMessage', ply, {templateId = 'sysMsg', args = {
        "Check out ^3/help ^7for info about the game!"
      }})
    end
  )
end)







--[[ ----------------------------------------------------------
          TEMPORARY WHITELIST STUFF
--]] ----------------------------------------------------------

local function FileExists()
  local f = io.open("resources/[cnr]/cnr_charcreate/whitelist.txt", "rb")
  if f then f:close() end
  return f ~= nil
end

local function GetWhitelist()
  if not FileExists() then return {} end
  local whitelistFile = "resources/[cnr]/cnr_charcreate/whitelist.txt"
  local lines = {}
  for line in io.lines(whitelistFile) do
    lines[#lines + 1] = string.gsub(line, "\r", "")
  end
  return lines
end

--[[
	When a player joins, check if they're in the whitelistArray.
	If they are, allow them to join. Otherwise don't let them.
]]
AddEventHandler("playerConnecting", function(playerName, setKickReason, deferrals)

    -- Tell the connection to defer until we have done our whitelist check
	deferrals.defer()

  local ids = GetPlayerIdentifiers(source)
	local authorizedList = GetWhitelist()

	-- Tell the user we're checking stuff (not shown for long)
  deferrals.update("Checking early access whitelist...")
	Wait(200)

  for myIdx,identifier in pairs(ids) do

	-- Loop through the whitelist array
    for _,i in ipairs(authorizedList) do

	    -- Check if the player exists in the array.
      if (string.lower(i) == string.lower(identifier)) then
        print("[CNR WHITELIST] ^2Authorized ^7"..playerName.." to join. ("..identifier..").")
        deferrals.done() -- They're in it... Let them in!
        return
      end
    end
  end

	print("[CNR WHITELIST] ^1Failed^7 to authorize "..playerName..". Connection rejected.")
	deferrals.done("Whitelist Violation - Get Whitelisted @ http://discord.gg/jaxxkKp !")
end)