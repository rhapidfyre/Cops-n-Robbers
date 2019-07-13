
--[[
  Cops and Robbers: Character Creation (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  05/11/2019
  
  This file handles all serversided interaction to verifying character
  information, and saving/recalling MySQL Information from the server.
  
  No one may edit, redistribute, or otherwise use this script.
--]]

-- A table consisting of player's database unique id numbers
local unique = {}
local steams = {}
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
  if steams[ply] then return steams[ply] end
  local sid = nil
  for _,id in pairs(GetPlayerIdentifiers(ply)) do 
    if string.sub(id, 1, string.len("steam:")) == "steam:" then
      sid = id
    end
  end
  steams[ply] = sid
  return sid
end


--- EVENT 'cnr:create_player'
-- Received by a client when they're spawned and ready to load in
RegisterServerEvent('cnr:create_player')
AddEventHandler('cnr:create_player', function()

  local ply = source
  local stm = GetPlayerSteamId(ply)
  
  if stm then
    exports['ghmattimysql']:scalar(
      "SELECT * FROM players WHERE idSteam = @steam LIMIT 1",
      {['steam'] = stm},
      function(uid)
        if uid then 
          unique[ply] = uid
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
  
  local ply   = source
  local pName = GetPlayerName(ply).. "("..ply..")"
  local dt    = os.date("%H:%M", os.time())
  
  -- If no idUnique, then they have never played here before
  if not unique[ply] then 
    
    -- SQL: Insert new user account for new player
    exports['ghmattimysql']:execute(
      "INSERT INTO players (idSteam, ip, username, created, lastjoin) "..
      "VALUES (@steamid, @ip, @user, NOW(), NOW())",
      {
        ['steamid'] = GetPlayerSteamId(ply), 
        ['ip']      = GetPlayerEndpoint(ply),
        ['user']    = GetPlayerName(ply)
      },
      function()
        -- SQL: Get idUnique of new player
        exports['ghmattimysql']:scalar(
          "SELECT idUnique FROM players WHERE idSteam = @steamid",
          {['steamid'] = GetPlayerSteamId(ply)},
          function(uid)
            unique[ply] = uid
            local nt = os.date("%H:%M", os.time())
            print(
              "[CNR "..nt.."] Unique ID "..uid.." for  "..pName.." created."
            )
          end
        )
      end
    )
    
    print("[CNR "..dt.."] Sending "..pName.." to Character Designer.")
    TriggerClientEvent('cnr:create_character', ply)
  
  -- Otherwise, they've played before
  else
  
    -- Retrieve all their character information
    exports['ghmattimysql']:execute(
      "SELECT * FROM characters WHERE idUnique = @uid",
      {['uid'] = unique[ply]},
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


--- EVENT 'cnr:create_save_character'
-- Received by a client when they're spawned and ready to load in
RegisterServerEvent('cnr:create_save_character')
AddEventHandler('cnr:create_save_character',
  function(parents, eyes, hair, perm, temp, feats, model, outfit)
  
    local ply = source
    local uid = unique[ply]
    
    -- SQL: Insert new player character
    exports['ghmattimysql']:execute(
      "INSERT INTO characters "..
      "(idUnique, model, blenddata, hairstyle, bodystyle, overlay, clothes, preset1, preset2, preset3) "..
      "VALUES (@uid, @mdl, @blend, @hair, @body, @tmp, @wear, @wear, @wear, @wear)",
      {
        ['uid']   = uid,     ['mdl']  = model,
        ['blend'] = parents, ['hair'] = hair,   ['body'] = perm,
        ['tmp']   = temp,    ['wear'] = outfit
      },
      function()
        TriggerClientEvent('chat:addMessage', (-1), {
          color     = {245,220,60},
          multiline = false,
          args      = {
            "Please welcome our newest player",
            GetPlayerName(ply)
          }
        })
        TriggerClientEvent('cnr:create_finished', ply)
      end
    )
  end
)

