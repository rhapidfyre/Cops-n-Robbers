
-- sv admin
RegisterServerEvent('cnr:client_loaded')
RegisterServerEvent('cnr:admin_check')

local adminid = {}

local function AssignAdministrator(aLevel)
  if aLevel > 2 then 
    
  
  elseif aLevel == 1 then 
    
    
  end
  return aLevel
end

local function CheckAdmin(client)
  local uid    = exports['cnrobbers']:UniqueId(client)
  local aLevel = exports['ghmattimysql']:scalarSync(
    "SELECT perms FROM players WHERE idUnique = @uid",
    {['uid'] = uid}
  )
  if aLevel then 
    AssignAdministrator(aLevel)
    
  else
    print("[CNR ADMIN] - No idUnique found for player #"..client)
    
  end
end

AddEventHandler('cnr:client_loaded', function() CheckAdmin(source) end)
AddEventHandler('cnr:admin_check',   function() CheckAdmin(source) end)

AddEventHandler('playerDisconnected', function(reason)
  local client = source
  if adminid[client] then adminid[client] = nil end
end)