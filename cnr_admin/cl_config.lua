
-- What commands exist and their approved permission level
local cmds = {
  ['kick'] = 2,
  ['ban']  = 3,
  ['tempban'] = 2
}

function CommandLevel(cmd)
  if not cmd then return 1 end
  if not cmds[cmd] then return 1 end
  return cmds[cmd]
end