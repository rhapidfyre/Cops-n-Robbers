
local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end

local points = {
  bust   = 9,  kill   = 6, kcop   = 9, burg = 3,
  steal  = 2,  rob    = 4, fish   = 1, hunt = 1,
  rape   = 5,  craft  = 1, escape = 3
}

-- Adjust player's score accordingly
AddEventHandler('cnr:imprisoned', function(ply, cop, wLevel)
  
  local uid = exports['cnrobbers']:UniqueId(cop)
  local pts = wLevel * points.bust
  
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