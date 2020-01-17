
-- Client

local dTruck     		    = nil
local destBlip   		    = nil
local hasPackage 		    = false
local box		 		        = nil
local firstDest  		    = true
local isOnDeliveryDuty  = false 
local myJobPoint		    = 1
local drops             = {}

local jobStart = {
	[1] = {v = vector3(-3147.12, 1121.18, 20.86), h = 59.9,   veh = "boxville2"},
	[2] = {v = vector3(78.81, 111.89, 81.16),     h = 64.33,  veh = "boxville2"},
	[3] = {v = vector3(-421.2, 6136.79, 31.87),   h = 181.67, veh = "boxville4"},
	[4] = {v = vector3(-424.23, -2789.84, 6.52),  h = 134.05, veh = "boxville4"}
}

local jobSpawns = {
	[1] = {x = -3155.67, y = 1132.26, z = 20.69, h = 335.2},
	[2] = {x = 62.66, y = 123.57, z = 79.02, h = 161.44},
	[3] = {x = -425.89, y = 6167.91, z = 31.32, h = 315.59},
	[4] = {x = -521.54, y = -2904.96, z = 5.83, h = 113.16}
}


-- Add Police Blips
Citizen.CreateThread(function()
  for _,b in pairs(jobStart) do
    local blip = AddBlipForCoord(b.v)
    SetBlipSprite(blip, 351)
    SetBlipDisplay(blip, 2)
    SetBlipScale(blip, 1.0)
    SetBlipColour(blip, 0)
    SetBlipAsShortRange(blip, true)
    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("JOB: Delivery")
    EndTextCommandSetBlipName(blip)
    Citizen.Wait(1)
  end
end)


RegisterNetEvent('cnr:delivery_routes')
AddEventHandler('cnr:delivery_routes', function(places)

	-- Gets the distance to each place
	local myPos = GetEntityCoords(PlayerPedId())
	drops = {}
	for k,v in pairs (places) do
		local dcode = json.decode(v["position"])
    local vec   = vector3(dcode["x"], dcode["y"], dcode["z"])
		local dist  = #(myPos - vec)
		if dist < 4000 then table.insert(drops, vec) end
	end

	PickDestination()
end)

function SetDestination(d)
	SetNewWaypoint(d.x, d.y)
	if DoesBlipExist(destBlip) then RemoveBlip(destBlip) end
	destBlip = AddBlipForCoord(d.x, d.y, 0.0)
	SetBlipSprite(destBlip, 66)
	SetBlipDisplay(destBlip, 2)
	SetBlipScale(destBlip, 1.0)
	SetBlipColour(destBlip, 10)
	SetBlipAsShortRange(destBlip, true)
	BeginTextCommandSetBlipName("STRING")
	AddTextComponentString("Delivery")
	EndTextCommandSetBlipName(destBlip)
end

function FinishedRoute()
	SetWaypointOff()
	if DoesBlipExist(destBlip) then RemoveBlip(destBlip) end
end

function NextDestination()
	if #drops > 0 then  PickDestination()
	else                FinishedRoute()
	end
end

function compare(a,b)
	return a.d < b.d
end

-- RecalculateDistance
-- Reorders the destination list to always get the closest one
function RecalculateDistance()
	local temp = drops
	drops = {}
	local myPos = GetEntityCoords(PlayerPedId())
	for k,v in pairs (temp) do
		local dist = GetDistanceBetweenCoords(myPos.x, myPos.y, myPos.z, v["x"], v["y"], v["z"])
		table.insert(drops, {x = v["x"], y = v["y"], z = v["z"], d = dist})
	end
	table.sort(drops, compare)
end

