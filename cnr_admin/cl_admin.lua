
-- cl admin
RegisterNetEvent('cnr:admin_assigned')

local aLevel = 1
local aid    = 0


RegisterCommand('checkadmin', function()
  TriggerServerEvent('cnr:admin_check')
end)


AddEventHandler('cnr:admin_assigned', function(aNumber)
  aid = aNumber
  if     aNumber > 999 then aLevel = 3
  elseif aNumber >  99 then aLevel = 2
  end
  TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
    args = {"^2Successfully logged in as an admin. ^7ID Assigned: "..aid}
  })
end)


RegisterCommand('kick', function(s,a,r)
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      if not a[1] or not a[2] then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"Invalid Arguments", "/"..cmd.." <ID#> <Reason>"}
        })

      else

        local tgt = tonumber( table.remove(a, 1) )

        local plys = GetActivePlayers()
        for _,i in ipairs (plys) do
          if GetPlayerServerId(i) == tgt then

            if tonumber(a[1]) == GetPlayerServerId(PlayerId()) then
              TriggerEvent('chat:addMessage', {multiline = false,
                args = { "^1Try kicking someone other than yourself."}}
              )

            else TriggerServerEvent('cnr:admin_cmd_kick', tgt, table.concat(a, " "))

            end
            break -- End the loop when we find the right person
          end
        end
      end
    else
      TriggerEvent('chat:addMessage', {
        templateId = 'cmdMsg', multiline = false, args = {"/"..cmd}
      })

    end
  else
    TriggerEvent('chat:addMessage', {
      templateId = 'cmdMsg', multiline = false, args = {"/"..r}
    })

  end
end)


RegisterCommand('ban', function(s,a,r)
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      if not a[1] or not a[2] then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"Invalid Arguments", "/"..cmd.." <ID#> <Reason>"}
        })

      else

        local tgt = tonumber( table.remove(a, 1) )

        local plys = GetActivePlayers()
        for _,i in ipairs (plys) do
          if GetPlayerServerId(i) == tgt then

            TriggerServerEvent('cnr:admin_cmd_ban', tgt, table.concat(a, " "))
            break -- End the loop when we find the right person
          end
        end
      end
    else
      TriggerEvent('chat:addMessage', {
        templateId = 'cmdMsg', multiline = false, args = {"/"..cmd}
      })

    end
  else
    TriggerEvent('chat:addMessage', {
      templateId = 'cmdMsg', multiline = false, args = {"/"..r}
    })

  end
end)


RegisterCommand('tempban', function(s,a,r)
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      if not a[1] or not a[2] or not a[3] then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"Invalid Arguments", "/"..cmd.." <ID#> <Minutes> <Reason>"}
        })

      else

        local mins = tonumber( table.remove(a, 2) )
        local tgt  = tonumber( table.remove(a, 1) )
        if     mins > 900 then mins = 900
        elseif mins <  15 then mins =  15 end

        local plys = GetActivePlayers()
        for _,i in ipairs (plys) do
          if GetPlayerServerId(i) == tgt then
            TriggerServerEvent('cnr:admin_cmd_ban', tgt, table.concat(a, " "), mins)
            break -- End the loop when we find the right person
          end
        end
      end
    else
      TriggerEvent('chat:addMessage', {
        templateId = 'cmdMsg', multiline = false, args = {"/"..cmd}
      })

    end
  else
    TriggerEvent('chat:addMessage', {
      templateId = 'cmdMsg', multiline = false, args = {"/"..r}
    })

  end
end)


RegisterCommand('warn', function()
  print("DEBUG - This is the kick command!")
end)


RegisterCommand('freeze', function()
  print("DEBUG - This is the kick command!")
end)


RegisterCommand('unfreeze', function()
  print("DEBUG - This is the kick command!")
end)


RegisterCommand('tphere', function()
  print("DEBUG - This is the kick command!")
end)


RegisterCommand('tpto', function()
  print("DEBUG - This is the kick command!")
end)


RegisterCommand('tpsend', function()
  print("DEBUG - This is the kick command!")
end)


RegisterCommand('tpmark', function()
  print("DEBUG - This is the kick command!")
end)


RegisterCommand('broadcast', function()
  print("DEBUG - This is the kick command!")
end)


RegisterCommand('asay', function()
  print("DEBUG - This is the kick command!")
end)


RegisterCommand('plyinfo', function()
  print("DEBUG - This is the kick command!")
end)