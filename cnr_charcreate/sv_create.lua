
--[[
  Cops and Robbers: Character Creation (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  05/11/2019
  
  This file handles all serversided interaction to verifying character
  information, and saving/recalling MySQL Information from the server.
  
  No one may edit, redistribute, or otherwise use this script.
--]]


--- EVENT 'cnr:create_player'
-- Received by a client when they're spawned and ready to load in
RegisterServerEvent('cnr:create_player')
AddEventHandler('cnr:create_player', function()

  local ply = source
  local stm = GetPlayerIdentifiers(ply)[1]
  
  local sql = exports['GHMattiMySQL']:executeSync(
    "SELECT * FROM players WHERE idSteam = @steam",
    {['steam'] = stm}
  )

  for k,v in pairs (sql) do 
    print(k)
    print(v)
  end
  
end)