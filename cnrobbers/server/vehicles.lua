
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
  local ply = source
  local netVeh = NetworkGetEntityFromNetworkId(veh)
  print("DEBUG - "..GetPlayerName(ply).." (ID "..ply..
    ") ^2has entered ^7Vehicle #"..netVeh.."|"..veh..
    " (Exists: "..tostring(DoesEntityExist(netVeh))..")"
  )
  -- Is Vehicle Owner
  -- Is Not Vehicle Owner
    -- Check for Carjacking
  if carJack[ply] then
    if carJack[ply] == 2 then
      WantedPoints(ply, 'carjack', "Carjacking")
      print("DEBUG - ^3Player has carjacked another player!^7")
      
    else
      WantedPoints(ply, 'carjack-npc', "Carjacking (NPC)")
      print("DEBUG - ^1Player has carjacked an NPC!^7")
    end
  end
  carJack[ply] = false
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

