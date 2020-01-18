
-- sv admin
RegisterServerEvent('cnr:client_loaded')
RegisterServerEvent('cnr:admin_check')

RegisterServerEvent('cnr:admin_cmd_kick')
RegisterServerEvent('cnr:admin_cmd_ban')
RegisterServerEvent('cnr:admin_cmd_warn')
RegisterServerEvent('cnr:admin_cmd_freeze')
RegisterServerEvent('cnr:admin_cmd_teleport')
RegisterServerEvent('cnr:admin_cmd_tp_sendback')
RegisterServerEvent('cnr:admin_cmd_unfreeze')
RegisterServerEvent('cnr:admin_cmd_tphere')
RegisterServerEvent('cnr:admin_cmd_tpto')
RegisterServerEvent('cnr:admin_cmd_tpsend')
RegisterServerEvent('cnr:admin_cmd_tpmark')
RegisterServerEvent('cnr:admin_cmd_announce')
RegisterServerEvent('cnr:admin_cmd_mole')
RegisterServerEvent('cnr:admin_cmd_asay')
RegisterServerEvent('cnr:admin_cmd_csay')
RegisterServerEvent('cnr:admin_cmd_plyinfo')
RegisterServerEvent('cnr:admin_cmd_vehinfo')
RegisterServerEvent('cnr:admin_cmd_svinfo')
RegisterServerEvent('cnr:admin_cmd_spawncar')
RegisterServerEvent('cnr:admin_cmd_delveh')
RegisterServerEvent('cnr:admin_cmd_spawnped')
RegisterServerEvent('cnr:admin_cmd_setcash')
RegisterServerEvent('cnr:admin_cmd_setbank')
RegisterServerEvent('cnr:admin_cmd_setweather')
RegisterServerEvent('cnr:admin_cmd_settime')
RegisterServerEvent('cnr:admin_cmd_giveweapon')
RegisterServerEvent('cnr:admin_cmd_takeweapon')
RegisterServerEvent('cnr:admin_cmd_stripweapons')
RegisterServerEvent('cnr:admin_cmd_togglelock')
RegisterServerEvent('cnr:admin_cmd_inmates')

local admins = {}
local warns  = {}
local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end

--- EXPORT: AdminLevel()
-- Checks if the player is an admin
-- @param client The server ID
-- @return table 1:Admin Level, 2:Admin ID Number
function AdminLevel(client)

  if not client then          return {[1] = 0, [2] = 0}  end 
  if not admins[client] then  return {[1] = 0, [2] = 0}  end 
  
  if admins[client] > 9999 then
    return {[1] = 4, [2] = admins[client]}
  elseif admins[client] > 999 then
    return {[1] = 3, [2] = admins[client]}
  end
  
  return {[1] = 2, [2] = admins[client]}
end

local function AssignAdministrator(client, aLevel)
  if not type(aLevel) == "number" then aLevel = tonumber(aLevel) end
  if aLevel > 1 then
    repeat
      
      local gen = math.random(1000,9999)
      if aLevel == 2 then gen = math.random(100,999)
      elseif aLevel == 4 then gen = math.random(10000, 99999)
      end
      
      local exists = false
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
  end
  return ( admins[client] )
end


local function CheckAdmin(client)
  local uid    = exports['cnrobbers']:UniqueId(client)
  local aLevel = exports['ghmattimysql']:scalarSync(
    "SELECT perms FROM players WHERE idUnique = @uid",
    {['uid'] = uid}
  )
  if aLevel then
    AssignAdministrator(client, aLevel)

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
local function BlockAction(offense, defense)
  if admins[offense] > 9999 then return false
  elseif admins[offense] > 999 then
    if admins[defense] > 999 then return true end
  elseif admins[offense] > 99 then
    if admins[defense] > 99 then return true end
  end
  return true
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
      DropPlayer(target, "Banned by Admin: "..banReason)

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


-- DEBUG - Come back and finish this after asay works
local function TeleportAlert(toPlayer, fromPlayer, admin, aid)

  -- CASE 1: Player to Player
  if toPlayer and fromPlayer then 
    -- CASE 1A: Player to Player 
    if toPlayer ~= admin and fromPlayer ~= admin then 
    
    -- CASE 1B: Player to Admin
    elseif toPlayer == admin then 
    
    -- CASE 1C: Admin to Player
    elseif fromPlayer == admin then 
    
    -- CASE 1D: Admin to Admin
    else
    
    end
  
  -- CASE 2: Player to Nobody (TP to coords)
  elseif fromPlayer then
  
  -- CASE 3: Nobody to Player (Should never happen?)
  else
  
  end
  
  
end

