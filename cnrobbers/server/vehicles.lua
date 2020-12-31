
RegisterServerEvent('cnr:entering_vehicle')
RegisterServerEvent('cnr:entering_abort')
RegisterServerEvent('cnr:in_vehicle')
RegisterServerEvent('cnr:exit_vehicle')


local carJack = {}

RegisterCommand('vehinfo', function(src)
	local ply = src
	local ped = GetPlayerPed(ply)
	local veh = GetVehiclePedIsIn(ped)
	print(veh, NetworkGetNetworkIdFromEntity(veh))
end)

-- Attempting to enter a vehicle
AddEventHandler('cnr:entering_vehicle', function(veh, seat, driver, isPlayer)
  local ply = source
  local netVeh = NetworkGetEntityFromNetworkId(veh)
  print("DEBUG - "..GetPlayerName(ply).." (ID "..ply..
    ") ^3is entering ^7Vehicle #"..netVeh.."|"..veh..
    " (Exists: "..tostring(DoesEntityExist(netVeh))..")"
  )
  if driver > 0 then
    if isPlayer then
      print("DEBUG - ^3Player is about to carjack someone!^7")
      carJack[ply] = 2
    else
      print("DEBUG - ^1Player is about to carjack an NPC!!^7")
      carJack[ply] = 1
    end
  end
  TriggerClientEvent('cnr:wanted_check_vehicle', ply, veh)
end)


-- Gave up trying to enter a vehicle for whatever reason
AddEventHandler('cnr:entering_abort', function(veh, seat)
  local ply = source
  local netVeh = NetworkGetEntityFromNetworkId(veh)
  carJack[ply] = false
  print("DEBUG - "..GetPlayerName(ply).." (ID "..ply..
    ") ^1stopped ^7entering Vehicle #"..netVeh.."|"..veh..
    " (Exists: "..tostring(DoesEntityExist(netVeh))..")"
  )
end)


-- Entered a vehicle (either legitimately or illegitimately/teleport)
AddEventHandler('cnr:in_vehicle', function(veh, seat)
  local client = source
  local netVeh = NetworkGetEntityFromNetworkId(veh)
  print("DEBUG - "..GetPlayerName(client).." (ID "..client..
    ") ^2has entered ^7Vehicle #"..netVeh.."|"..veh..
    " (Exists: "..tostring(DoesEntityExist(netVeh))..")"
  )
  -- Is Vehicle Owner
  -- Is Not Vehicle Owner
    -- Check for Carjacking
  if carJack[client] then
    if carJack[client] == 2 then
      ReportCrime(client, 'carjack')
    else
      ReportCrime(client, 'carjack-npc')
    end
  end
  carJack[client] = false
end)


AddEventHandler('cnr:exit_vehicle', function(veh, seat)
  local ply = source
  local netVeh = NetworkGetEntityFromNetworkId(veh)
  print("DEBUG - "..GetPlayerName(ply).." (ID "..ply..
    ") exited Vehicle #"..netVeh.."|"..veh..
    " (Exists: "..tostring(DoesEntityExist(netVeh))..")"
  )
  carJack[ply] = false
end)

