

-- Disables police NPCs, restricts vehicle usage (tanks, etc), and more


Citizen.CreateThread(function()
	while true do
		for i = 1, 14 do EnableDispatchService(i, false) end
		SetPlayerWantedLevel(PlayerId(), 0, false)
		SetPlayerWantedLevelNow(PlayerId(), false)
		SetPlayerWantedLevelNoDrop(PlayerId(), 0, false)
		Wait(0)
	end
end)


local restricted = {
  ["RHINO"] = true,
}


Citizen.CreateThread(function()
  while true do 
    Wait(0)

    --[[ Stops cops from dropping weapons
    for ped in exports['southland']:EnumeratePeds() do 
      if ped then 
        if ped > 0 then
          SetPedDropsWeaponsWhenDead(ped, false)
        end
      end
      Citizen.Wait(100)
    end]]

    -- If player gets in a restricted vehicle, delete it
    local vehc = GetVehiclePedIsTryingToEnter(PlayerPedId())
    if vehc > 0 then
      local mdl = GetDisplayNameFromVehicleModel(GetEntityModel(vehc))
      if restricted[mdl] then
        if true then --exports['ham']:MyAdminLevel() < 4 then
          TaskLeaveVehicle(PlayerPedId(), vehc, 16)
        end
      end
      Citizen.Wait(1000)
    end
  end
end)


Citizen.CreateThread(function()
  -- Removes air traffic
  local scenes = {
    world = {
      "WORLD_VEHICLE_MILITARY_PLANES_SMALL",
      "WORLD_VEHICLE_MILITARY_PLANES_BIG"
    },
    groups = {
      2017590552, -- LSX Traffic
      2141866469, -- Sandy Shores Air Traffic
      1409640232, -- Grapeseed Air Traffic
      "ng_planes", -- Airborne Air Traffic
    },
    planes = {
      "SHAMAL", "LUXOR", "LUXOR2", "JET", "LAZER", "TITAN",
      "BARRACKS", "BARRACKS2", "CRUSADER", "RHINO", "AIRTUG", "RIPLEY"
    }
  }
  while true do
    for _, sctyp in next, (scenes.world) do
      SetScenarioTypeEnabled(sctyp, false)
    end
    for _, scgrp in next, (scenes.groups) do
      SetScenarioGroupEnabled(scgrp, false)
    end
    for _, model in next, (scenes.planes) do
      SetVehicleModelIsSuppressed(GetHashKey(model), true)
    end
    Citizen.Wait(10000)
  end
end)
