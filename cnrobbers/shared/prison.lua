
function Imprisoned(client)
  if not client then client = GetPlayerServerId(PlayerId()) end
  return CNR.prisoners[client]
end