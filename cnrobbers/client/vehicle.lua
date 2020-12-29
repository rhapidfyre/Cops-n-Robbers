
RegisterNetEvent('cnr:wanted_enter_vehicle')  -- Player entered illegal veh
RegisterNetEvent('cnr:wanted_check_vehicle')  -- Checks if player has rt to veh

local usingVehicle      = nil -- The vehicle client is using (driving)
local isEnteringVehicle = nil -- The vehicle client is entering


local function NeverLocked(veh)
  local neverLock = {[8] = true, [9] = true, [13] = true, [14] = true}
  if not DoesEntityExist(veh) then 
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    if not DoesEntityExist(veh) then
     veh = GetVehiclePedIsTryingToEnter(ped))
    end
  end
  if DoesEntityExist(veh) then
    local vehClass = GetVehicleClass(veh)
    if neverLock[vehClass] then return true end
  end
  return false
end


local function AlwaysLocked(veh)
  local alwaysLock = {
    [GetHashKey("HYDRA")] = true, [GetHashKey("RHINO")] = true, [GetHashKey("LAZER")] = true,
    [GetHashKey("INSURGENT")] = true, [GetHashKey("BUZZARD")] = true,
    [GetHashKey("ANNIHILATOR")] = true
  }
  if not DoesEntityExist(veh) then 
    local ped = PlayerPedId()
    local veh = GetVehiclePedIsIn(ped)
    if not DoesEntityExist(veh) then
     veh = GetVehiclePedIsTryingToEnter(ped))
    end
  end
  if DoesEntityExist(veh) then
    if alwaysLock[GetEntityModel(veh)] then return true end
  end
  return false
end


function GetVehicleSeat()
  local ped = PlayerPedId()
  local vehicle = GetVehiclePedIsIn(ped, false)
  for i = -2, GetVehicleMaxNumberOfPassengers(vehicle) do
    if(GetPedInVehicleSeat(vehicle, i) == ped) then return i end
  end
  return (-2)
end


-- CreateThread()
-- Bastardized version of the baseevents vehiclechecker.lua
-- Sends a Vehicle Network ID instead of the vehicle entity ID
Citizen.CreateThread(function()
	while not CNR.ready do Wait(1000) end
	while true do

		Citizen.Wait(10)
    local pid = PlayerId()
    local ped = PlayerPedId()
    
		-- Script thinks player is on foot and the player isn't dead
		if not inVehicle and not IsPlayerDead(pid) then
			
			-- Trying to enter a vehicle
			if DoesEntityExist(GetVehiclePedIsTryingToEnter(ped)) and not enteringVehicle then
			
				enteringVehicle = GetVehiclePedIsTryingToEnter(ped)
        local seat      = GetSeatPedIsTryingToEnter(ped)
        local driver    = GetPedInVehicleSeat(enteringVehicle, (-1))
        local isPlayer  = false
        
        if DoesEntityExist(driver) then
          if IsEntityAPed(driver) then
            if IsPedAPlayer(driver) then isPlayer = true end
          end
        end
        
				TriggerServerEvent('cnr:entering_vehicle',
          NetworkGetNetworkIdFromEntity(enteringVehicle),
          seat, driver, isPlayer
        )
				TriggerEvent('cnr:entering_vehicle', enteringVehicle,
          seat, driver, isPlayer
        )
        
        -- Unlock the vehicle if it's a bike, boat, etc
        if NeverLocked(enteringVehicle) then
          SetVehicleDoorsLocked(enteringVehicle, 0)
          
        -- Lock the vehicle if it's an always-locked vehicle (military, etc)
        elseif AlwaysLocked(enteringVehicle) then
          SetVehicleDoorsLocked(enteringVehicle, 2)
        end
        
			-- No longer trying to enter the vehicle
			elseif not DoesEntityExist(GetVehiclePedIsTryingToEnter(ped))
         and not IsPedInAnyVehicle(ped, true)
         and enteringVehicle
        then
          TriggerServerEvent('cnr:entering_abort')
          TriggerEvent('cnr:entering_abort')
          enteringVehicle = nil
          inVehicle       = nil
          inSeat          = nil
          usingvehicle    = nil
				
			-- Player suddenly appeared in the vehicle
			elseif IsPedInAnyVehicle(ped) then
      
				enteringVehicle = nil
        inVehicle    = GetVehiclePedIsIn(ped)
        inSeat       = GetVehicleSeat()
        local model  = GetEntityModel(inVehicle)
        if inSeat < 0 then usingVehicle = inVehicle end
				TriggerServerEvent('cnr:in_vehicle', NetworkGetNetworkIdFromEntity(inVehicle), inSeat)
				TriggerEvent('cnr:in_vehicle', inVehicle, inSeat)
        
        -- Disable Plane/Helicopter Turbulance
        if IsThisModelAPlane(model) then
          SetPlaneTurbulenceMultiplier(inVehicle, 0.0)
        elseif IsThisModelAHeli(model) then
          SetHeliTurbulenceScalar(inVehicle, 0.0)
        end
				
			end
			
		-- Script thinks player is in the car - Are they?
		elseif inVehicle then
			
			-- If ped is not in a car but the script thinks they are, OR if they died in the car
			if not IsPedInAnyVehicle(ped) or IsPlayerDead(pid) then
				TriggerServerEvent('cnr:exit_vehicle', NetworkGetNetworkIdFromEntity(inVehicle))
				TriggerEvent('cnr:exit_vehicle', inVehicle, currentSeat)
        
        -- Reset Variables
				enteringVehicle = nil
				inVehicle       = nil
				inSeat          = nil
        usingvehicle    = nil
			end
      
		end
    
	end
end)


