

RegisterServerEvent('cnr:police_dispatch')
RegisterServerEvent('cnr:police_dispatch_report')
RegisterServerEvent('cnr:police_backup')
RegisterServerEvent('cnr:police_status')
RegisterServerEvent('cnr:client_loaded')
RegisterServerEvent('cnr:police_stations_req') -- Client requests stations info


local cops      = {}
local dropCop   = {}

local function CopRankFormula()
  return (((n * (n + 1)) / 2) * 100)
end

function CountCops()
  local n = 0
  for k,v in pairs(cops) do
    if v then n = n + 1 end
  end
  return n
end


function DispatchPolice(title, zName, position, message)
  if not zName then zName = "San Andreas" end
  if not message then message = "A(n) "..title.." was reported in "..zName end
  print("DEBUG - Calling Dispatch for: "..title.." in "..zName.." @ "..tostring(position))
  TriggerClientEvent('cnr:dispatch', (-1), title, zName, position, message)
  exports['cnr_chat']:DiscordMessage(
    35578, "Crime Reported", message, title, 1
  )
end
AddEventHandler('cnr:police_dispatch', function(title, zName, position)
  DispatchPolice(title, zName, position)
end)
AddEventHandler('cnr:police_dispatch_report', function(title, zName, position, message)
  DispatchPolice(title, zName, position, message)
end)

-- Sends parking updates (police garage)
RegisterServerEvent('cnr:police_setparking')
AddEventHandler('cnr:police_setparking', function(nStation, nPos, isOccupied)
  if isOccupied then isOccupied = source end
  TriggerClientEvent('cnr:police_parking', (-1), nStation, nPos, isOccupied)
end)

AddEventHandler('cnr:police_status', function(agency, onDuty)

  local ply = source

  local numCops = CountCops()
  
  if onDuty then
    local uid = exports['cnrobbers']:UniqueId(ply)
    exports['ghmattimysql']:scalar(
      "SELECT cop FROM players WHERE idUnique = @uid",
      {['uid'] = uid},
      function(cLevel)
        if not cLevel then cLevel = 1 end
        cops[ply] = cLevel
        exports['cnr_chat']:DiscordMessage(2067276,
          GetPlayerName(ply).." is now on Law Enforcement duty",
          "There is now "..CountCops().." cop(s) on duty.", ""
        )
        local copRank = cLevel
        while (cLevel > rankFormula(copRank)) do 
          copRank = copRank + 1
          Citizen.Wait(1)
        end
        TriggerClientEvent('cnr:police_officer_duty', (-1), ply, onDuty, copRank)
      end
    )
  else
    cops[ply] = nil
    exports['cnr_chat']:DiscordMessage(10038562,
      GetPlayerName(ply).." is no longer a cop",
      "There is now "..CountCops().." cop(s) on duty.", ""
    )
    TriggerClientEvent('cnr:police_officer_duty', (-1), ply, nil, 0)
  end

  local dt      = os.date("%H:%M", os.time())

  if numCops < 1 then
    print("[CNR "..dt.."] There are no cops on duty.")
  elseif numCops == 1 then
    print("[CNR "..dt.."] There is now 1 cop on duty.")
  else
    print("[CNR "..dt.."] There are now "..numCops.." cops on duty.")
  end

end)


--- EXPORT: DutyStatus()
-- Like the client function, tells calling script if player is on police duty.
-- However, unlike the client function, must be given Server ID of player to check.
-- @param ply The player by server ID
-- @return True if on police duty, false or nil if not.
function DutyStatus(ply)
  if not ply then return nil end
  return cops[ply]
end


AddEventHandler('cnr:client_loaded', function()
  local ply = source
  local uid = exports['cnrobbers']:UniqueId(ply)
  for k,v in pairs(dropCop) do
    if v == uid then
      TriggerClientEvent('cnr:police_reduty', ply)
      TriggerClientEvent('chat:addMessage', {
        color     = {255,180,40},
        multiline = true,
        args      = {"SERVER", "You were on duty when you logged out. "..
                               "Your duty status has been restored."}
      })
    end
    Citizen.Wait(1)
  end
  -- Sends list of on duty cops to connecting player
  for k,v in pairs(cops) do
    TriggerClientEvent('cnr:police_officer_duty', ply, k, true, v)
  end
end)


-- Adds player to dropped cops table, so their duty status
-- can be returned if they come back within 10 minutes
AddEventHandler('playerDropped', function()
  local ply = source
  local uid = exports['cnrobbers']:UniqueId(ply)
  if cops[ply] then
    cops[ply] = nil
    dropCop[#dropCop + 1] = uid
    Citizen.CreateThread(function()
      Citizen.Wait(600000)
      for k,v in pairs (dropCop) do
        if v == uid then
          table.remove(dropCop, k)
          TriggerClientEvent('cnr:police_officer_duty', (-1), ply, nil, 0)  
          break
        end
      end
    end)
  end
end)


-- Receives info for a 911 call, and then changes the blips
function RequestBackup(em, title, msg, areaName, x, y, z)
  TriggerClientEvent('cnr:dispatch', (-1), title, msg, areaName, x,y,z)
  TriggerClientEvent('cnr:police_blip_backup', (-1), source)
end
AddEventHandler('cnr:police_backup', RequestBackup)

