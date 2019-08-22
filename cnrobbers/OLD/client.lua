
--[[
  Cops and Robbers Client Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  05/11/2019
  
  This file contains all information that will be stored, used, and
  manipulated by any CNR scripts in the gamemode. For example, a
  player's level will be stored in this file and then retrieved using
  an export; Rather than making individual SQL queries each time.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

local activeZone      = 1
local mostWantedValue = 101
local wantedPlayers   = {}
local restarted       = {} -- DEBUG -
local copDuty         = {}

local reduce = {
  time = 30, -- Time in seconds to reduce wanted level
  pts  = 1.25 -- Amount of wanted points to reduce by
}

local plyCount = 255
local felonLevel = 40

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

---------- ENTITY ENUMERATOR --------------
local entityEnumerator = {
  __gc = function(enum)
    if enum.destructor and enum.handle then
      enum.destructor(enum.handle)
    end
    enum.destructor = nil
    enum.handle = nil
  end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
  return coroutine.wrap(function()
    local iter, id = initFunc()
    if not id or id == 0 then
      disposeFunc(iter)
      return
    end
    
    local enum = {handle = iter, destructor = disposeFunc}
    setmetatable(enum, entityEnumerator)
    
    local next = true
    repeat
      coroutine.yield(id)
      next, id = moveFunc(iter)
    until not next
    
    enum.destructor, enum.handle = nil, nil
    disposeFunc(iter)
  end)
end

--- EXPORT EnumerateObjects()
-- Used to loop through all objects rendered by the client
-- @return The table of entities
-- @usage for objs in EnumerateObjects() do
function EnumerateObjects()
  return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

--- EXPORT EnumeratePeds()
-- Used to loop through all objects rendered by the client
-- @return The table of entities
-- @usage for peds in EnumeratePeds() do
function EnumeratePeds()
  return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

--- EXPORT EnumerateVehicles()
-- Used to loop through all objects rendered by the client
-- @return The table of entities
-- @usage for vehs in EnumerateVehicles() do
function EnumerateVehicles()
  return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

--- EXPORT EnumeratePickups()
-- Used to loop through all pickups rendered by the client
-- @return The table of entities
-- @usage for pickups in EnumeratePickups() do
function EnumeratePickups()
  return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end
-------------------------------------------------	


--- EXPORT: GetFullZoneName()
-- Returns the name found for the zone in shared.lua
-- If one isn't found, returns "San Andreas"
-- @param abbrv The abbreviation of the zone name given by runtime
function GetFullZoneName(abbrv)
  if not zoneByName[abbrv] then return "San Andreas" end
  return zoneByName[abbrv]
end


RegisterNetEvent('cnr:police_officer_duty')
AddEventHandler('cnr:police_officer_duty', function(ply, status)
  copDuty[ply] = status
end)


--- EXPORT: IsCop()
-- Tells the client whether the given server ID is on cop duty or not
-- @param ply The player server ID
-- @return True is a cop on duty 
function IsCop(ply)
  return copDuty[ply]
end


--- EVENT: 'cl_wanted_list'
-- Updates the client's entire table with the current server wanted list
-- @param wanteds The list (table) of wanted players (K: Server ID, V: Points)
RegisterNetEvent('cnr:cl_wanted_list')
AddEventHandler('cnr:cl_wanted_list', function(wanteds)
  wantedPlayers = wanteds
end)


--- EVENT: 'cl_wanted_player'
-- Updates a single entry for a single player.
-- Triggers 'is_wanted' (if 0 -> X) and 'is_clear' (X -> 0) events respectively
-- Also triggers 'is_most_wanted' if wp exceeds 100
-- @param ply The server ID
-- @param wps The wanted points value
RegisterNetEvent('cnr:cl_wanted_client')
AddEventHandler('cnr:cl_wanted_client', function(ply, wp)
  if not wp then wp = 0 end
  if not ply then return 0 end
  if ply == GetPlayerServerId(PlayerId()) then 
    print("DEBUG - Player being affected is YOU!")
    if not wantedPlayers[ply] then wantedPlayers[ply] = wp end
    if wantedPlayers[ply] == 0 and wp > 0 then
      print("DEBUG - You went from innocent to wanted.")
      TriggerEvent('cnr:is_wanted', wp)
    elseif wantedPlayers[ply] > 0 and wp <= 0 then 
      print("DEBUG - You went from wanted to innocent.")
      TriggerEvent('cnr:is_clear')
    end
    if wp > 101 then 
      print("DEBUG - You are now most wanted.")
      TriggerEvent('cnr:is_most_wanted')
    end
  end
  print("DEBUG - wantedPlayers["..tostring(ply).."] = "..tostring(wp))
  wantedPlayers[ply] = wp
end)


-- EXPORT GetWanteds()
-- Returns the table of wanted players
-- @return table The list of wanteds (KEY: Server ID, VAL: Wanted Points)
function GetWanteds()
  return wantedPlayers
end


--- EXPORT GetPlayers()
-- Retrieves a table of all connected players
-- OBSOLETE - Use GetActivePlayers() (Native)
-- @return Table of connected players
function GetPlayers()
    local players = {}
    for i = 0, plyCount do
      if NetworkIsPlayerActive(i) then
			  table.insert(players, i)
		  end
    end
    return players
    
end


--- EXPORT GetClosestPlayer()
-- Finds the closest player
-- @return Player local ID. Must be turned into a ped object or server ID from there.
function GetClosestPlayer()
	local ped  = GetPlayerPed(-1)
	local plys = GetPlayers()
	local cPly = nil
	local cDst = -1
	for k,v in pairs (plys) do
		local tgt = GetPlayerPed(v)
		if tgt ~= ped then
			local dist = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(tgt))
			if cDst == -1 or cDst > dist then
				cPly = v
				cDst = dist
			end
		end
	end
	return cPly
end


function GetActiveZone()
  return activeZone
end


-- DEBUG -
AddEventHandler('onResourceStop', function(rn)
  restarted[rn] = true
end)
-- DEBUG -
AddEventHandler('onResourceStart', function(rn)
  if restarted[rn] then
    TriggerEvent('chat:addMessage', {args={
      "An admin has restarted the "..rn.." resource!"
    }})
    if rn == "cnr_police" then 
      TriggerEvent('chat:addMessage', {args={
        "Any active cops must reduty to continue!"
      }})
    end
    restarted[rn] = nil
  end
end)

function ChatNotification(icon, title, subtitle, message)
	SetNotificationTextEntry("STRING")
	AddTextComponentString(message)
	SetNotificationMessage(icon, icon, false, 2, title, subtitle, "")
	DrawNotification(false, true)
	PlaySoundFrontend(-1, "GOON_PAID_SMALL", "GTAO_Boss_Goons_FM_SoundSet", 0)
  return true
end

RegisterNetEvent('cnr:chat_notify')
AddEventHandler('cnr:chat_notify', function(icon, title, subt, msg)
  ChatNotification(icon, title, subt, msg)
end)

RegisterNetEvent('cnr:active_zone')
AddEventHandler('cnr:active_zone', function(aZone)
  activeZone = aZone
end)

RegisterCommand('zones', function()
  TriggerEvent('chat:addMessage', {
    color = {255,140,20},
    multiline = false,
    args = {
      "ACTIVE ZONE",
      "Zone #"..activeZone
    }
  })
  TriggerEvent('chat:addMessage', {
    color = {0,200,0},
    multiline = false,
    args = {
      "Zone 1",
      "Los Santos (All), LS Airport, Port of L.S., Racetrack, Mirror Park"
    }
  })
  TriggerEvent('chat:addMessage', {
    color = {0,200,0},
    multiline = false,
    args = {
      "Zone 2",
      "Palomino, Tataviam, Senora Desert, Sandy Shores, Harmony, Prison."
    }
  })
  TriggerEvent('chat:addMessage', {
    color = {0,200,0},
    multiline = false,
    args = {
      "Zone 3",
      "Zancudo, Chumash, Great Chaparral, Mount Josiah, Vinewood Hills, Stab City."
    }
  })
  TriggerEvent('chat:addMessage', {
    color = {0,200,0},
    multiline = false,
    args = {
      "Zone 4",
      "Paleto Bay, Mount Chiliad, Chiliad Wilderness, Mount Gordo, Grapeseed."
    }
  })
  local myPos = GetEntityCoords(PlayerPedId())
  local zn    = GetNameOfZone(myPos.x, myPos.y, myPos.z)
  local zName = zoneByName[zn]
  if zName.z then 
    TriggerEvent('chat:addMessage', {
      color = {0,200,0},
      multiline = false,
      args = {
        "Your Position",
        (zName.name).." (Zone #"..(zName.z)..")"
      }
    })
  else
    TriggerEvent('chat:addMessage', {
      color = {0,200,0},
      multiline = false,
      args = {
        "Your Zone",
        "Not located; You might be in the sky, at sea, or in an area unscripted."
      }
    })
  end
end)
