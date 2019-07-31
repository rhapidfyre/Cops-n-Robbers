
--[[
  Cops and Robbers: Clans Script (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  07/22/2019
  
  Handles the ability for people to form, modify, and remove clans.
  
  This resource is an open license and free for anyone to modify or use
--]]

RegisterNetEvent('cnr:clans_receive') -- Receive clan listing
RegisterNetEvent('cnr:clans_members') -- Receive clan members of selected clan

Citizen.CreateThread(function()
  while true do 
  
    -- Close the menu if the player pauses or dies
    if menuEnabled then 
      if IsPauseMenuActive() or IsPedDeadOrDying(PlayerPedId()) then 
          SendNUIMessage({close = true})
          SetNuiFocus(false)
      end
    end
    
    -- DEBUG - Change to F2 later (trainer/lambda menu)
    if IsControlJustPressed(0, 20) then
      print("DEBUG - Pressed Z")
      if not IsPauseMenuActive() and not menuEnabled then
        print("DEBUG - Eligible.")
        if not IsPedDeadOrDying(PlayerPedId()) then 
          print("DEBUG - Not dying.")
          menuEnabled = true
          SetNuiFocus(true, true)
          SendNUIMessage({open = true, showload = true})
          TriggerServerEvent('cnr:clans_request')
          print("DEBUG - Ready.")
        end
      end
    end
    
    Citizen.Wait(10)
  end
end)

RegisterCommand('mouse', function() SetNuiFocus(false) end)
AddEventHandler('cnr:clans_receive', function(clanInfo)
  print("DEBUG - Received clan list from server.")
  local htmlTable = {}
  if clanInfo then
    for k,v in pairs(clanInfo) do
      local idClass = 'othclan'
      if     v.cop > v.civ + 10 then idClass = 'copclan'
      elseif v.civ > v.cop + 10 then idClass = 'civclan'
      end
      table.insert(htmlTable,
        '<tr class="'..(idClass)..'">'..
        '<td><button class="name" onclick="ViewRoster('..k..')">'..(v.tag)..'</button></td>'..
        '<td><button class="name" onclick="ViewRoster('..k..')">'..(v.name)..'</button></td>'..
        '<td>'..(v.cop + v.civ)..'</td></tr>'
      )
      print("DEBUG - Prepared HTML for clan: "..(v.name)..".")
    end
    SendNUIMessage({clans = table.concat(htmlTable)})
  end
  SendNUIMessage({hideload = true})
  print("DEBUG - Done.")
end)

AddEventHandler('cnr:clans_members', function(ldr, plys)
  if plys then 
    local htmlTable = {}
    print("DEBUG - Adding all other members.")
    local i = 1
    for k,v in pairs(plys) do
      local infoBuild = ''
      local leadText  = '<font color="#CCC">'
      if i % 2 ~= 0 then infoBuild = '<tr>' end
      if v["idUnique"] == ldr then leadText = '<font color="#FB0">(*) ' end
      infoBuild = infoBuild..'<td>'..
        '<button class="member" onclick="ViewMember('..(v["idUnique"])..')">'..
        leadText..(v["username"])..'</font></button>'..
        '</td><td>'..(v["cop"])..'</td><td>'..(v["civ"])..'</td>'
      if i % 2 == 0 then infoBuild = infoBuild..'</tr>' end
      print(infoBuild)
      table.insert(htmlTable, infoBuild)
      i = i + 1
    end
    Citizen.Wait(300)
    SendNUIMessage({hideload = true, roster = table.concat(htmlTable)})
  end
end)

RegisterNUICallback("clanMenu", function(data, cb)
  print("DEBUG - Received NUICallback 'clanMenu'")
  if data.action == "exit" then 
    SetNuiFocus(false)
    menuEnabled = false
  elseif data.action == "roster" then
    print("DEBUG - Show Roster for idClan ["..(data.clanNumber).."]")
    SendNUIMessage({showload = true})
    Citizen.Wait(300)
    TriggerServerEvent('cnr:clans_roster', tonumber(data.clanNumber))
  end
end)