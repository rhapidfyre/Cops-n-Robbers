
local zone = {
  newPick = 0,          -- Time until the next zone is chosen
  count   = 4,          -- Number of zones 'n' to use (n < 5)
  active  = 1,          -- Which zone is currently active
  pick    = 18000000,   -- The next time to pick a zone (ms)
}

CNR.SQL = {
  
  RESULT = function(query, tbl)
    if not query then return error("No Querystring given to CNR.SQL") end
    local p = promise.new()
    if not tbl then tbl = {} end
    exports['ghmattimysql']:execute(query, tbl,
      function(result) p:resolve(result) end
    )
    return Citizen.Await(p)
  end,
  
  SCALAR = function(query, tbl)
    if not query then return error("No Querystring given to CNR.SQL") end
    local p = promise.new()
    if not tbl then tbl = {} end
    exports['ghmattimysql']:scalar(query, tbl,
      function(result) p:resolve(result) end
    )
    return Citizen.Await(p)
  end,
  
  RSYNC = function(query, tbl)
    if not query then return error("No Querystring given to CNR.SQL") end
    if not tbl then tbl = {} end
    return exports['ghmattimysql']:executeSync(query, tbl)
  end,
  
  RSCALAR = function(query, tbl)
    if not query then return error("No Querystring given to CNR.SQL") end
    if not tbl then tbl = {} end
    return exports['ghmattimysql']:scalarSync(query, tbl)
  end
  
}


AddEventHandler('cnr:metatable', function(cb)
  cb(CNR)
end)


function GetMetaTable()
  return CNR
end


--[[ Other scripts will call this to receive the metatable
Citizen.CreateThread(function()
  while not CNR do
    CNR = exports['cnr_gamemode']:GetMetaTable()
    Citizen.Wait(1)
  end
end)
]]


Citizen.CreateThread(function()
  Citizen.Wait(1000)
  CNR.zone_list = CNR.SQL.RSCALAR("SELECT * FROM zones")
  TriggerClientEvent('cnr_base:zonelist', CNR.zone_list)
end)




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
        function() positions[uid] = nil end
      )
    end
  end
end


AddEventHandler('playerDropped', function(reason)
  local ply = source
  local uid = unique[ply]
  local plyInfo = GetPlayerName(ply)
  if uid then SavePlayerPos(uid, positions[uid]) end
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