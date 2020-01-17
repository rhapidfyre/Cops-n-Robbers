
-- cl admin
RegisterNetEvent('cnr:admin_assigned')
RegisterNetEvent('cnr:admin_do_freeze')
RegisterNetEvent('cnr:admin_do_spawncar')
RegisterNetEvent('cnr:admin_do_delveh')
RegisterNetEvent('cnr:admin_do_togglelock')
RegisterNetEvent('cnr:admin_tp_coords')
RegisterNetEvent('cnr:admin_do_giveweapon')
RegisterNetEvent('cnr:admin_do_sendback')

local aLevel = 1
local aid    = 0



--[[
      UNFINISHED COMMANDS 
]]
RegisterCommand('spawnped', function(s,a,r) end)
RegisterCommand('setcash', function(s,a,r) end)
RegisterCommand('setbank', function(s,a,r) end)
RegisterCommand('setweather', function(s,a,r) end)
RegisterCommand('settime', function(s,a,r) end)
RegisterCommand('inmates', function() end)
----------------------------------------------------

AddEventHandler('onClientResourceStart', function(rname)
  if rname == GetCurrentResourceName() then
    TriggerEvent('chat:addTemplate', 'asay',
      '<b><font color="#F00">[STAFF CHAT]</font> '..
      '{0}</b><font color="#DDD">: {1}</font>'
    )
  end
end)


local function CommandValid(cmd)
  if cmd then
    if aLevel >= CommandLevel(cmd) then 
      return true
    end
  end
  TriggerEvent('chat:addMessage', {
    templateId = 'cmdMsg', multiline = false, args = {"/"..cmd}
  })
  return false
end

  
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
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then

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
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('ban', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then

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
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('tempban', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then

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
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('warn', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
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
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('freeze', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then

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
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('unfreeze', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
   
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
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('tphere', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then

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
          TriggerServerEvent('cnr:admin_cmd_teleport', 0, tgt)
          break -- End the loop when we find the right person
        end
      end
    end
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('tpto', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
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
          TriggerServerEvent('cnr:admin_cmd_teleport', tgt, 0)
          break -- End the loop when we find the right person
        end
      end
    end
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('tpsend', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
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
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('tpmark', function()
  if CommandLevel('tpmark') then
    local ped    = PlayerPedId()
    local blip   = GetFirstBlipInfoId(8) -- Retrieve GPS marker
    local coords = nil
    if DoesBlipExist(blip) then coords = GetBlipInfoIdCoord(blip)
    else print("DEBUG - Blip does not exist.") end
    
    if not coords then
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"No Marker Set", "/tpmark requires a map marker to be set"}
      })
    
    else
      local coord = vector3(coords.x, coords.y, 1.05)
      TriggerServerEvent('cnr:admin_cmd_teleport', 0, 0, coord)
      
    end
  else CommandInvalid('tpmark')
  end
end)


RegisterCommand('tpcoords', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
  
    --      x           y           z
    if not a[1] or not a[2] then
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"Invalid Arguments", "/"..cmd.." <x> <y> <z(optional)>"}
      })
    
    else
      if not a[3] then a[3] = 1.05 end
      TriggerServerEvent('cnr:admin_cmd_teleport', nil, nil,
        vector3(tonumber(a[1]), tonumber(a[2]), tonumber(a[3]))
      )
      
    end
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('tpback', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
  
    if not a[1] then
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"Invalid Arguments", "/"..cmd.." <ID#>"}
      })
    
    else
    
      TriggerServerEvent('cnr:admin_cmd_tp_sendback', tonumber(a[1]))
      
    end
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('announce', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
    if not a[1] then 
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"Invalid Arguments", "/"..cmd.." <x> <y> <z>"}
      })
    else
      TriggerServerEvent('cnr:admin_cmd_announce', table.concat(a, " "))
    end
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('mole', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
    if not a[1] then 
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"Invalid Arguments", "/"..cmd.." <x> <y> <z>"}
      })
    else
      TriggerServerEvent('cnr:admin_cmd_mole', table.concat(a, " "))
    end
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('asay', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
    if not a[1] then 
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"Invalid Arguments", "/"..cmd.." <message>"}
      })
    else
      TriggerServerEvent('cnr:admin_cmd_asay', table.concat(a, " "))
    end
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('csay', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
    if not a[1] then 
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"Invalid Arguments", "/"..cmd.." <message>"}
      })
    else
      TriggerServerEvent('cnr:admin_cmd_csay', table.concat(a, " "))
    end
  else CommandInvalid(cmd)
  end
end)

RegisterCommand('plyinfo', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
    if not a[1] then 
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"Invalid Arguments", "/"..cmd.." <message>"}
      })
    else
      TriggerServerEvent('cnr:admin_cmd_plyinfo', table.concat(a, " "))
    end
  else CommandInvalid(cmd)
  end