AddEventHandler('cnr:admin_cmd_teleport', function(toPlayer, fromPlayer, coords)
  local client = source
  print("DEBUG", toPlayer, fromPlayer, coords)
  if admins[client] then 
    -- Sending one player to another
    if toPlayer > 0 and fromPlayer > 0 then 
      print("DEBUG - Sending Player 1 to Player 2")
      TriggerClientEvent('cnr:admin_tp_coords', fromPlayer, toPlayer, nil, admins[client])
      TeleportAlert(toPlayer, fromPlayer, client, admins[client])
      ActionLog("Admin #"..admins[client].." ("..GetPlayerName(client)..") sent "..GetPlayerName(fromPlayer).." (ID #"..fromPlayer..") to "..GetPlayerName(toPlayer).." (ID #"..toPlayer..")")
    
    -- Sending themselves to another player
    elseif toPlayer > 0 then
    print("DEBUG - Sending admin to Player")
      TriggerClientEvent('cnr:admin_tp_coords', client, toPlayer, nil, admins[client])
      TeleportAlert(toPlayer, client, client, admins[client])
      ActionLog("Admin #"..admins[client].." ("..GetPlayerName(client)..") teleported to "..GetPlayerName(toPlayer).." (ID #"..toPlayer..")")
      
    -- Bringing another player to themselves
    elseif fromPlayer > 0 then 
      print("DEBUG - Sending player to Admin")
      TriggerClientEvent('cnr:admin_tp_coords', fromPlayer, client, nil, admins[client])
      TeleportAlert(client, fromPlayer, client, admins[client])
      ActionLog("Admin #"..admins[client].." ("..GetPlayerName(client)..") brought "..GetPlayerName(fromPlayer).." (ID #"..fromPlayer..") to them.")
      
    -- Going to a specific location
    else
      print("DEBUG - Sending admin to coords")
      TriggerClientEvent('cnr:admin_tp_coords', client, client, coords, admins[client])
      TeleportAlert(nil, nil, client, admins[client])
      ActionLog("Admin #"..admins[client].." ("..GetPlayerName(client)..") teleported to "..tostring(coords))
    end
  else
    print("DEBUG - Not an Admin.")
  end
end)


AddEventHandler('cnr:admin_cmd_teleport', function(teleportee)
  local client = source
  if admins[client] then 
    TriggerClientEvent('cnr:admin_do_sendback', teleportee, admins[client])
  else print("DEBUG - Not an Admin.")
  end
end)

AddEventHandler('cnr:admin_cmd_announce', function(message)
  local client = source
  if admins[client] then
    if admins[client] > 999 then 
      TriggerClientEvent('chat:addMessage', (-1), {templateId = 'sysMsg',
        args = { "Admin #"..admins[client]..": "..message }
      })
    else
      TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
        args = { "Insufficient Permissions." }
      })
    end
  else print("DEBUG - Not an Admin.")
  end
end)


AddEventHandler('cnr:admin_cmd_mole', function(message)
  local client = source
  if admins[client] then
    if admins[client] > 999 then 
      TriggerClientEvent('cnr:chat_notification', (-1), "CHAR_LESTER",
        "MOLE", "555-1234", message
      )
    else
      TriggerClientEvent('cnr:chat_notification', (-1), "CHAR_LESTER",
        "5M CNR", "Server Notice", "Insufficient Permissions"
      )
    end
  else print("DEBUG - Not an Admin.")
  end
end)


--- EXPORT: AdminMessage()
-- Sends an admin message to all admins on the server
-- @param message A message sent to all admins
-- @param client  Player Server ID; If nil, comes from "server"
function AdminMessage(message, client)
  
  local aid  = 0
  local ply  = "SERVER"
  local name = "SERVER CONSOLE"
  if client then
    ply  = client
    aid  = admins[client]
    name = GetPlayerName(client)
  end
  PerformHttpRequest(
    "https://discordapp.com/api/webhooks/667800489534160925/ws7iwSoeIBjRrcX5vV7nJoyDFoAEXXAXoJx6onGgZyKqa3fLWBAJzf12fGzWUuA5gTqT",
    function(err, text, headers) end, 'POST',
    json.encode({
      username = "5M:CNR Monitor",
      content  = "**"..name.." (# "..aid..")**: "..message
    }),
    { ['Content-Type'] = 'application/json' }
  )
  for k,_ in pairs (admins) do 
    TriggerClientEvent('chat:addMessage', k, {templateId = 'asay',
      args = {name.." ("..aid..")", message}
    })
  end
  
end

RegisterCommand('asay', function(s,a,r)
  AdminMessage(table.concat(a, " "))
end, true)

AddEventHandler('cnr:admin_cmd_asay', function(message)
  local client = source
  if admins[client] then AdminMessage(message, client)
  else print("DEBUG - Not an Admin")
  end
end)


AddEventHandler('cnr:admin_cmd_csay', function(message)
  local client = source
  TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
    args = { "( Not Implemented )" }
  })
end)


AddEventHandler('cnr:admin_cmd_plyinfo', function()
  local client = source
  TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
    args = { "( Not Implemented )" }
  })
end)


AddEventHandler('cnr:admin_cmd_vehinfo', function()
  local client = source
  TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
    args = { "( Not Implemented )" }
  })
end)

