
-- sv admin
RegisterServerEvent('cnr:client_loaded')
RegisterServerEvent('cnr:admin_check')

RegisterServerEvent('cnr:admin_cmd_kick')
RegisterServerEvent('cnr:admin_cmd_ban')
RegisterServerEvent('cnr:admin_cmd_warn')
RegisterServerEvent('cnr:admin_cmd_freeze')
RegisterServerEvent('cnr:admin_cmd_unfreeze')
RegisterServerEvent('cnr:admin_cmd_tphere')
RegisterServerEvent('cnr:admin_cmd_tpto')
RegisterServerEvent('cnr:admin_cmd_tpsend')
RegisterServerEvent('cnr:admin_cmd_tpmark')
RegisterServerEvent('cnr:admin_cmd_broadcast')
RegisterServerEvent('cnr:admin_cmd_asay')
RegisterServerEvent('cnr:admin_cmd_plyinfo')

local admins = {}
local warns  = {}
local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end


local function AssignAdministrator(client, aLevel)
  repeat
    local gen = math.random(1000,9999)
    if aLevel == 2 then gen = math.random(100,999) end
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
  return ( admins[client] )
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


--- BlockAction()
-- Blocks the action attempt if affected admin is equal or greater rank
-- @return True if the action should be blocked/stopped
local function BlockAction(offense, defense) --[[
  if admins[offense] > 9999 then return false
  elseif admins[offense] > 999 then
    if admins[defense] > 999 then return true end
  elseif admins[offense] > 99 then
    if admins[defense] > 99 then return true end
  end
  return true ]] return false
end


AddEventHandler('cnr:admin_cmd_ban', function(target, banReason, minutes)
  local client = source
  if admins[client] then

    if admins[client] > 99 then
    
      if BlockAction(client, target) then
        cprint("Admin Action was blocked (equal or greater rank)")
        TriggerEvent('cnr:admin_message',
          "Admin "..GetPlayerName(client).." (ID #"..client..") attempted to BAN "..
          "Admin "..GetPlayerName(target).." (ID #"..target.."), but was blocked."
        )
        return 0
      end

      local banType = " permabanned "
      if minutes then banType = " tempbanned " end
      TriggerClientEvent('chat:addMessage', (-1), {
        multiline = true, args = {
          "^1Admin #"..(admins[client])..
          banType..GetPlayerName(target)..
          "\nReason: ^7"..tostring(banReason)
        }
      })

      local uid = exports['cnrobbers']:UniqueId(target)
      if minutes then
        local bTime = os.time() + (minutes * 1000)
        banReason = banReason.." (Ban lifts: "..(os.date("%I:%M%p", bTime))..")"
        local bTimeModified = os.date("%Y-%m-%d %I:%M:%S", bTime)
        exports['ghmattimysql']:execute(
          "UPDATE players SET perms = 0, bantime = @bt, "..
          "reason = @br WHERE idUnique = @uid",
          {
            ['br'] = banReason, ['uid'] = uid,
            ['bt'] = bTimeModified
          }
        )
        
      else
        exports['ghmattimysql']:execute(
          "UPDATE players SET perms = 0, bantime = NULL, "..
          "reason = @br WHERE idUnique = @uid",
          {['br'] = banReason, ['uid'] = uid}
        )
        
      end

      Citizen.Wait(1200)
      DropPlayer(target, msg..": "..banReason)

    else
      local msg = "Insufficient Permissions"
      TriggerEvent('cnr:admin_message', msg)

    end
  else
    print("DEBUG - Not an Admin.")
  end
end)


AddEventHandler('cnr:admin_cmd_warn', function(target, reason)
  local client = source
  if admins[client] then

    if admins[client] > 99 then
      
      if BlockAction(client, target) then
        cprint("Admin Action was blocked (equal or greater rank)")
        TriggerEvent('cnr:admin_message',
          "Admin "..GetPlayerName(client).." (ID #"..client..") attempted to warn "..
          "Admin "..GetPlayerName(target).." (ID #"..target.."), but was blocked."
        )
        return 0
      end
      
      if not warns[target] then warns[target] = 0 end
      warns[target] = warns[target] + 1

      if warns[target] > 2 then
        TriggerClientEvent('chat:addMessage', (-1), {
          multiline = true, args = {
            "^1Server auto-kicked "..GetPlayerName(target)..": Too many warnings. "..
            "\nLatest Warning For: "..reason
          }
        })
        Citizen.Wait(1200)
        DropPlayer(target, "Auto-Kicked: Received 3 Warnings in One Session.")
      else
        TriggerClientEvent('chat:addMessage', (-1), {
          multiline = true, args = {
            "^1Admin #"..(admins[client])..
            " warned "..GetPlayerName(target).." ("..warns[target].."/3)"..
            "\nReason: ^7"..reason
          }
        })
      end

    else
      local msg = "Insufficient Permissions"
      TriggerEvent('cnr:admin_message', msg)

    end
  else
    print("DEBUG - Not an Admin.")
  end
end)


AddEventHandler('cnr:admin_cmd_freeze', function(target, doFreeze)
  local client = source
  if admins[client] then

    if admins[client] > 99 then
      
      if BlockAction(client, target) then
        cprint("Admin Action was blocked (equal or greater rank)")
        TriggerEvent('cnr:admin_message',
          "Admin "..GetPlayerName(client).." (ID #"..client..") attempted to freeze "..
          "Admin "..GetPlayerName(target).." (ID #"..target.."), but was blocked."
        )
        return 0
      end
      
      TriggerClientEvent('cnr:admin_do_freeze', target, doFreeze, admins[client])

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
