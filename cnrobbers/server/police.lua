
RegisterServerEvent('cnr:police_status')
RegisterServerEvent('cnr:police_dispatch')
RegisterServerEvent('cnr:police_dispatch_report')
RegisterServerEvent('cnr:police_backup')
RegisterServerEvent('cnr:client_loaded')

local droppedCops = {}


function CountCops()
  local n = 0
  for k,v in pairs (CNR.police) do
    if v then n = n + 1 end
  end
  return n
end


-- Attempt to recover cops who crashed
AddEventHandler('playerDropped', function()
  local ply = source
  local uid = UniqueId(ply)
  if CNR.police[ply] then
    droppedCops[uid] = {
      t = (os.time() + 600), -- Save for 10 minutes
      a = st
    }
  end
end)


AddEventHandler('cnr:client_loaded', function()
  local ply = source
  local uid = UniqueId(ply)
  if droppedCops[uid] then 
    -- Recover duty status
    print("DEBUG - Player #"..ply.."'s duty status was remembered. Restoring!")
    PoliceStatus(client, true, droppedCops[uid].a, true)
  end
end)


function RememberCops()
  for uid,dropTime in pairs (droppedCops) do 
    if os.time() > dropTime then 
      ConsolePrint("Reconnection time for dropped cop UID #"..uid.." has expired.")
      droppedCops[uid] = nil
    end
  end
end


function PoliceStatus(client, onDuty, station, ignoreCam)
  if not IsWanted(client) then
    local st = GetPoliceStation(station)
    if onDuty then
      CNR.police[client] = st
      DiscordFeed(2067276, GetPlayerName(ply).." is now on Law Enforcement duty",
        "There are now "..CountCops().." cops on duty.", ""
      )
      ConsolePrint(GetPlayerName(client).." ("..client..") went ^5on duty ^7@ "..(st.title).."!")
    else
      CNR.police[client] = nil
      DiscordFeed(2067276, GetPlayerName(ply).." is no longer a cop",
        "There are now "..CountCops().." cops on duty.", ""
      )
      ConsolePrint(GetPlayerName(client).." ("..client..") went ^1off duty ^7@ "..(st.title).."!")
    end
    TriggerClientEvent('cnr:police_duty', (-1),
      GetPlayerName(client), client, onDuty, station, ignoreCam
    )
  else 
    TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg', args = {
      "^1Lose your wanted level ^7before trying to go on Police Duty!"
    }})
  end
end
AddEventHandler('cnr:police_status', function(onDuty, station, ignoreCam)
  PoliceStatus(source, onDuty, station, ignoreCam)
end)


function DispatchPolice(title, position, message)
  if not message then message = "A(n) "..title.." was reported" end
  ConsolePrint("^6Dispatch: "..title.." ("..tostring(position)..")")
  TriggerClientEvent('cnr:dispatch', (-1), title, position, message)
  DiscordFeed(
    35578, "CRIME REPORTED", message, title, 1
  )
end
AddEventHandler('cnr:police_dispatch', DispatchPolice)
AddEventHandler('cnr:police_dispatch_report',DispatchPolice)


-- Receives info for a 911 call, and then changes the blips
function RequestBackup(title, msg, areaName)
  local client  = source
  local posn    = GetEntityCoords(GetPlayerPed(client))
  local officer = "Officer "..GetPlayerName(client)
  TriggerClientEvent('cnr:dispatch', (-1), title, officer.." "..msg, areaName, posn)
  TriggerClientEvent('cnr:police_blip_backup', (-1), posn)
end
AddEventHandler('cnr:police_backup', RequestBackup)

