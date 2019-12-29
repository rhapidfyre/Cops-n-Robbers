
-- DEBUG - Lock Status
local lockLv = {
  [0] = "None/Unknown",
  [1] = "Unlocked",
  [2] = "Locked (No Break-in)",
  [3] = "Locked for Player",
  [4] = "Stuck Inside",
  [7] = "Locked (Break-in OK)",
  [8] = "Breakable (persist)",
  [10] = "Ignore Attempt to Enter"
}

-- client vehicles
local thisVehicle = 0
local thisDriver  = 0
local wbreakers   = 1
local lockChecked = {}

RegisterCommand('vehmodel', function()
  TriggerEvent('chatMessage', "^3DEBUG - [^7"..GetEntityModel(GetVehiclePedIsIn(PlayerPedId())).."^3]")
end)

local function VehicleHint(msg)
  ClearPrints()
  SetTextEntry_2("STRING")
  AddTextComponentString(msg)
  DrawSubtitleTimed(101, 1)
end

--- DoParkedVehicleLock()
-- Locks the vehicle if it's unoccupied and
function DoParkedVehicleLock(veh)

  -- Vehicle is a player's vehicle, forget it.
  if DecorExistOn(veh, "OwnerId") then lockChecked[veh] = true; return 0 end

  -- If the door is open then ignore lock check; It's open
  local maxDoors = GetNumberOfVehicleDoors(veh) - 1
  local doorOpen = (-1)
  for i = 0, maxDoors do
    if GetVehicleDoorAngleRatio(veh, i) > 0.0 then doorOpen = i end
  end
  if doorOpen >= 0 then lockChecked[veh] = true; return 0 end

  -- If the window is smashed, it shall be considered unlocked
  if not IsVehicleWindowIntact(veh, 1) or not IsVehicleWindowIntact(veh, 0) then
    SetVehicleDoorsLocked(veh, 0)
    lockChecked[veh] = true
    return 0
  end

  -- Is the vehicle unoccupied?
  local maxPassengers = GetVehicleMaxNumberOfPassengers(veh)
  local occupied = false
  for i = (-1), (maxPassengers - 1) do
    if not IsVehicleSeatFree(veh, i) then occupied = true end
  end

  if not occupied then
    if GetVehicleDoorLockStatus(veh) > 0 then

      -- Checks if this vehicle should always be found locked (config file)
      if AlwaysLocked(GetEntityModel(veh)) then SetVehicleDoorsLocked(veh, 2)

      -- Otherwise give it a random lock chance
      else

        if math.random(1, 1000) > 180 then  SetVehicleDoorsLocked(veh, 2)
        else                                SetVehicleDoorsLocked(veh, 0)
        end

      end
    else SetVehicleDoorsLocked(veh, 2)
    end

  -- Vehicle is occupied
  else
    SetVehicleDoorsLocked(veh, 2)

    -- Check 3 seconds later - If vehicle still locked, drive off in a panic
    Citizen.CreateThread(function()
      Citizen.Wait(3000)
      if GetVehicleDoorLockStatus(veh) > 1 then
        local ped = GetPedInVehicleSeat(veh, (-1))
        SetPedFleeAttributes(ped, 1, true)
        --SetDriverAbility(ped, 1.0)
        SetDriverAggressiveness(ped, 1.0)
        TaskVehicleDriveWander(ped, veh, 100.0, 786944)

        -- Contact Police
        local myPos = GetEntityCoords(PlayerPedId())
        TriggerServerEvent('cnr:wanted_points', '664-carjack', true,
          exports['cnrobbers']:GetFullZoneName(GetNameOfZone(myPos)),
          myPos
        )

      end
    end)
  end

  lockChecked[veh] = true
end

Citizen.CreateThread(function()
  while true do

    thisVehicle = GetVehiclePedIsIn(PlayerPedId())

    -- Things to do if the player is in a vehicle
    if thisVehicle > 0 then
      thisDriver = GetPedInVehicleSeat(thisVehicle, (-1))

    -- Things to do if the player is NOT in a vehicle
    else

      local entering = GetVehiclePedIsTryingToEnter(PlayerPedId())
      if entering > 0 then

        -- Check lock chance if not already checked
        if not lockChecked[entering] then DoParkedVehicleLock(entering) end

        local lockStatus = GetVehicleDoorLockStatus(entering)
        if lockStatus > 1 and lockStatus < 7 then
          VehicleHint("(~g~E~w~): USE WINDOW BREAKER")
          if IsControlJustPressed(0, 38) then
            if wbreakers > 0 then
              SetVehicleDoorsLocked(entering, 7)
              wbreakers = wbreakers - 1
              TriggerServerEvent('cnr:inventory_use', 'item_window_breaker', 1)

            else
              TriggerEvent('chat:addMessage', {templateId = 'errMsg',
                multiline = true, args = {
                  "Not enough supplies",
                  "You have no Window Breakers to use. Visit a 24/7."
                }
              })

            end
          end
        end -- lockStatus
      end -- entering
    end -- thisVehicle
    Citizen.Wait(0)
  end
end)