--- EXPORT: HasRightsToVehicle
-- Checks if local player has a right to the vehicle
-- @param veh The local vehicle ID
-- @return True if the vehicle has a right to use this vehicle; False if not
function HasRightsToVehicle(veh)
  if DoesEntityExist(veh) then
    if IsEntityAVehicle(veh) then
      
      -- Vehicle is an emergency vehicle
      if GetVehicleClass(veh) == 18 or eVehicle[GetEntityModel(veh)] then
        if DutyStatus() then return true
        end
        
      -- Vehicle is *NOT* an emergency vehicle
      else
        if DecorExistOn(veh, "idOwner") then
          if DecorGetInt(veh, "idOwner") == UniqueId() then
            return true
          end
        end
      end
      
    end
  end
  return false
end


AddEventHandler('cnr:wanted_check_vehicle', function(veh)
  local hasRight = HasRightsToVehicle(veh)
  if not hasRight then
    if IsEntityAVehicle(veh) then
      local lockStatus = GetVehicleDoorLockStatus(veh)
      local driver     = GetPedInVehicleSeat(veh, (-1))
      -- Breaking into a car is only a crime if it's locked
      if lockStatus ~= 0 and lockStatus ~= 1 then
        if driver > 0 then crimeCar.d = driver end
        crimeCar.v = veh
      -- Or if the vehicle is being driven
      elseif driver > 0 then
        crimeCar.d = driver
        crimeCar.v = veh
      end
    end
  end
end)


AddEventHandler('cnr:wanted_enter_vehicle', function(veh)
  if crimeCar.v then
    if veh == crimeCar.v then
      -- Occupied: Carjacking (more serious crime)
      local myPos = GetEntityCoords(PlayerPedId())
      if crimeCar.d then
        if IsPedAPlayer(crimeCar.d) then
          TriggerServerEvent('cnr:crime', 'carjack', true,
            GetFullZoneName(GetNameOfZone(myPos)),
            myPos
          )
        else
          TriggerServerEvent('cnr:crime', 'carjack-npc', true,
            GetFullZoneName(GetNameOfZone(myPos)),
            myPos, true -- ignore 911
          )
        end
      -- Unoccupied: GTA
      else
        -- DEBUG - Add check later to see if vehicle is owned
        TriggerServerEvent('cnr:crime', 'gta-npc', true,
          GetFullZoneName(GetNameOfZone(myPos)),
          myPos
        )
      end
      crimeCar = {}
    end
  end
end)