
-- cl admin
RegisterNetEvent('cnr:admin_assigned')
RegisterNetEvent('cnr:admin_do_freeze')

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


RegisterCommand('warn', function(s,a,r)
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      if not a[1] or not a[2] or not a[3] then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"Invalid Arguments", "/"..cmd.." <ID#> <Reason>"}
        })

      else

        local tgt  = tonumber( table.remove(a, 1) )

        local plys = GetActivePlayers()
        for _,i in ipairs (plys) do
          if GetPlayerServerId(i) == tgt then
            TriggerServerEvent('cnr:admin_cmd_warn', tgt, table.concat(a, " "))
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


RegisterCommand('freeze', function(s,a,r)
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      if not a[1] then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"Invalid Arguments", "/"..cmd.." <ID#>"}
        })

      else

        local tgt  = tonumber( table.remove(a, 1) )

        local plys = GetActivePlayers()
        for _,i in ipairs (plys) do
          if GetPlayerServerId(i) == tgt then
            TriggerServerEvent('cnr:admin_cmd_freeze', tgt, true)
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


RegisterCommand('unfreeze', function(s,a,r)
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      if not a[1] then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"Invalid Arguments", "/"..cmd.." <ID#>"}
        })

      else

        local tgt  = tonumber( table.remove(a, 1) )

        local plys = GetActivePlayers()
        for _,i in ipairs (plys) do
          if GetPlayerServerId(i) == tgt then
            TriggerServerEvent('cnr:admin_cmd_freeze', tgt, false)
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


RegisterCommand('tphere', function(s,a,r)
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      if not a[1] then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"Invalid Arguments", "/"..cmd.." <ID#>"}
        })

      else

        local tgt  = tonumber( table.remove(a, 1) )

        local plys = GetActivePlayers()
        for _,i in ipairs (plys) do
          if GetPlayerServerId(i) == tgt then
            TriggerServerEvent('cnr:admin_cmd_teleport', nil, tgt)
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


RegisterCommand('tpto', function(s,a,r)
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      if not a[1] then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"Invalid Arguments", "/"..cmd.." <ID#>"}
        })

      else

        local tgt  = tonumber( table.remove(a, 1) )

        local plys = GetActivePlayers()
        for _,i in ipairs (plys) do
          if GetPlayerServerId(i) == tgt then
            TriggerServerEvent('cnr:admin_cmd_teleport', tgt)
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


RegisterCommand('tpsend', function(s,a,r)
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      if not a[1] or not a[2] then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"Invalid Arguments", "/"..cmd.." <send_ID> <to_ID>"}
        })

      else

        local destPlayer  = tonumber( table.remove(a, 2) )
        local sendPlayer  = tonumber( table.remove(a, 1) )

        local plys = GetActivePlayers()
        local count = 0
        for _,i in ipairs (plys) do
          local sid = GetPlayerServerId(i)
          if sid == destPlayer or sid == sendPlayer then count = count + 1 end
        end
        if count > 1 then
          TriggerServerEvent('cnr:admin_cmd_teleport', destPlayer, sendPlayer)
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


RegisterCommand('tpmark', function()
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      local ped   = PlayerPedId()
      local blip  = GetFirstBlipInfoId(8) -- Retrieve GPS marker
      local coord = nil
      if DoesBlipExist(blip) then coord = GetBlipInfoIdCoord(blip) end
  
      if not coord then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"No Marker Set", "/"..cmd.." requires a set map marker"}
        })

      else TriggerServerEvent('cnr:admin_cmd_teleport', nil, nil, coords)
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


RegisterCommand('tpcoords', function(s,a,r)
  if a[1] then
    local cmd = string.sub(r, 1, string.find(r, ' ') - 1)
    if aLevel >= CommandLevel(cmd) then

      if not a[1] or not a[2] or not a[3] then
        TriggerEvent('chat:addMessage', {
          templateId = 'errMsg', multiline = true,
            args = {"Invalid Arguments", "/"..cmd.." <x> <y> <z>"}
        })

      else
        TriggerServerEvent('cnr:admin_cmd_teleport', nil, nil,
          vector3(tonumber(a[1]), tonumber(a[2]), tonumber(a[3]))
        )
        
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


RegisterCommand('broadcast', function()
end)


RegisterCommand('asay', function()
end)


RegisterCommand('plyinfo', function()
end)

AddEventHandler('cnr:admin_do_freeze', function(doFreeze, aid)
  local msg = "You have been frozen in place by Admin #"..aid
  if doFreeze then
    local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 0.0, 0.3)
    SetEntityCoords(PlayerPedId(), offset.x, offset.y, offset.z)
    FreezeEntityPosition(PlayerPedId(), true)
  
  else
    FreezeEntityPosition(PlayerPedId(), false)
    msg = "You have been unfrozen."
    
  end
  TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {msg}})
end)

AddEventHandler('cnr:admin_tp_coords', function(toPlayer, coords, aid)
  
  -- Only allow if the event comes from the server, not the client
  if source == "" then
    print("^1CNR ERROR: ^7Unable to authorize the teleport request.")
    return 0
  end
  
  
  
end)