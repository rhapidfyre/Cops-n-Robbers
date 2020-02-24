
-- car theft, boosting, chopshops
RegisterNetEvent('cnr:exports_mission_vehicle')
RegisterNetEvent('cnr:exports_delivered')
RegisterNetEvent('cnr:exports_list')


local vehRequest = {}


AddEventHandler('cnr:exports_list', function(vehList)
  TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
      "The auto export list has changed! View the list by typing ^3/exports^7!"
  }})
  vehRequest = vehList
end)


RegisterCommand('exports', function()

  local n = #vehRequest
  if n > 0 then

    local vehs = ""
    for k,v in pairs (vehRequest) do
      local temp    = "^3"..string.lower(v.mdl)
      if k > 1 then temp = "^7, "..temp end
      vehs = vehs..temp
    end

    TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
      args = { "The export yard is seeking: "..vehs }
    })

  else

    TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
        "There are currently no vehicles being requested for export."
    }})

  end
end)


-- This loop handles the blips to ensure they only work for the active zone
Citizen.CreateThread(function()
  for k,v in pairs (vehDrops) do
    local temp = AddBlipForCoord(v.pos)
    SetBlipSprite(temp, 569)
    SetBlipDisplay(temp, 2)
    SetBlipAsShortRange(temp, true)

    BeginTextCommandSetBlipName("STRING")
    AddTextComponentString("Auto Exporter")
    EndTextCommandSetBlipName(temp)

  end
end)

RegisterNetEvent('cnr:exports_delivered')
AddEventHandler('cnr:exports_delivered', function()
  if IsPedInVehicle(PlayerPedId()) then 
    DeleteVehicle(GetVehiclePedIsIn(PlayerPedId()))
  end
end)


AddEventHandler('cnr:exports_mission_vehicle', function(price)

  TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
      "This vehicle is currently export list for ^2$"..price.."^7!"
  }})
    
  Citizen.Wait(2000)
  while IsPedInVehicle(PlayerPedId()) do
    local nearest = 0
    local cDist = math.huge
    local myPos = GetEntityCoords(PlayerPedId())
    for k,v in pairs (vehDrops) do
      local dist = #(myPos - v.pos)
      if dist < cDist then nearest = k; cDist = dist end
    end
    if nearest > 0 then
      if exports['cnrobbers']:InActiveZone() then
        if dist < 4.0 then
          TriggerServerEvent('cnr:exports_arrived', 
            GetEntityModel(GetVehiclePedIsIn(PlayerPedId()))
          )
          Citizen.Wait(12000)
        end
      else
        TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
            "^1REJECTED^7 - This exporter isn't in the active ^3/zones^7!"
        }})
        Citizen.Wait(12000)
      end
    end
    Citizen.Wait(1000)
  end
end)