function PickDestination()
	if not firstDest then RecalculateDistance() end
	Citizen.CreateThread(function()
		local atDest 	  = false
		local dropNum     = 1
		if firstDest then 
			dropNum 	= math.random(#drops)
			firstDest 	= false
		end
		local destination = table.remove(drops, dropNum)
		SetWaypointOff()
		SetDestination(destination)
		while not atDest do
			Citizen.Wait(0)
			DrawMarker(1, destination.x, destination.y, destination.z - 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 5.0, 5.0, 1.25, 0, 255, 0, 90, false, false, 1.0, false) 
			if not IsPedInVehicle(PlayerPedId(), dTruck) then
				if not hasPackage then
					local offset = GetOffsetFromEntityInWorldCoords(dTruck, 0.0, -4.0, 0.0)
					DrawMarker(1, offset.x, offset.y, offset.z - 0.8, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.20, 1.20, 1.25, 255, 180, 0, 120, false, false, 1.0, false) 
					if Vdist2(GetEntityCoords(PlayerPedId()), offset.x, offset.y, offset.z) < 2.0 then
						local ped = PlayerPedId()
						box = CreateObject(GetHashKey("prop_cs_box_clothes"), GetEntityCoords(ped), true, false, true)
						AttachEntityToEntity(box, ped, GetPedBoneIndex(ped, 18905), 0.3, 0.0, 0.0, 0.0, 200.0, 40.0, false, false, false, true, 0.0, true)
						hasPackage = true
					end
				else
					if Vdist2(GetEntityCoords(PlayerPedId()), destination.x, destination.y, destination.z) < 1.2 then
						DropPackage()
            TriggerServerEvent('cnr:delivery_complete')
						atDest = true
					end
				end
			end
			if not isOnDeliveryDuty then atDest = true end
		end
		NextDestination()
	end)
end

function DropPackage()
	if hasPackage then
		if box then DeleteObject(box) end
		local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), -0.32, 0.0, -0.07)
		local tempBox = CreateObject(GetHashKey("prop_cs_box_clothes"), offset.x, offset.y, offset.z, true, false, true)
		
		ActivatePhysics(tempBox)
		FreezeEntityPosition(tempBox, false)
		hasPackage = false
		Citizen.CreateThread(function()
			Citizen.Wait(30000)
			DeleteObject(tempBox)
		end)
	end
end

function StartDeliveryJob(ped, sNum)
	
	DoScreenFadeOut(400)
	Citizen.Wait(600)
	
	if dTruck then
		TaskLeaveVehicle(ped, dTruck, 16)
		DeleteVehicle(dTruck)
	end
	
	local veh = GetHashKey(jobStart[sNum].veh)
		
	RequestModel(veh)
	while not HasModelLoaded(veh) do Wait(1) end
	
	dTruck = CreateVehicle(veh, jobSpawns[sNum].x, jobSpawns[sNum].y, jobSpawns[sNum].z, jobSpawns[sNum].h, true, false)
	
  Citizen.Wait(100)
  DecorRegister("OwnerId", 3)
  DecorSetInt(dTruck, "OwnerId", GetPlayerServerId(PlayerId()))
	SetVehicleOnGroundProperly(dTruck)
	SetVehicleColours(dTruck, 112, 83)
	SetModelAsNoLongerNeeded(veh)
  SetEntityAsMissionEntity(dTruck, true, true)
	SetPedIntoVehicle(ped, dTruck, -1)
  SetVehicleDoorsLocked(dTruck, 1)
	
	isOnDeliveryDuty = true 
	
	TriggerServerEvent('cnr:delivery_getroutes')
	TriggerEvent('cnr:chat_notification', "CHAR_SOCIAL_CLUB",
    "Delivery", "Duty Status",
    "Head out to your route and get to work."
  )
	--[[
  SetPedComponentVariation(ped, 7, 0, 0, 2)
  SetPedComponentVariation(ped, 9, 0, 0, 2)
    
  -- Go Postal Uniform
  if jobStart[sNum].veh == "boxville2" then
    if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then 
      SetPedComponentVariation(ped, 4, 13, 5, 2)
      SetPedComponentVariation(ped, 6, 14, 4, 2)
      SetPedComponentVariation(ped, 8, 15, 0, 2)
      SetPedComponentVariation(ped, 11, 171, 1, 2)
    else
      SetPedComponentVariation(ped, 4, 99, 1, 2)
      SetPedComponentVariation(ped, 6, 50, 0, 2)
      SetPedComponentVariation(ped, 8, 14, 0, 2)
      SetPedComponentVariation(ped, 11, 20, 1, 2)
    end
    
  -- PostOp Uniform
  else
    if GetEntityModel(ped) == GetHashKey("mp_m_freemode_01") then 
      SetPedComponentVariation(ped, 4, 13, 4, 2)
      SetPedComponentVariation(ped, 6, 14, 0, 2)
      SetPedComponentVariation(ped, 8, 15, 0, 2)
      SetPedComponentVariation(ped, 11, 171, 0, 2)
    else
      SetPedComponentVariation(ped, 4, 99, 0, 2)
      SetPedComponentVariation(ped, 6, 50, 0, 2)
      SetPedComponentVariation(ped, 8, 14, 0, 2)
      SetPedComponentVariation(ped, 11, 20, 0, 2)
    end
  end
  ]]
	
	-- Drops the package if player is doing something with their hands or getting into a vehicle
  local warned = false
	Citizen.CreateThread(function()
		while isOnDeliveryDuty do
			Citizen.Wait(0)
			if hasPackage then
				local ped = PlayerPedId()
				if IsPlayerFreeAiming(ped) then
					DropPackage()
				elseif IsControlJustPressed(1,24) or IsControlJustPressed(1,25) then -- Attack/Aim
					if GetSelectedPedWeapon(PlayerPedId()) ~= -1569615261 then
						DropPackage()
					end
				elseif IsControlJustPressed(1,23) or IsControlJustPressed(1,45) then -- Enter Vehicle/Reload
					if GetSelectedPedWeapon(PlayerPedId()) ~= -1569615261 then
						DropPackage()
					end
				elseif IsPedInAnyVehicle(ped, true) then
					DropPackage()
				end
      else
        if not warned then 
          if not IsPedInAnyVehicle(PlayerPedId()) then
            warned = true
            TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
              args = {
                "If you go too far away from the truck without a package, "..
                "your truck will be deleted and you'll be marked off duty. "
              }
            })
          end
        end
        if not DoesEntityExist(dTruck) then 
            DelTruckGoOffDuty()
            TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
              args = { "The delivery truck was destroyed! "..
                "You are now off delivery duty "
              }
            })
        
        else 
          if #(GetEntityCoords(PlayerPedId()) - GetEntityCoords(dTruck)) > 80.0 then 
            DelTruckGoOffDuty()
            TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
              args = { "You went too far from the truck without a package. "..
                "You're now off delivery duty. "
              }
            })
          end
        end
			end
		end
	end)
  
  TriggerServerEvent('cnr:delivery_duty', true)
  myJobPoint = sNum
  
	DoScreenFadeIn(1000)
	Citizen.Wait(400)
		
