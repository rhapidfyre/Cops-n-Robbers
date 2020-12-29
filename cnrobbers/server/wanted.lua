
--[[
  Cops and Robbers: Wanted Script - Server Dependencies
  Created by Michael Harris (mike@harrisonline.us)
  08/19/2019

  This file contains all information that will be stored, used, and
  manipulated by any CNR scripts in the gamemode. For example, a
  player's level will be stored in this file and then retrieved using
  an export; Rather than making individual SQL queries each time.
--]]


RegisterServerEvent('baseevents:enteringVehicle')
RegisterServerEvent('baseevents:enteringAborted')
RegisterServerEvent('baseevents:enteredVehicle')
RegisterServerEvent('baseevents:onPlayerKilled')
RegisterServerEvent('cnr:wanted_points')
RegisterServerEvent('cnr:client_loaded')


local cprint     = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local carUse     = {}  -- Keeps track of vehicle theft actions
local paused     = {}  -- Players to keep from wanted points being reduced
local crimesList = {}
local reduce     = {
  tickTime = 30,   -- Time in seconds between each reduction in wanted points
  points   = 1.25, -- Amount of wanted points to reduce upon (reduce.time)
}

--- EXPORT: WantedPoints()
-- Sets the player's wanted level.
-- @param ply      The player's server ID
-- @param crime    The crime that was committed
-- @param msg      If true, displays "Crime Committed" message
function WantedPoints(ply, crime, msg)
  if not exports['cnr_police']:DutyStatus(ply) then
    if not ply         then return 0        end
    if not wanted[ply] then wanted[ply] = 0 end -- Creates ply index
    if not crime       then
      cprint("^1Crime '^7"..tostring(crime).."^1' not found in sh_wanted.lua!")
      return 0
    end

    if crime == 'jailed' then
      wanted[ply] = 0
      TriggerClientEvent('cnr:wanted_client', (-1), ply, 0)
      TriggerClientEvent('chat:addMessage', ply, {args={
        "^2Your wanted level has been cleared."
      }})
      return 0
    elseif crime == 'prisonbreak' or crime == 'jailbreak' then
      if crime == 'prisonbreak' then
        TriggerClientEvent('cnr:radio_receive', (-1),
          true, "DISPATCH", "An inmate is escaping from Mission Row PD!",
          true, false, false
        )
      else
        TriggerClientEvent('cnr:radio_receive', (-1),
          true, "DISPATCH", "Prisoners are escaping from Bolingbroke Penitentiary!",
          true, false, false
        )
      end
      Citizen.Wait(30000)
    end

    local n = GetCrimeWeight(crime)
    if not n then return 0 end

    local lastWanted = wanted[ply]

    -- Sends a crime message to the perp
    if msg then
      local cn = GetCrimeName(crime)
      if cn then
        TriggerClientEvent('chat:addMessage', ply,
          {templateId = 'crimeMsg', args = {cn}}
        )
        TriggerClientEvent('cnr:push_notify', ply,
          1, "Crime Committed", cn
        )
      end
    end

    -- Add to criminal history
    if not crimesList[ply] then crimesList[ply] = {} end
    local pcl = #(crimesList[ply])
    crimesList[ply][pcl + 1] = crime
    TriggerClientEvent('cnr:wanted_crimelist', ply, crimesList[ply])

    -- Calculates wanted points increase by each point individually
    -- This makes higher wanted levels harder to obtain
    while n > 0 do -- e^-(0.02x/2)
      local addPoints = true

      -- Ensure crime is NOT a felony
      if (not IsCrimeFelony(crime)) then
        -- If the next point would make them a felon, do nothing.
        if wanted[ply] + 1 >= felony then addPoints = false end
      end

      -- Crime is a felony, or would not make player a felon (if not a felony)
      if addPoints then

        --[[ OLD FORMULA: e^-(0.02x/2)
        local modifier = math.exp( -1 * ((0.02 * wanted[ply])/2))
        local formula  = math.floor((modifier * 1)*100000)
        ]]

        -- NEW FORMULA: 1(0.98/1 ^x)
        local modifier = (0.98) ^ wanted[ply]
        wanted[ply]    = wanted[ply] + modifier

      else n = 0
      end

      n = n - 1
      Wait(0)

    end

    -- Check for broadcast
    if lastWanted ~= wanted[ply] then
      local wants = WantedLevel(ply)

      -- Wanted level went up by at least 10 (1 level)
      if lastWanted < wanted[ply] - 10 then
        if wants > 10 then
          exports['cnr_chat']:DiscordMessage(
            11027200, "San Andreas' Most Wanted",
            GetPlayerName(ply).." is now on the Most Wanted list!",
            "", 6
          )
        else
          exports['cnr_chat']:DiscordMessage(
            15105570, GetPlayerName(ply).." had their Wanted Level increased!",
            "WANTED LEVEL "..wants, "", 6
          )
        end

      -- Player is no longer wanted
      elseif lastWanted > 0 and wanted[ply] <= 0 then
        exports['cnr_chat']:DiscordMessage(
          8359053, GetPlayerName(ply).." is no longer wanted.",
          "WANTED LEVEL 0", "", 6
        )

      end
    end

    -- Tell other scripts about the change
    TriggerEvent('cnr:points_wanted', ply, lastWanted, wanted[ply], crime)
    TriggerClientEvent('cnr:wanted_client', (-1), ply, wanted[ply])
  else
    cprint("^1[CRIME] ^7"..GetPlayerName(ply).." #"..ply..
        ", a ^5police officer ^7, committed: "..crime)
  end
