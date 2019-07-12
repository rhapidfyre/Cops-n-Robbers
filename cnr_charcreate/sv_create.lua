
--[[
  Cops and Robbers: Character Creation (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  05/11/2019
  
  This file handles all serversided interaction to verifying character
  information, and saving/recalling MySQL Information from the server.
  
  No one may edit, redistribute, or otherwise use this script.
--]]

-- A table consisting of player's database unique id numbers
local plyInfo = {}
local whitelist = {
  ["steam:110000100c58e26"] = true,
}
-- DEBUG - Whitelist
local function OnPlayerConnecting(name, setKickReason, deferrals)
  local identifiers, steamIdentifier = GetPlayerIdentifiers(source)
  deferrals.defer()
  deferrals.update(string.format("Checking Whitelist for user %s", name))
  for _,v in pairs(identifiers) do
    if string.find(v, "steam") then 
      steamIdentifier = v
      break
    end
  end
  if whitelist[steamIdentifier] then 
    deferrals.done()
  else
    deferrals.done(
      "Server is being Developed and you are not whitelisted. "..
      "Please check back soon!"
    )
  end
end
AddEventHandler("playerConnecting", OnPlayerConnecting)


function GetPlayerSteamId(ply)
  local sid = nil
  for _,id in pairs(GetPlayerIdentifiers(ply)) do 
    if string.sub(id, 1, string.len("steam:")) == "steam:" then
      sid = id
    end
  end
  return sid
end


--- EVENT 'cnr:create_player'
-- Received by a client when they're spawned and ready to load in
RegisterServerEvent('cnr:create_player')
AddEventHandler('cnr:create_player', function()

  print("DEBUG - Creating Player Information.")

  local ply = source
  local stm = GetPlayerSteamId(ply)
  
  if stm then
    print("DEBUG - Steam Session is Valid.")
    exports['ghmattimysql']:execute(
      "SELECT * FROM players WHERE idSteam = @steam LIMIT 1",
      {['steam'] = stm},
      function(results)
        if results[1] then 
          for k,v in pairs (results) do 
            plyInfo[ply] = v["idUnique"]
          end
          print("DEBUG - Saved idUnique for user "..GetPlayerName(ply))
        else 
          print("DEBUG - No idUnique found for user "..GetPlayerName(ply))
        end
        Citizen.Wait(200)
        TriggerClientEvent('cnr:create_ready', ply)
      end
    )
    
  else
    DropPlayer(ply,
      "Please log into steam, or make a FREE steam account at "..
      "www.steampowered.com so we can save your progress."
    )
  end
end)


--- EVENT 'cnr:create_session'
-- Received by a client when they're spawned and ready to load in
RegisterServerEvent('cnr:create_session')
AddEventHandler('cnr:create_session', function()
  
  local ply = source
  local dt  = os.date("%H:%M", os.time())
  
  -- If no idUnique, then they have never played here before
  if not plyInfo[ply] then 
    print("[CNR "..dt.."] No Unique ID found. "..
      GetPlayerName(ply).." ("..ply..") is going to Character Creator."
    )
  
    -- DEBUG - This should be moved to after they've finished the designer
    TriggerClientEvent('chat:addMessage', (-1), {
      color     = {245,220,60},
      multiline = false,
      args      = {
        "Please welcome our newest player",
        GetPlayerName(ply)
      }
    })
    
    TriggerClientEvent('cnr:create_character', ply)
  
  -- Otherwise, they've played before
  else
  
    -- Retrieve all their character information
    exports['ghmattimysql']:execute(
      "SELECT * FROM characters WHERE idUnique = @uid",
      {['uid'] = plyInfo[ply]},
      function(plyr) 
        
        -- If character exists, load it.
        if plyr[1] then
          print("[CNR "..dt.."] Stats exist. Reloading "..
            GetPlayerName(ply).."'s ("..ply..") information."
          )
          TriggerClientEvent('cnr:create_reload', ply, plyr[1])
        
        -- Otherwise, create it
        else
          print("[CNR "..dt.."] No existing stats retrieved. "..
            GetPlayerName(ply).." ("..ply..") is going to Character Creator."
          )
          TriggerClientEvent('cnr:create_character', ply)
        end
      end
    )
  
  end
  
end)

