
-- What commands exist and their approved permission level
local cmds = {
  ['kick']       = 2, ['ban']          = 3, ['tempban']    = 2,
  ['warn']       = 2, ['freeze']       = 2, ['unfreeze']   = 2,
  ['tphere']     = 3, ['tpto']         = 2, ['tpsend']     = 3,
  ['tpmark']     = 3, ['announce']     = 3, ['mole']       = 2,
  ['asay']       = 2, ['csay']         = 4, ['plyinfo']    = 3,
  ['vehinfo']    = 2, ['svinfo']       = 2, ['spawncar']   = 2,
  ['spawnped']   = 2, ['setcash']      = 2, ['setbank']    = 2,
  ['setweather'] = 3, ['settime']      = 3, ['giveweapon'] = 3,
  ['takeweapon'] = 3, ['stripweapons'] = 3, ['togglelock'] = 3,
  ['inmates']    = 2
}

-- 0: Banned, 1: Player, 2: Moderator, 3: Admin, 4: Superadmin
function CommandLevel(cmd)
  if not cmd then return 4 end
  if not cmds[cmd] then return 4 end
  return cmds[cmd]
end