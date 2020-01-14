
-- sv admin
RegisterServerEvent('cnr:client_loaded')
RegisterServerEvent('cnr:admin_check')

RegisterServerEvent('cnr:admin_cmd_kick')
RegisterServerEvent('cnr:admin_cmd_ban')

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


AddEventHandler('cnr:admin_cmd_kick', function(target, kickReason)
  local client = source
  if admins[client] then
    if admins[target] then 
      if admins[target] >= 1000 and admins[client] < 1000 then 
        TriggerEvent('cnr:admin_message',
          "Admin "..GetPlayerName(client).." (ID #"..client..") attempted to kick "..
          "Admin "..GetPlayerName(target).." (ID #"..target.."), but was blocked."
        )
        return 0
      end
    end
    TriggerClientEvent('chat:addMessage', (-1), {
      multiline = true, args = {
        "^1Admin #"..(admins[client])..
        " kicked "..GetPlayerName(target)..
        "\nReason: ^7"..tostring(kickReason)
      }
    })
    Citizen.Wait(1200)
    DropPlayer(target, "Kicked by Admin: "..kickReason)
  else
    print("DEBUG - Not an Admin.")
  end
end)


AddEventHandler('cnr:admin_cmd_ban', function(target, banReason)
  local client = source
  if admins[client] then
  
    if admins[client] > 999 then 
      --[[if admins[target] then
        if admins[target] >= 1000 then 
          TriggerEvent('cnr:admin_message',
            "Admin "..GetPlayerName(client).." (ID #"..client..") attempted to BAN "..
            "Admin "..GetPlayerName(target).." (ID #"..target.."), but was blocked."
          )
          return 0
        end
      end]]
    
      TriggerClientEvent('chat:addMessage', (-1), {
        multiline = true, args = {
          "^1Admin #"..(admins[client])..
          " permabanned "..GetPlayerName(target)..
          "\nReason: ^7"..tostring(banReason)
        }
      })
      local uid = exports['cnrobbers']:UniqueId(target)
      exports['ghmattimysql']:execute(
        "UPDATE players SET perms = 0, bantime = NULL, "..
        "reason = @br WHERE idUnique = @uid",
        {['br'] = banReason, ['uid'] = uid}
      )
      Citizen.Wait(1200)
      DropPlayer(target, "Banned by Admin: "..banReason)
      
    else
      local msg = "Insufficient Permissions"
      TriggerEvent('cnr:admin_message', msg)
      
    end
  else
    print("DEBUG - Not an Admin.")
  end
end)










function ActionLog(logMessage)
  cprint("ADMIN: "..logMessage)
end
