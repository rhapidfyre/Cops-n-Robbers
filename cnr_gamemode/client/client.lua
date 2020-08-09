
RegisterNetEvent('cnr:chat_notify')


------------------------------------------
-- Reports when a resource is restarted --
AddEventHandler('onResourceStop', function(rn)
  restarted[rn] = true
end)

AddEventHandler('playerSpawned', function()
  SetCanAttackFriendly(PlayerPedId(), true, true)
  NetworkSetFriendlyFireOption(true)
end)

AddEventHandler('onResourceStart', function(rn)
  if restarted[rn] then
    if debugging then
      TriggerEvent('chat:addMessage', {args={
        "The ^3"..rn.." ^7resource has been restarted!"
      }})
    end
  end
end)
------------------------------------------


--- EXPORT: GetClosestPlayer()
-- Returns the closest local player reference
-- @param   minDistance Ignores players past this distance. If nil, math.huge is used
-- @return ID of local player reference, zero on failure (too far/none found)
function GetClosestPlayer(minDistance)
  local ped           = PlayerPedId()
  local myPosition    = GetEntityCoords(ped)
  local closestPlayer = 0
  local distance      = math.huge
  if minDistance then distance = minDistance end
  local plys = GetActivePlayers()
  for _,i in ipairs(plys) do
    local ply = tonumber(i)
    if ply ~= PlayerId() then
      local dist = #(myPosition - GetEntityCoords(GetPlayerPed(ply)))
      if dist < distance then
        closestPlayer = ply
        distance = dist
      end
    end
  end
end


--- EXPORT: ChatNotification()
-- Sends a notification to the lower left area of the screen
-- @param icon The icon to display (https://pastebin.com/XdpJVbHz)
function ChatNotification(icon, title, subtitle, message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	SetNotificationMessage(icon, icon, false, 2, title, subtitle, "")
	DrawNotification(false, true)
	PlaySoundFrontend(-1, "GOON_PAID_SMALL", "GTAO_Boss_Goons_FM_SoundSet", 0)
  return true
end
AddEventHandler('cnr:chat_notify', ChatNotification)


-- Displays the zones, the current active zone, and what zone client is in
function ListZones()

  local myPos   = GetEntityCoords(PlayerPedId())
  local zn      = GetNameOfZone(myPos.x, myPos.y, myPos.z)
  
  local zName   = GetFullZoneName(zn)
  local zNumber = GetZoneNumber(zn)

  if activeZone == zNumber then

    TriggerEvent('chat:addMessage', {
      color = {0,200,0}, multiline = false,
      args = {"ACTIVE ZONE", "You're currently in the active zone."}
    })

  else
    -- Display what the current zone is
    TriggerEvent('chat:addMessage', {
      color = {255,140,20}, multiline = false,
      args = {"INACTIVE ZONE", "The active zone is Zone #"..activeZone}
    })


    TriggerEvent('chat:addMessage', {
      color = {255,140,20}, multiline = false,
      args = {
        "INACTIVE ZONE",
        "You're currently in "..tostring(zName)..", Zone #"..tostring(zNumber)
      }
    })
  end

end
RegisterCommand('zones', ListZones)


--- EXPORT: IsActiveZone()
-- Returns true if the player is in the active zone
function IsActiveZone()
  local myPos   = GetEntityCoords(PlayerPedId())
  local zn      = GetNameOfZone(myPos.x, myPos.y, myPos.z)
  local zNumber = GetZoneNumber(zn)

  if activeZone == zNumber then return true end
  return false
end


Citizen.CreateThread(function()
  while not #CNR.zone_list > 0 do 
    Citizen.Wait(1000)
    TriggerServerEvent('cnr_base:request_zones')
  end
end)


AddEventHandler('cnr_base:zonelist', function(zlist)
  CNR.zone_list = zList
end)