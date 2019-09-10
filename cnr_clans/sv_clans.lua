
RegisterServerEvent('cnr:clans_request')
RegisterServerEvent('cnr:clans_roster')
RegisterServerEvent('cnr:client_loaded')
local clans = {}

AddEventHandler('cnr:clans_roster', function(cn)
  local ply = source
  print("DEBUG - Player #"..ply.." requesting clan roster for idClan ["..cn..")")
  if cn then
    -- SQL: Retrieve members
    local plys = exports['ghmattimysql']:executeSync(
      "SELECT idUnique,username,cop,civ,cop+civ AS ranks FROM players "..
      "WHERE idClan = @c ORDER BY ranks",
      {['c'] = cn}
    )
    -- SQL: Retrieve leader's information
    local ldr  = exports['ghmattimysql']:scalarSync(
      "SELECT idUnique FROM players WHERE idClan = @c",
      {['c'] = cn}
    )
    if plys[1] then
      TriggerClientEvent('cnr:clans_members', ply, ldr, plys)
    else
      TriggerClientEvent('cnr:clans_members', ply, ldr)
    end
  end
end)


AddEventHandler('cnr:clans_request', function()
  local ply = source
  if #clans < 1 then ClanRetrieve() end
  print("DEBUG - Sending Client #"..ply.." clan list.")
  TriggerClientEvent('cnr:clans_receive', ply, clans)
end)


-- Populates the clans variable whenever called
-- Destroys existing information and refreshes it
function ClanRetrieve()
  clans = {}
  local temp = exports['ghmattimysql']:executeSync("SELECT * FROM clans")
  if temp then
    for k,v in pairs (temp) do
      local id = v["idClan"]
      clans[id] = {
        tag  = v["tag"],      name = v["title"],
        lead = v["idLeader"], cop  = v["cop"],   civ  = v["civ"]
      }
      print("DEBUG - Added clan ^2"..(v["title"]).."^7 at index "..(v["idClan"]))
    end
    print("DEBUG - Clan list generated.")
  else
    clans = {}
    print("DEBUG - No clans exist.")
  end
end

-- Updates the clans variable when a clan is created
function ClanCreated()

end

-- Updates the clans variable when a clan is disbanded
function ClanDisbanded()

end

-- Loads the clans variable upon script init
Citizen.CreateThread(function()
  Citizen.Wait(3000)
  ClanRetrieve()
end)

local tag = {}
function GetClanTag(ply)
  return tag[ply]
end
Citizen.CreateThread(function()
  Citizen.Wait(1000)
  local ply = source
  local uid = exports['cnrobbers']:UniqueId(ply)
  exports['ghmattimysql']:execute(
    "SELECT c.tag,c.idLeader FROM players p LEFT JOIN clans c "..
    "ON c.idClan = p.idClan WHERE p.idUnique = @u",
    function(cInfo)
      if cInfo[1] then 
        TriggerClientEvent('cnr:clan_tag', ply, cInfo[1]["tag"])
        if cInfo[1]["idLeader"] == uid then 
          TriggerClientEvent('cnr:clan_leader', ply, true)
        end
      end
    end
  )
end)