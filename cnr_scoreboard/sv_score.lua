
RegisterServerEvent('cnr:client_loaded')


local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local levels = { cop = {}, civ = {} }

local points = {
  bust   = 9,  kill   = 6, kcop   = 9, burg = 3,
  steal  = 2,  rob    = 4, fish   = 1, hunt = 1,
  rape   = 5,  craft  = 1, escape = 3,
  
  wantedUp = 1, wantedDown = 1.45
}


-- Adjust player's score accordingly
AddEventHandler('cnr:imprisoned', function(client, cop, wLevel)
  
  local uid = exports['cnrobbers']:UniqueId(cop)
  local pts = wLevel * points.bust
  
  -- Add pts to player's cop score
  exports['ghmattimysql']:execute(
    "UPDATE players SET cop = cop + @val WHERE idUnique = @cid",
    {['val'] = pts, ['cid'] = uid}
  )
  cprint(
    GetPlayerName(cop).." ("..cop..") was awarded "..pts..
    " for arresting "..GetPlayerName(client).." ("..client..")"
  )
  
  TriggerClientEvent('cnr:score_receive', (-1), ply, scores[1])
  
end)

local function SetScore(client, scores)

  if not scores           then scores[1] = {['civ'] = 1, ['cop'] = 1} end
  if not scores[1]        then scores[1] = {['civ'] = 1, ['cop'] = 1} end
  if not scores[1]['civ'] then scores[1] = {['civ'] = 1, ['cop'] = 1}
  end
  
  levels.civ[client] = scores[1]['civ']
  levels.cop[client] = scores[1]['cop']
  
  TriggerClientEvent('cnr:score_receive', (-1), ply, scores[1])
      
end

AddEventHandler('cnr:points_wanted', function(client, prevLevel, nowLevel, crime)
  if crime ~= "jailed" then 
    
    -- Find difference in wanted level
    local changed = math.ceil(math.abs(nowLevel - prevLevel))
    local uid = exports['cnrobbers']:UniqueId(client)
    
    -- Add points for wanted level change
    local scores = exports['ghmattimysql']:executeSync(
      "UPDATE players SET civ = civ + @val WHERE idUnique = @cid",
      {['val'] = math.floor(changed * points.wantedDown), ['cid'] = uid}
    )
    
    -- Broadcast Change
    SetScore(ply, scores)
    
  end
end)


AddEventHandler('cnr:client_loaded', function()
  local client = source
  
  local pts = exports['ghmattimysql']:execute(
    "SELECT cop,civ FROM players WHERE idUnique = @uid",
    {['uid'] = exports['cnrobbers']:UniqueId(client)},
    function(scores)
      SetScore(ply, scores)
    end
  )
  
end)