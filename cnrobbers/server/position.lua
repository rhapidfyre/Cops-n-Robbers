
RegisterServerEvent('cnr:save_pos')
--[[ --------------------------------------------------------------------------
  1) Players, when loaded, will submit their position every 12 seconds
  2) When a player disconnects*, their position is then saved to MySQL
  
  * All players should be kicked before shutting down the server for this reason
]]-----------------------------------------------------------------------------

local positions = {}


local function SavePlayerPos(uid,pos)
  if uid then
    if not pos then pos = positions[uid] end
    if pos then
      exports['ghmattimysql']:execute(
        "UPDATE characters SET x = @x, y = @y, z = @z WHERE idUnique = @uid",
        {
          ['uid'] = uid,
          ['x']   = positions[uid].x,
          ['y']   = positions[uid].y,
          ['z']   = positions[uid].z,
        },
        function()
          -- Once updated, remove entry
          positions[uid] = nil
        end
      )
    end
  end
end


AddEventHandler('cnr:save_pos', function()
  local ply     = source
  local plyPos  = GetEntityCoords(GetPlayerPed(ply))
  local uid     = UniqueId(ply)
  if uid then
    if not positions[uid] then positions[uid] = pos end
    if positions[uid] ~= plyPos then
      positions[uid] = plyPos
    end
  end
end)


AddEventHandler('playerDropped', function(reason)
  local ply = source
  local uid = UniqueId(ply)
  local plyInfo = GetPlayerName(ply)
  if uid then SavePlayerPos(uid, positions[uid]) end
  ConsolePrint("^1"..tostring(plyInfo).." disconnected. ^7("..tostring(reason)..")")
  DiscordFeed(16711680, tostring(plyInfo).." Disconnected", tostring(reason), "")
end)