end)
RegisterCommand('vehinfo', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
    if not a[1] then 
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"Invalid Arguments", "/"..cmd.." <message>"}
      })
    else
      TriggerServerEvent('cnr:admin_cmd_vehinfo', table.concat(a, " "))
    end
  else CommandInvalid(cmd)
  end
end)
RegisterCommand('svinfo', function()
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
    if not a[1] then 
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"Invalid Arguments", "/"..cmd.." <message>"}
      })
    else
      TriggerServerEvent('cnr:admin_cmd_svinfo', table.concat(a, " "))
    end
  else CommandInvalid(cmd)
  end
end)

RegisterCommand('spawncar', function(s,a,r)
  local sp  = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
    if not a[1] then 
      TriggerEvent('chat:addMessage', {
        templateId = 'errMsg', multiline = true,
          args = {"Invalid Arguments", "/"..cmd.." <model>"}
      })
    else TriggerServerEvent('cnr:admin_cmd_spawncar', a[1])
    end
  else CommandInvalid(cmd)
  end
end)

RegisterCommand('delveh', function()
  if aLevel > 1 then
    local veh = GetVehiclePedIsIn(PlayerPedId())
    if veh > 0 then TriggerServerEvent('cnr:admin_cmd_delveh')
    else
      TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
        args = { "You must be sitting in the vehicle you want to delete." }
      })
    end
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('togglelock', function(s,a,r)
  local sp = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
  
    local cVeh, cDist, myPed = 0, math.huge, PlayerPedId()
    for vehs in exports['cnrobbers']:EnumerateVehicles() do 
      local dist = #(GetEntityCoords(vehs) - GetEntityCoords(myPed))
      if dist < cDist then cVeh = vehs; cDist = dist end
    end
  
    if cVeh < 1 or cDist > 8.25 then 
      TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
          args = {"Too far away from the nearest vehicle to toggle it's lock."}
      })
    else TriggerServerEvent('cnr:admin_cmd_togglelock', cVeh)
    end
  else CommandInvalid(cmd)
  end
end)


RegisterCommand('giveweapon', function(s,a,r)
  local sp = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
  
    if not a[1] or not a[2] or not a[3] then 
      TriggerEvent('chat:addMessage', {templateId = 'errMsg',
          args = {"Invalid Arguments", "/"..cmd.." <ID#> <weapon> <ammo>"}
      })
    else TriggerServerEvent('cnr:admin_cmd_giveweapon', a[1], a[2], a[3])
    end
    
  else CommandInvalid(cmd)
  end
end)
RegisterCommand('takeweapon', function(s,a,r)
  local sp = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
  
    if not a[1] or not a[2] or not a[3] then 
      TriggerEvent('chat:addMessage', {templateId = 'errMsg',
          args = {"Invalid Arguments", "/"..cmd.." <ID#> <weapon> <ammo(optional)>"}
      })
    else TriggerServerEvent('cnr:admin_cmd_takeweapon', a[1], a[2], a[3])
    end
    
  else CommandInvalid(cmd)
  end
end)
RegisterCommand('stripweapons', function(s,a,r)
  local sp = string.find(r, ' ')
  if sp then sp = sp - 1 end
  local cmd = string.sub(r, 1, sp)
  if CommandValid(cmd) then
  
    if not a[1] then 
      TriggerEvent('chat:addMessage', {templateId = 'errMsg',
          args = {"Invalid Arguments", "/"..cmd.." <ID#>"}
      })
    else TriggerServerEvent('cnr:admin_cmd_stripweapons', a[1])
    end
    
  else CommandInvalid(cmd)
  end
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

AddEventHandler('cnr:admin_do_spawncar', function(vModel)
  
  -- Only allow if the event comes from the server, not the client
  if source == "" then
    print("^1CNR ERROR: ^7Unable to authorize the teleport request.")
    return 0
  end
  
  local mdl = GetHashKey(vModel)
  if IsModelValid(mdl) then
    RequestModel(mdl)
    while not HasModelLoaded(mdl) do Wait(10) end
    TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
      args = { "Spawning: "..vModel }
    })
    local myPos = GetEntityCoords(PlayerPedId())
    local myHeading = GetEntityHeading(PlayerPedId())
    local veh = CreateVehicle(mdl,
      myPos.x, myPos.y, myPos.z + 0.125, myHeading, true, false
    )
    
    while not DoesEntityExist(veh) do Wait(10) end
    Citizen.Wait(100)
    --TaskEnterVehicle(PlayerPedId(), veh, 10000, (-1), 8.0, 16, 1)
    SetVehicleEngineOn(veh, true, true, true)
    SetVehicleDoorsLocked(veh, 1)
    SetPedIntoVehicle(PlayerPedId(), veh, (-1))
    
  else
    TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
      args = { "Couldn't find Vehicle Model: "..vModel }
    })
    
  end
  
  
  
  
  
  
end)


