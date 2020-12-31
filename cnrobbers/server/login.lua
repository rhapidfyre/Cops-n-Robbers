

RegisterServerEvent('cnr:create_save_character')
RegisterServerEvent('cnr:ready')  -- Client has connected
RegisterServerEvent('cnr:create_session') -- Client is ready to join

--local steams    = {} -- Collection of Steam IDs by Server ID.
--local fivem     = {} -- Collection of FiveM License #s by Server ID.
local max_lines = 20 -- Maximum number of entries to save from the changelog.txt


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
    ConsolePrint("changelog.txt not found. You can safely ignore this warning.")
  end
  if changelog then changeLog:close() end
  TriggerClientEvent('cnr:changelog', ply, logLines)
end


function GetPlayerInformation(ply)
  local plyInfo = GetPlayerIdentifiers(ply)
  local infoTable = {
    ['steam'] = "", ['social']  = "",
    ['fivem'] = "", ['discord'] = "",
    ['ip']    = GetPlayerEndpoint(ply),
    -- Removes all non alphanumeric characters
    ['user']  = string.gsub(GetPlayerName(ply), "[%W]", "")
  }
  for _,id in pairs (plyInfo) do
    if string.sub(id, 1, string.len("steam:")) == "steam:" then
      infoTable['steam'] = id
    elseif string.sub(id, 1, string.len("license:")) == "license:" then
      infoTable['social'] = id
    elseif string.sub(id, 1, string.len("five:")) == "five:" then
      infoTable['fivem'] = id
    elseif string.sub(id, 1, string.len("discord:")) == "discord:" then
      infoTable['discord'] = id
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
    ConsolePrint("^1No player ID given to CreateUniqueId()")
    return 0
  end

  -- SQL: Insert new user account for new player
  -- If steamid and fiveid are nil, the procedure will return 0
  local ids = GetPlayerInformation(ply)
  local uid = CNR.SQL.RSYNC(
    "SELECT new_player (@steam, @social, @fivem, @discord, @ip, @user)", ids
  )
  if not uid then uid = 0 end
  if uid > 0 then
    UniqueId(ply, uid)
    ConsolePrint("^2Unique ID ("..(uid)..") assigned for  "..GetPlayerName(ply).." (ID "..ply..")")
  end
  return uid

end


--- EVENT 'cnr:create_session'
-- Received by a client when they're spawned and ready to load in
function CreateSession(ply)

  -- Retrieve all their character information
  local plyr = CNR.SQL.QUERY(
    "SELECT * FROM characters WHERE idUnique = @uid",
    {['uid'] = CNR.unique[ply]}
  )

  -- If character exists, load it.
  if plyr[1] then
    local pName = GetPlayerName(ply).."'s"
    ConsolePrint("Reloading "..pName.." last known character information.")
    DiscordFeed(65280, GetPlayerName(ply).." has joined the game!")
    TriggerClientEvent('cnr:create_reload', ply, plyr[1])

  -- Otherwise, create it.
  else
  
    Citizen.Wait(1000)
    ConsolePrint("Sending "..GetPlayerName(ply).." to Character Creator.")
    TriggerClientEvent('cnr:create_character', ply)

  end

end


--- EVENT 'cnr:ready'
-- Received from a client when they're spawned and ready to play
AddEventHandler('cnr:ready', function()

  local ply     = source
  local ustring = GetPlayerName(ply).." (ID "..ply..")"
  local uid     = CreateUniqueId(ply)

  if uid < 1 then
    DropPlayer(ply,
      "A Steam account, linked FiveM Account, or Social Club license "..
      "is required to play on this server!"
    )
  else CreateSession(ply)
  end

end)


--- EVENT 'cnr:create_save_character'
-- Received by a client when they're spawned and ready to load in
AddEventHandler('cnr:create_save_character', function(pModel)
  local ply = source
  local uid = UniqueId(ply)
  local sp = CNR.spawnpoints[math.random(#CNR.spawnpoints)]
  CNR.SQL.EXECUTE(
    "INSERT INTO characters (idUnique, model, x, y, z) "..
    "VALUES (@uid, @mdl, @x, @y, @z)",
    {['uid'] = uid, ['mdl'] = pModel, ['x'] = sp.x, ['y'] = sp.y, ['z'] = sp.z},
    function()
      SetEntityCoords(GetPlayerPed(ply), sp.x, sp.y, sp.z)
      SetEntityHeading(GetPlayerPed(ply), math.random(359)+0.1)
      DiscordFeed(16580705, "New Player",
        "**Please welcome our newest player, "..GetPlayerName(ply).."!**", ""
      )
      TriggerClientEvent('cnr:create_finished', ply)
      TriggerClientEvent('chat:addMessage', (-1), {templateId = 'sysMsg', args = {
        "^3Please welcome our newest player, ^7"..GetPlayerName(ply).."^3!"
      }})
      TriggerClientEvent('chat:addMessage', ply, {templateId = 'sysMsg', args = {
        "Check out ^3/help ^7for info about the game!"
      }})
    end
  )
end)
