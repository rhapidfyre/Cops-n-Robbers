
function DutyStatus(ply)
  if not ply then return false end
  return CNR.police[ply]
end