AddEventHandler('cnr:admin_cmd_svinfo', function()
  local client = source
  TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
    args = { "( Not Implemented )" }
  })
end)


AddEventHandler('cnr:admin_cmd_spawncar', function(vModel)
  local client = source
  if admins[client] then
    if admins[client] > 999 then 
      TriggerClientEvent('cnr:admin_do_spawncar', client, vModel)
    else
      TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
        args = { "Insufficient Permissions" }
      })
    end
  else print("DEBUG - Not an Admin")
  end
end)


AddEventHandler('cnr:admin_cmd_delveh', function()
  local client = source
  if admins[client] then
    TriggerClientEvent('cnr:admin_do_delveh', client)
  else print("DEBUG - Not an Admin")
  end
end)


AddEventHandler('cnr:admin_cmd_spawnped', function()

end)


AddEventHandler('cnr:admin_cmd_setcash', function(target, amount)
  
  local client = source
  if admins[client] then
  
    -- If amount is positive
    if amount > 0 then
      TriggerClientEvent('chat:addMessage', target, {templateId = 'sysMsg',
        args = { "Admin #"..admins[client].." added $"..amount.." to your wallet." }
      })
      exports['cnr_cash']:CashTransaction(target, amount)
    
    -- If amount is negative
    elseif amount < 0 then
      if admins[target] then
        -- Admin is higher ranking OR a Superadmin
        if admins[client] > admins[target] or admins[client] > 9999 then
          TriggerClientEvent('chat:addMessage', target, {templateId = 'sysMsg',
            args = { "Admin #"..admins[client].." took away $"..amount.." from your wallet." }
          })
          exports['cnr_cash']:CashTransaction(target, amount)
          
        -- Admin isn't a Superadmin, and is equal or lower ranking than target
        else
          TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
            args = { "Can't take money away from a higher/equal ranking admin" }
          })
        
        end
      
      else
        TriggerClientEvent('chat:addMessage', target, {templateId = 'sysMsg',
          args = { "Admin #"..admins[client].." took away $"..amount.." from your wallet." }
        })
        exports['cnr_cash']:CashTransaction(target, amount)
      
      end
    
    else
      TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
        args = { "Enter an amount other than 0. (Negative takes away money)" }
      })
    
    end
  else print("DEBUG - Not an Admin")
  end
end)


AddEventHandler('cnr:admin_cmd_setbank', function(target, amount)
  
  local client = source
  if admins[client] then
  
    -- If amount is positive
    if amount > 0 then
      TriggerClientEvent('chat:addMessage', target, {templateId = 'sysMsg',
        args = { "Admin #"..admins[client].." added $"..amount.." to your bank balance." }
      })
      exports['cnr_cash']:BankTransaction(target, amount)
    
    -- If amount is negative
    elseif amount < 0 then
      if admins[target] then
        -- Admin is higher ranking OR a Superadmin
        if admins[client] > admins[target] or admins[client] > 9999 then
          TriggerClientEvent('chat:addMessage', target, {templateId = 'sysMsg',
            args = { "Admin #"..admins[client].." took away $"..amount.." from your bank balance." }
          })
          exports['cnr_cash']:BankTransaction(target, amount)
          
        -- Admin isn't a Superadmin, and is equal or lower ranking than target
        else
          TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
            args = { "Can't take money away from a higher/equal ranking admin" }
          })
        
        end
      
      else
        TriggerClientEvent('chat:addMessage', target, {templateId = 'sysMsg',
          args = { "Admin #"..admins[client].." took away $"..amount.." from your bank balance." }
        })
        exports['cnr_cash']:BankTransaction(target, amount)
      
      end
    
    else
      TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
        args = { "Enter an amount other than 0. (Negative takes away money)" }
      })
    
    end
  else print("DEBUG - Not an Admin")
  end
end)


AddEventHandler('cnr:admin_cmd_setweather', function()

end)


AddEventHandler('cnr:admin_cmd_settime', function()

end)


AddEventHandler('cnr:admin_cmd_giveweapon', function(target, wHash, wAmmo)
  local client = source
  if admins[client] then 
    if admins[client] > 999 then 
      TriggerClientEvent('cnr:admin_do_giveweapon', target, admins[client], wHash, wAmmo)
    else
      TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg',
        args = { "Insufficient Permissions" }
      })
    end
  else print("DEBUG - Not an Admin.")
  end
end)


AddEventHandler('cnr:admin_cmd_takeweapon', function()

end)


AddEventHandler('cnr:admin_cmd_stripweapons', function()

end)


AddEventHandler('cnr:admin_cmd_togglelock', function(vehNumber)
  local client = source
  if admins[client] then 
    TriggerClientEvent('cnr:admin_do_togglelock', client, vehNumber)
  else print("DEBUG - Not an Admin.")
  end
end)


AddEventHandler('cnr:admin_cmd_inmates', function()

end)





function ActionLog(logMessage)
  cprint("ADMIN: "..logMessage)
end