end

function DelTruckGoOffDuty()

	isOnDeliveryDuty = false
	--DoScreenFadeOut(500)
	--Citizen.Wait(6000)
	
	if dTruck then
		if IsPedInAnyVehicle(PlayerPedId()) then
			TaskLeaveVehicle(PlayerPedId(), dTruck, 16)
			Citizen.Wait(100)
		end
		DeleteVehicle(dTruck)
		dTruck 		= nil
	end
	
	if box or hasPackage then
		if box then DeleteObject(box) end
		hasPackage = false
	end
	
	drops				  = {}
	firstDest			= true 
	SetWaypointOff()
	TriggerEvent('cnr:chat_notification', "CHAR_SOCIAL_CLUB",
    "Delivery", "Duty Status", "See you next time."
  )
	
	--TriggerServerEvent('cnr:clothing_recall', false)
  
  TriggerServerEvent('cnr:delivery_duty', false)
	--SetEntityCoords(PlayerPedId(), jobStart[myJobPoint].v)
	--SetEntityHeading(PlayerPedId(), jobStart[myJobPoint].h + 180.0)
	--DoScreenFadeIn(1000)
	
end

-- Waits for keypress to check job starting position
Citizen.CreateThread(function()
  DoScreenFadeIn(100)
	while true do
		Citizen.Wait(0)
		if not isOnDeliveryDuty then
			DrawMarker(1, jobStart[1].v.x, jobStart[1].v.y, jobStart[1].v.z - 0.9, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 3.25, 3.25, 1.0, 0, 255, 0, 90, false, false, 1, false)
			DrawMarker(29, jobStart[1].v.x, jobStart[1].v.y, jobStart[1].v.z + 0.4, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 1.0, 1.0, 1.0, 255, 180, 0, 90, false, false, 1, true)
			if IsControlJustPressed(1, 38) then
				local ped = PlayerPedId()
				if not IsPedInAnyVehicle(ped) then
					for k,p in pairs (jobStart) do
						local myPos = GetEntityCoords(ped)
						local jDist = #(myPos - p.v)
						if jDist < 3.0 then StartDeliveryJob(ped, k) end
					end
				end
			end
		else
			local myPos = GetEntityCoords(PlayerPedId())
			-- Check for ending duty
			for k,p in pairs(jobStart) do
				if #(myPos - p.v) < 3.0 then DelTruckGoOffDuty() end
			end
			Citizen.Wait(1000)
		end
	end
end)

