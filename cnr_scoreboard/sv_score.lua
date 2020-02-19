
RegisterServerEvent('cnr:client_loaded')


local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local rankFormula = function(n) return ((n * (n+1) )/2) * 100 end
local levels = {}

local points = {
  bust   = 9,  kill   = 6, kcop   = 9, burg = 3,
  steal  = 2,  rob    = 4, fish   = 1, hunt = 1,
  rape   = 5,  craft  = 1, escape = 3,
  
  wantedUp = 1.3, wantedDown = 1.65
}

--- EXPORT: CalculateRanks()
-- Converts the given score to a rank level
-- @param client The player to get the ranks of
-- @return Table {'cop', 'civ'}
function CalculateRanks(client)
  
  local copRank, civRank = 1, 1
  if client then
    if levels[client].cop > rankFormula(1) then
      while (levels[client].cop > rankFormula(copRank)) do 
        copRank = copRank + 1
        Citizen.Wait(1)
      end
    end
    if levels[client].civ > rankFormula(1) then
      while (levels[client].civ > rankFormula(civRank)) do 
        civRank = civRank + 1
        Citizen.Wait(1)
      end
    end
  end
  return {cop = copRank, civ = civRank}
end

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
  
  -- Avoids using MySQL to update the points
  local scores = nil
  if levels[client].cop then 
    scores = {
      [1] = {
        cop = levels[client].cop + pts,
        civ = levels[client].civ
      }
    }
  end
  SetScore(client, scores)
  
end)

local function SetScore(client, scores)

  if not client then return 0 end
  if type(client) ~= "number" then client = tonumber(client) end
  if not levels[client] then
    print("DEBUG - No levels[client]. Creating...")
    levels[client] = {cop = 0, civ = 0}
  end
  
  if not scores then 
    print("DEBUG - No scores received. Defaulting...")
    -- Create 'scores' var in SQL result format (i.e "scores[1]")
    scores = {
      [1] = { cop = levels[client].cop, civ = levels[client].civ }
    }
  end
  
  levels[client] = {civ = scores[1]['civ'], cop = scores[1]['cop']}
  local newScores = CalculateRanks(client)
  print("DEBUG - Scores: "..json.encode(levels[client]).."& Calculated Ranks: "..json.encode(newScores))
  TriggerClientEvent('cnr:score_receive', (-1), client, newScores)
  --TriggerClientEvent('cnr:score_receive', (-1), client, scores)
      
end

AddEventHandler('cnr:points_wanted', function(client, oldPts, newPts, crime)
  print("DEBUG - Received event points_wanted with args: "..
    client..", "..oldPts..", "..newPts..", "..crime
    )
  if crime ~= "jailed" then 
    
    -- Find difference in wanted level
    local changed = math.ceil(math.abs(oldPts - newPts) / 10)
    local uid = exports['cnrobbers']:UniqueId(client)
    local pts = math.floor(changed * points.wantedUp)
    print("DEBUG - Wanted level changed by "..changed)
    
    -- Add points for wanted level change
    exports['ghmattimysql']:execute(
      "UPDATE players SET civ = civ + @val WHERE idUnique = @cid",
      {['val'] = pts, ['cid'] = uid}
    )
    
    -- Broadcast Change
    -- Avoids using MySQL to update the points
    local scores = nil
    if levels[client].cop then 
      scores = {
        [1] = {
          cop = levels[client].cop,
          civ = levels[client].civ + pts
        }
      }
    end
    SetScore(client, scores)
    
  end
end)

AddEventHandler('playerDropped', function(reason)
  local client = source
  print(GetPlayerName(client).." quit. Removing their scoreboard values.")
  levels[client] = nil
end)


AddEventHandler('cnr:client_loaded', function()
  local client = source
  
  -- SQL: Update player's score(s)
  local pts = exports['ghmattimysql']:execute(
    "SELECT cop,civ FROM players WHERE idUnique = @uid",
    {['uid'] = exports['cnrobbers']:UniqueId(client)},
    function(scores)
      SetScore(client, scores)
    end
  )
  
end)

-- DEBUG - Updates connected players when resource is restarted
Citizen.CreateThread(function()
  Citizen.Wait(2000)
  local clients = GetPlayers()
  for k,v in pairs (clients) do 
    local pts = exports['ghmattimysql']:execute(
      "SELECT cop,civ FROM players WHERE idUnique = @uid",
      {['uid'] = exports['cnrobbers']:UniqueId(v)},
      function(scores)
        SetScore(v, scores)
      end
    )
  end
end)

RegisterCommand('levels_test', function(s,a,r)
  local n = tonumber(a[1])
  local calc = ((n * (n+1) )/2) * 100
  print(n .. " = " .. calc)
end)