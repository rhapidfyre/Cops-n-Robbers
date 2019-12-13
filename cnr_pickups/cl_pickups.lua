
-- Client!
RegisterCommand('spawngun', function()
  print("^3DEBUG - Creating a gun spawn")
  local modelHash = GetHashKey("w_pi_pistol.mdl")
  RequestModel(modelHash)
  while not HasModelLoaded(modelHash) do Wait(1) end
  print("DEBUG - Gun model loaded and ready to go")
  local offset = GetOffsetFromEntityInWorldCoords(PlayerPedId(), 0.0, 6.5, 0.2)
  
  local obj = CreateObject(modelHash, offset.x, offset.y, offset.z,
		false, false, false
	)
  print("^3DEBUG - Object has been created offset from player's location")
  FreezeEntityPosition(obj, true)
  Citizen.CreateThread(function()
    while DoesEntityExist(obj) do 
      local heading = GetEntityHeading(obj) + 1.1
      if heading > 359.0 then heading = 0.0 end
      SetEntityHeading(obj, heading)
      Citizen.Wait(5)
    end
    print("^3DEBUG - MODEL REMOVED")
  end)
  print("^3DEBUG - Waiting for model to expire")
  Citizen.Wait(8000)
  DeleteObject(obj)
  print("^3DEBUG - Model expired.")
end)
