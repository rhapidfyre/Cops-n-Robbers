
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
    if not CNR.zones then CNR.zones = {} end
    CNR.zones.active = aZone
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
  return CNR.zones.active
end


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

local function UnstuckNUI()
  local forceClose = IsPauseMenuActive() or IsPlayerDead(PlayerId())
  if forceClose and not nuiClose then
    nuiClose = true
    print("DEBUG - Forcing NUI Closure & Releasing the Mouse")
    TriggerEvent('cnr:close_all_nui')   -- Close all windows/NUI
    SetNuiFocus(false)                  -- Free the mouse
    Wait(100)
  elseif not forceClose then
    nuiClose = false
  end
end

-- Primary Gamemode Driver
CreateThread(function()
  while not CNR do Wait(1000) end
  while not CNR.ready do Wait(100) end
  while true do
    Wait(1)
    if CNR.loaded then
      UnstuckNUI()        -- Unstuck the NUI if it's stuck
      UpdateWantedStars() -- Keep wanted stars up to date
      CheckForDeath()     -- Handle player's death
    else Wait(1000)
    end
  end
end)

--[[ ---------------------------------------------------------
  DISABLE POLICE/MILITARY DISPATCHING / AGGRESSION / VEHICLES
------------------------------------------------------------ ]]
local disScenario = {"WORLD_HUMAN_COP_IDLES",
            "WORLD_VEHICLE_POLICE_BIKE",
            "WORLD_VEHICLE_POLICE_CAR",
            "WORLD_VEHICLE_POLICE_NEXT_TO_CAR",
            "CODE_HUMAN_POLICE_CROWD_CONTROL",
            "CODE_HUMAN_POLICE_INVESTIGATE"
}
Citizen.CreateThread(function()

  for i = 1, #disScenario do
    SetScenarioTypeEnabled(disScenario[i], false)
  end
  
  for i = 1, 14 do EnableDispatchService(i, false) end
  SetMaxWantedLevel(0)
  
  while true do
    Citizen.Wait(100)
    local myPos = GetEntityCoords(PlayerPedId())
    ClearAreaOfCops(myPos.x, myPos.y, myPos.z, 1000.0, 0)
  end
  
end)


--[[ -----------------------------------------------
  DISCORD RICH PRESENCE
-------------------------------------------------- ]]
Citizen.CreateThread(function()
	while true do
		SetDiscordAppId(613118632549154817) -- Discord app id
		SetDiscordRichPresenceAsset('5MCNR') -- Big picture asset name
    SetDiscordRichPresenceAssetText('5M Cops and Robbers') -- Big picture hover text
    SetDiscordRichPresenceAssetSmall('cnr_logo') -- Small picture asset name
    SetDiscordRichPresenceAssetSmallText('5M CnR') -- Small picture hover text
		Citizen.Wait(600000) --How often should this script check for updated assets? (in MS)
	end
end)
