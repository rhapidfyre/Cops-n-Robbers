
-- sv admin
RegisterServerEvent('cnr:client_loaded')
RegisterServerEvent('cnr:admin_check')

local admins = {}

local function AssignAdministrator(client, aLevel)
  repeat
    local gen = math.random(1000,9999)
    if aLevel == 1 then gen = math.random(100,999) end
    exists = false
    for k,v in pairs(admins) do 
      if v == gen then exists = true end
    end
    if not exists then 
      admins[client] = gen
      print("[CNR ADMIN] Assigned Admin ID "..admins[client].." to "..GetPlayerName(client))
      TriggerClientEvent('cnr:admin_assigned', client, admins[client])
    end
    Citizen.Wait(10)
  until admins[client]
  return admins[client]
end

local function CheckAdmin(client)
  local uid    = exports['cnrobbers']:UniqueId(client)
  local aLevel = exports['ghmattimysql']:scalarSync(
    "SELECT perms FROM players WHERE idUnique = @uid",
    {['uid'] = uid}
  )
  if aLevel then 
    local aid = AssignAdministrator(client, aLevel)
    if aid > 999 then 
      
    
    elseif aid > 99 then 
      
      
    end
    
  else
    print("[CNR ADMIN] - No idUnique found for player #"..client)
    
  end
end

AddEventHandler('cnr:client_loaded', function() CheckAdmin(source) end)
AddEventHandler('cnr:admin_check',   function() CheckAdmin(source) end)

AddEventHandler('playerDisconnected', function(reason)
  local client = source
  if admins[client] then admins[client] = nil end
end)