AddEventHandler('cnr:admin_do_delveh', function(toPlayer, coords, aid)
  
  -- Only allow if the event comes from the server, not the client
  if source == "" then
    print("^1CNR ERROR: ^7Unable to authorize the vehicle deletion.")
    return 0
  end
  
  local veh = GetVehiclePedIsIn(PlayerPedId())
  if veh > 0 then 
    TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
      args = { "Deleted occupied vehicle." }
    })
    SetEntityAsMissionEntity(veh, true, true)
    DeleteVehicle(veh)
  end
  
end)


AddEventHandler('cnr:admin_do_giveweapon', function(aid, wHash, wAmmo)
  
  -- Only allow if the event comes from the server, not the client
  if source == "" then
    print("^1CNR ERROR: ^7Unable to authorize the vehicle deletion.")
    return 0
  end
  
  if not wAmmo then wAmmo = 1000 end
  TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
    args = {"Admin #"..aid.." gave you "..wHash..". It will NOT save when you log off."}
  })
  GiveWeaponToPed(PlayerPedId(), GetHashKey(wHash), wAmmo, false, false)
  
end)


AddEventHandler('cnr:admin_do_togglelock', function(veh)

  -- Only allow if the event comes from the server, not the client
  if source == "" then
    print("^1CNR ERROR: ^7Unable to authorize the vehicle deletion.")
    return 0
  end
  
  if veh then 
    if veh > 0 then 
      if DoesEntityExist(veh) then 
        local lockStatus = GetVehicleDoorLockStatus(veh)
        if lockStatus > 1 then 
          TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
            args = {GetDisplayNameFromVehicleModel(GetEntityModel(veh)).." ^2unlocked^7."}
          })
          SetVehicleDoorsLocked(veh, 1)
          Citizen.CreateThread(function()
            local sec = GetGameTimer() + 100
            while sec > GetGameTimer() do 
              SoundVehicleHornThisFrame(veh); Wait(0)
            end
            Citizen.Wait(100)
            sec = GetGameTimer() + 100
            while sec > GetGameTimer() do 
              SoundVehicleHornThisFrame(veh); Wait(0)
            end
          end)
        else
          TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
            args = {GetDisplayNameFromVehicleModel(GetEntityModel(veh)).." ^1locked^7."}
          })
          SetVehicleDoorsLocked(veh, 2)
          Citizen.CreateThread(function()
            local sec = GetGameTimer() + 100
            while sec > GetGameTimer() do 
              SoundVehicleHornThisFrame(veh); Wait(0)
            end
          end)
        end
      else
        TriggerEvent('chat:addMessage', {templateId = 'errMsg',
          args = {"TOGGLELOCK", "Vehicle ID didn't return a Vehicle Entity"}
        })
      end
    end
  end
  
end)


local function FindZCoord(coord)
  local zFound, zCoord = GetGroundZFor_3dCoord(coord.x, coord.y, coord.z)
  local ht = 1000.0
  while not zFound do
    Wait(10)
    ht = ht - 10.0
    SetEntityCoords(PlayerPedId(), coord.x, coord.y, ht)
    zFound, zCoord = GetGroundZFor_3dCoord(coord.x, coord.y, ht)
    if ht < 1.5 then break end
  end
  if zFound then return zCoord end
  return 0.0
end

AddEventHandler('cnr:admin_tp_coords', function(toPlayer, coords, aid)
  
  -- Only allow if the event comes from the server, not the client
  if source == "" then
    print("^1CNR ERROR: ^7Unable to authorize the teleport request.")
    return 0
  end
  
  if coords then
    local lastPosition = GetEntityCoords(PlayerPedId())
    local zCoord = coords.z
    if zCoord == 1.05 then zCoord = FindZCoord(coords) end
    if zCoord > 0.0 then 
      SetEntityCoords(PlayerPedId(), coords.x, coords.y, zCoord)
    else
      SetEntityCoords(PlayerPedId(), lastPosition)
      TriggerEvent('cnr:chatMessage', {templateId = 'sysMsg',
        args = {"Teleport destination was unsafe for arrival. Returned."}
      })
    end
    FreezeEntityPosition(PlayerPedId(), true)
    Citizen.Wait(3000)
    FreezeEntityPosition(PlayerPedId(), false)
  
  else
    local pedPos = GetEntityCoords(GetPlayerPed(GetPlayerFromServerId(toPlayer)))
    SetEntityCoords(PlayerPedId(), pedPos.x, pedPos.y, pedPos.z)
    FreezeEntityPosition(PlayerPedId(), true)
    Citizen.Wait(3000)
    FreezeEntityPosition(PlayerPedId(), false)
  
  end
  
end)

AddEventHandler('cnr:admin_do_sendback', function(aid)
  
  -- Only allow if the event comes from the server, not the client
  if source == "" then
    print("^1CNR ERROR: ^7Unable to authorize the teleport request.")
    return 0
  end
  
  if lastPosition then 
    SetEntityCoords(PlayerPedId(), lastPosition)
    TriggerEvent('cnr:chatMessage', {templateId = 'sysMsg',
      args = {"Admin #"..aid.." sent you back to your previous position."}
    })
  end
end)
