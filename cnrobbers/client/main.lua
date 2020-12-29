
RegisterNetEvent('cnr:active_zone')
RegisterNetEvent('cnr:chat_notify')

local activeZone = 1      -- What zone is currently active



-- DEBUG -
local restarted = {}
AddEventHandler('onResourceStop', function(rn)
  restarted[rn] = true
end)
AddEventHandler('onResourceStart', function(rn)
  if restarted[rn] then
    TriggerEvent('chat:addMessage', {args={
      "An admin has restarted the '^3"..rn.."^7' resource!"
    }})
    restarted[rn] = nil
  end
end)


-- Enable PVP
AddEventHandler('playerSpawned', function()
  NetworkSetFriendlyFireOption(true)
  SetCanAttackFriendly(PlayerPedId(), true, false)
end)


--- SetActiveZone()
-- Called by server to tell client what the current zone is
AddEventHandler('cnr:active_zone', function(aZone)
  if source ~= "" then
    CNR.activeZone = aZone
  end
end)


--- EXPORT: GetPlayers()
-- Retrieves a table of all connected players
-- OBSOLETE - Use GetActivePlayers() (Native)
-- @return Table of connected players
function GetPlayers()
  print("^1Obsolete 'GetPlayers()' was used. You should use the native 'GetActivePlayers()' instead.")
  return GetActivePlayers()
end


--- EXPORT: GetClosestPlayer()
-- Finds the closest player, returns zero on failure/no player closeby
-- @return Player local ID. Must be turned into a ped object or server ID from there.
function GetClosestPlayer()

	local ped   = PlayerPedId()
  local myPos = GetEntityCoords(ped)
	local cPly  = 0
	local cDst  = math.huge
  local plys  = GetActivePlayers()

	for i = 1, #plys do
		local tgt = GetPlayerPed(plys[i])
		if tgt ~= ped then
			local dist = #(myPos - GetEntityCoords(tgt))
			if cDst > dist then cPly = plys[i]; cDst = dist end
		end
	end

	return cPly
end


--- EXPORT: GetActiveZone()
-- Returns what zone number is currently active.
function GetActiveZone()
  return CNR.activeZone
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

  if Config.GetNumberOfZones() < 2 then 
    TriggerEvent('chat:addMessage', {
      color = {0,255,0}, multiline = false,
      args = {"ZONES DISABLED", "The whole map area is in play!"}
    })
    
  else
    -- Get player's position and determine the zone they're in
    local zNumber = ZoneNumber()
    if IsActiveZone() then
      TriggerEvent('chat:addMessage', {
        color = {0,255,0}, multiline = false,
        args = {"ACTIVE ZONE", "You are currently in the active zone (Zone "..GetActiveZone()..")"}
      })
  
    else
      -- Display what the current zone is
      TriggerEvent('chat:addMessage', {
        color = {255,140,20}, multiline = false,
        args  = {"INACTIVE ZONE", "The active zone is currently Zone "..GetActiveZone()}
      })
      TriggerEvent('chat:addMessage', {
        color = {255,140,20}, multiline = false,
        args  = {
          "INACTIVE ZONE", "You're currently in "..ZoneName().." (Zone "..ZoneNumber()..")"
        }
      })
    end
  end
end
RegisterCommand('zones', ListZones)


-- Primary Gamemode Driver
Citizen.CreateThread(function()
  while not CNR.ready do Wait(1000) end
  while true do
    Citizen.Wait(1000)
    UpdateWantedStars()
  end
end)