end
local tracking   = {}
local worstCrime = {}
AddEventHandler('cnr:wanted_points', function(crime, msg, zName, posn, ignore911)
  local ply = source
  if crime then
    -- DEBUG - Add crime ~= 'jailed' to prevent clients from clearing themselves
    if DoesCrimeExist(crime) then

      -- This is the first crime that has been committed
      if not tracking[ply] and not ignore911 then
        worstCrime[ply] = crime
        tracking[ply] = GetGameTimer() + 6000
        Citizen.CreateThread(function()
          while tracking[ply] > GetGameTimer() do Citizen.Wait(100) end
          exports['cnr_police']:DispatchPolice(
            worstCrime[ply], zName, posn
          )
          tracking[ply] = nil
          worstCrime[ply] = nil
        end)
      -- Update with worst crime committed
      else
        local cWeight = GetCrimeWeight(crime)
        if cWeight > GetCrimeWeight(worstCrime[ply]) then
          worstCrime[ply] = crime
          tracking[ply]   = GetGameTimer() + 6000
        end
      end
      WantedPoints(ply, crime, msg)
    else
      cprint("^1Crime '^7"..tostring(crime).."^1' not found in sh_wanted.lua!")
    end
  end
end)

AddEventHandler('cnr:imprisoned', function(client)
  wanted[client] = 0
  TriggerClientEvent('cnr:wanted_client', (-1), ply, 0)
end)

--- EXPORT WantedLevel()
-- Returns the wanted level of the player for easier calculation
-- @param ply Server ID, if provided
-- @return The wanted level based on current wanted points
function WantedLevel(ply)

  if type(ply) ~= "number" then ply = tonumber(ply) end

  -- If ply not given, return 0
  if not ply         then return 0 end
  if not wanted[ply] then wanted[ply] = 0 end -- Create entry if not exists

  if     wanted[ply] <   1 then return  0
  elseif wanted[ply] > 100 then return 11
  end

  return (math.ceil(wanted[ply]/10))

end


--- AutoReduce()
-- Reduces wanted points per tick
function AutoReduce()
  while true do
    if wanted then
      for k,v in pairs (wanted) do
        if math.floor(v) > 0 then
          -- If wanted level is not paused/locked, allow it to reduce
          if not paused[k] then
            local oldLevel = WantedLevel(k)
            local newV = v - (reduce.points)
            wanted[k] = newV
            if oldLevel > WantedLevel(k) then
              TriggerClientEvent('cnr:wanted_client', (-1), k, wanted[k])
            end
          end
        else
          if not crimesList[k] then crimesList[k] = {} end
          wanted[k] = 0
          crimesList[k] = {}
          TriggerClientEvent('cnr:wanted_client', (-1), k, 0)
          TriggerClientEvent('cnr:wanted_crimelist', k, {})
        end
        Citizen.Wait(10)
      end
    end
    Citizen.Wait((reduce.tickTime)*1000)
  end
end
Citizen.CreateThread(AutoReduce)


--- CheckIfWanted()
-- Checks if player is wanted in SQL (Logged off while wanted)
-- If SQL wanted is zero, does nothing. If wanted, sets 'wanted_client' event
-- @param ply The player's server ID. If not given, function returns
function CheckIfWanted(ply)
  local uid = GetUniqueId(ply)

  if uid then
    CNR.SQL.EXECUTE(
      "SELECT wanted FROM players WHERE idUnique = @uid",
      {['uid'] = uid},
      function(wp)
        -- If player being checked is wanted, send update for that player
        if not wp then
          print("^1[CNR ERROR] ^7SQL gave no response for wanted level query.")
          return
        end
        if wp > 0 then
          wanted[ply] = wp
          TriggerClientEvent('cnr:wanted_client', (-1), ply, wp)
        end
      end
    )
  else
    print("^1[CNR ERROR] ^7Unique ID was invalid ("..tostring(uid)..").")
  end
end


--- EXPORT: CrimeList()
-- Returns a list of crimes committed by the player
-- @param ply The player server ID to check.
-- @param crime If supplied, adds crime to player's crime list
-- @return List of crimes. If not wanted or not found, returns empty list
function CrimeList(ply, crime)
  if not ply             then return {} end
  if not crimesList[ply] then crimesList[ply] = {} end
  local n = #(crimesList[ply]) + 1
  if crime then crimesList[ply][n] = crime end
  return (crimesList[ply])
end


-- Called when a player signs in. Sends them the wanted persons list.
AddEventHandler('cnr:client_loaded', function()
  local ply = source
  -- Send new player list of wanted players
  TriggerClientEvent('cnr:wanted_client', ply, CNR.wanted)
end)










