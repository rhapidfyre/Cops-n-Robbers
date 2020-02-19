
local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end

local points = {
  'busted' = 10,
}

-- Adjust player's score accordingly
AddEventHandler('cnr:imprisoned', function(ply, cop, wLevel)
  
  local uid = exports['cnrobbers']:UniqueId(cop)
  
  local pts = wLevel * points.busted
  
  -- Add pts to player's cop score
  exports['ghmattimysql']:execute(
    "UPDATE players SET cop = cop + @val WHERE idUnique = @cid",
    {['val'] = pts, ['cid'] = uid}
  )
  cprint(
    GetPlayerName(cop).." ("..cop..") was awarded "..pts..
    " for arresting "..GetPlayerName(ply).." ("..ply..")"
  )
  
end)