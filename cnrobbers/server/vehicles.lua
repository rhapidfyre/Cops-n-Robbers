
RegisterServerEvent('cnr:entering_vehicle')
RegisterServerEvent('cnr:entering_abort')
RegisterServerEvent('cnr:in_vehicle')
RegisterServerEvent('cnr:exit_vehicle')


local carJack = {}

-- Attempting to enter a vehicle
AddEventHandler('cnr:entering_vehicle', function(veh, seat, driver, isPlayer)
  local ply = source
  local netVeh = veh
  print("DEBUG - "..GetPlayerName(ply).." (ID "..ply..
    ") ^3is entering ^7Vehicle #"..carUse[ply]..
    " (Exists: "..tostring(DoesEntityExist(netVeh))..")"
  )
  if driver > 0 then
    if isPlayer then
      print("DEBUG - ^3Player is about to carjack someone!^7")
      carJack[ply] = 1
    else
      print("DEBUG - ^1Player is about to carjack an NPC!!^7")
      carJack[ply] = 2
    end
  end
  TriggerClientEvent('cnr:wanted_check_vehicle', ply, veh)
end)


-- Gave up trying to enter a vehicle for whatever reason
AddEventHandler('cnr:entering_abort', function(veh, seat)
  local ply = source
  local netVeh = veh
  carJack[ply] = false
  print("DEBUG - "..GetPlayerName(ply).." (ID "..ply..
    ") ^1stopped ^7entering Vehicle #"..carUse[ply]..
    " (Exists: "..tostring(DoesEntityExist(netVeh))..")"
  )
end)


-- Entered a vehicle (either legitimately or illegitimately/teleport)
AddEventHandler('cnr:in_vehicle', function(veh, seat)
  local ply = source
  local netVeh = veh
  print("DEBUG - "..GetPlayerName(ply).." (ID "..ply..
    ") ^2has entered ^7Vehicle #"..carUse[ply]..
    " (Exists: "..tostring(DoesEntityExist(netVeh))..")"
  )
  -- Is Vehicle Owner
  -- Is Not Vehicle Owner
    -- Check for Carjacking
  if carJack[ply] then
    if carJack[ply] == 2 then
      print("DEBUG - ^3Player has carjacked another player!^7")
    else
      print("DEBUG - ^1Player has carjacked an NPC!^7")
    end
  end
  carJack[ply] = false
end)


AddEventHandler('cnr:exit_vehicle', function(veh, seat)
  local ply = source
  local netVeh = veh
  print("DEBUG - "..GetPlayerName(ply).." (ID "..ply..
    ") exited Vehicle #"..carUse[ply]..
    " (Exists: "..tostring(DoesEntityExist(netVeh))..")"
  )
  carJack[ply] = false
end)

