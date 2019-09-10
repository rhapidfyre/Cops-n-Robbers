
RegisterNetEvent('cnr:active_zone')
RegisterNetEvent('cnr:chat_notify')

local activeZone = 1      -- What zone is currently active
local plyCount   = 255    -- Used Internally (Obsolete? Use GetActivePlayers())


-- DEBUG -
local restarted = {}
AddEventHandler('onResourceStop', function(rn)
  restarted[rn] = true
end)


-- DEBUG -
AddEventHandler('onResourceStart', function(rn)
  if restarted[rn] then
    TriggerEvent('chat:addMessage', {args={
      "An admin has restarted the ^3"..rn.." ^7resource!"
    }})
    if rn == "cnr_police" then 
      TriggerEvent('chat:addMessage', {args={
        "Any active cops must reduty to continue!"
      }})
    end
    restarted[rn] = nil
  end
end)


-- Discord Rich Presence
Citizen.CreateThread(function()
	while true do
		SetDiscordAppId(613118632549154817) -- Discord app id
		SetDiscordRichPresenceAsset('CopsNRobbers') -- Big picture asset name
    SetDiscordRichPresenceAssetText('Cops and Robbers FiveM') -- Big picture hover text
    SetDiscordRichPresenceAssetSmall('cnr_logo') -- Small picture asset name
    SetDiscordRichPresenceAssetSmallText('Cops and Robbers FiveM') -- Small picture hover text
		Citizen.Wait(600000) --How often should this script check for updated assets? (in MS)
	end
end)


--- SetActiveZone()
-- Called by server to tell client what the current zone is
function SetActiveZone(aZone)
  print("DEBUG - The active zone has been set to "..tostring(aZone))
  activeZone = aZone
end
AddEventHandler('cnr:active_zone', SetActiveZone)


--[[----
    EXPORTS
--]]----


--- EXPORT: GetFullZoneName()
-- Returns the name found for the zone in shared.lua
-- If one isn't found, returns "San Andreas"
-- @param abbrv The abbreviation of the zone name given by script
function GetFullZoneName(abbrv)
  if not zoneByName[abbrv] then return "San Andreas" end
  return zoneByName[abbrv]
end


--- EXPORT: GetPlayers()
-- Retrieves a table of all connected players
-- OBSOLETE - Use GetActivePlayers() (Native)
-- @return Table of connected players
function GetPlayers()
    --[[
    local players = {}
    for i = 0, plyCount do
      if NetworkIsPlayerActive(i) then table.insert(players, i) end
    end
    return players]]
    return GetActivePlayers()
end


--- EXPORT: GetClosestPlayer()
-- Finds the closest player
-- @return Player local ID. Must be turned into a ped object or server ID from there.
function GetClosestPlayer()

	local ped   = PlayerPedId()
  local myPos = GetEntityCoords(ped)
	local cPly  = nil
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
  return activeZone
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
RegisterCommand('zones', function()

  -- Display what the current zone is
  TriggerEvent('chat:addMessage', {
    color = {255,140,20}, multiline = false,
    args = {"ACTIVE ZONE", "Zone #"..activeZone}
  })
  
  local temp = {}
  
  -- Build a numerical order list of zones
  for k,v in pairs (zoneByName) do 
    local n = #(temp[v.z]) + 1
    temp[v.z][n] = v.name
  end
 
  -- Display the numerical order list of zones
  for _,i in pairs (temp) do 
    local listed = {}
    for k,v in pairs (v) do 
      listed[#listed + 1] = v
    end
    TriggerEvent('chat:addMessage', {
      color = {0,200,0},
      multiline = false,
      args = {"Zone #"..i..":", table.concat(listed, ", ")}
    })
  end
  
  -- Get player's position and determine the zone they're in
  local myPos = GetEntityCoords(PlayerPedId())
  local zn    = GetNameOfZone(myPos.x, myPos.y, myPos.z)
  local zName = zoneByName[zn]
  TriggerEvent('chat:addMessage', {
    color = {0,200,0},
    multiline = false,
    args = {
      "Your Position",
      tostring(zName.name).." (Zone #"..tostring(zName.z)..")"
    }
  })
  
end)



-- Start saving the player's location
function ReportPosition(truth)
  reportLocation = truth
  
  -- Sends update to MySQL every 12 seconds
  -- Does not send the update if position has not changed
  Citizen.CreateThread(function()
  
    if reportLocation then print("DEBUG - Now reporting position to SQL.")
    else print("DEBUG - No longer reporting position to SQL.")
    end
    
    while reportLocation do 
      if plyIsDead or IsPedDeadOrDying(PlayerPedId()) then 
        print("[CNR] Cannot report position; Player is dead.")
      else
        local myPos = GetEntityCoords(PlayerPedId())
        local doUpdate = false 
        if not lastPos then 
          doUpdate = true 
        elseif #(lastPos - myPos) > 5.0 then 
          doUpdate = true
        end
        if doUpdate then
          local savePos = {
            x = math.floor(myPos.x*1000)/1000,
            y = math.floor(myPos.y*1000)/1000,
            z = math.floor(myPos.z*1000)/1000
          }
          TriggerServerEvent('cnr:save_pos', json.encode(savePos))
        end
        lastPos = GetEntityCoords(PlayerPedId())
      end
      Citizen.Wait(12000)
    end
  end)
    
end