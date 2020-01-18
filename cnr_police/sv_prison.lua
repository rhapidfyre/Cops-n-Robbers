

RegisterServerEvent('cnr:police_imprison')
RegisterServerEvent('cnr:police_jail')
RegisterServerEvent('cnr:police_release')
RegisterServerEvent('cnr:police_ticket')
RegisterServerEvent('cnr:prison_break')       -- Starts the prison break event
RegisterServerEvent('cnr:prison_sendto')
RegisterServerEvent('cnr:prison_time_served') -- 30 seconds served
RegisterServerEvent('cnr:client_loaded')
RegisterServerEvent('cnr:police_door')
RegisterServerEvent('cnr:prison_break')


local inmates   = {}
local prisoners = {}    -- Used if player is in big boy jail
local serveTime = {}
local tickets   = {}
local cprint    = function(msg) exports['cnrobbers']:ConsolePrint(msg) end


local ticketTime    = 30 -- Time in seconds to give player to pay ticket
local minFineAmount = 100
local maxFineAmount = 25000


function CalculateTime(ply)
  local n = 0
  for k,v in pairs(exports['cnr_wanted']:CrimeList(ply)) do
    n = n + exports['cnr_wanted']:GetCrimeTime(v)
  end
  if n > 120 then   return 120
  elseif n > 5 then return n
  end
  return 5
end


--- ReleaseFugitive()
-- Removes all traces of player inmate/prison info from tables
-- Also triggers prison_release event
-- @param ply The player's server ID to release
-- @param isBreakout True if the player broke out of prison
function ReleaseFugitive(ply, isBreakout)

  if inmates[ply] or prisoners[ply] then
  
    local uid = exports['cnrobbers']:UniqueId(ply)
    local title = "jail"
    if prisoners[ply] then title = "prison" end
    
    if not isBreakout then
      TriggerClientEvent('cnr:prison_release', ply, prisoners[ply])
      exports['cnr_chat']:DiscordMessage(1752220, "RELEASED",
        GetPlayerName(ply).." has paid their debt to society.", ""
      )
      cprint(
        GetPlayerName(ply).." has served their debt to society, "..
        "and has been ^2released^7 from "..title.."."
      )
    else
      cprint("^3"..GetPlayerName(ply).." has broken out of "..title.."!.")
    end
  
    if serveTime[ply] then serveTime[ply]  = nil end
    if inmates[ply]   then inmates[ply]    = nil end
    if prisoners[ply] then prisoners[ply]  = nil end
  
    -- SQL: Remove inmate record
    exports['ghmattimysql']:execute(
      "DELETE FROM inmates WHERE idUnique = @uid",
      {['uid'] = uid},
      function() end
    )
    
  else
    if isBreakout then 
      print("DEBUG - "..GetPlayerName(ply).." (ID "..ply..") reported prisonbreak, but they're not imprisoned.")
    end
  end
end


AddEventHandler('cnr:prison_break', function()
  ReleaseFugitive(source, true)
end)

function ImprisonClient(ply, cop)
  if ply and cop then

    local wantedLevel = exports['cnr_wanted']:WantedLevel(ply)
    local uid         = exports['cnrobbers']:UniqueId(ply)

    -- Jail / Prison
    if wantedLevel > 3 then

      serveTime[ply]  = CalculateTime(ply) * 60
      inmates[ply]    = true

      if wantedLevel > 5 then
        prisoners[ply] = true
        cprint("^4"..GetPlayerName(ply)..
          " has been sent to prison for "..(serveTime[ply]/60).." minutes!"
        )
        exports['cnr_chat']:DiscordMessage(1752220, "BUSTED",
          GetPlayerName(ply).." has been caught and was sent to prison!",
          "Arrested by "..GetPlayerName(cop)
        )
      else
        cprint("^4"..GetPlayerName(ply)..
          " has been sent to jail for "..(serveTime[ply]/60).." minutes!"
        )
        exports['cnr_chat']:DiscordMessage(1752220, "BUSTED",
          GetPlayerName(ply).." has been caught and was sent to jail!",
          "Arrested by "..GetPlayerName(cop)
        )
      end

      -- Tell client to go to prison
      TriggerClientEvent('cnr:police_imprison', ply,
        cop, serveTime[ply], prisoners[ply]
      )

      -- Fire off relevant server scripts
      TriggerEvent('cnr:imprisoned', ply, cop)

      -- SQL: Insert inmate to SQL
      exports['ghmattimysql']:execute(
        "INSERT INTO inmates (idUnique, sentence, isPrison) "..
        "VALUES (@uid, @jt, @p)",
        {['uid'] = uid, ['jt'] = serveTime[ply], ['p'] = prisoners[ply]}
      )

    -- Ticket
    elseif wantedLevel > 0 then
      if not tickets[ply] then tickets[ply] = 0 end
      if tickets[ply] > 0 then
        TriggerClientEvent('chat:addMessage', cop, {args={
          "^1That player already has a ticket, wait to see if they pay it!"
        }})

      else
        local n = 0
        local cList = exports['cnr_wanted']:CrimeList(ply)
        for k,v in pairs(cList) do
          local cFine = exports['cnr_wanted']:GetCrimeFine(v)
          print("DEBUG - GetCrimeFine("..tostring(v)..") = "..tostring(cFine))
          n = n + cFine
          print("DEBUG - $"..tostring(n))
        end

        if n < minFineAmount then n = minFineAmount
        elseif n > maxFineAmount then n = maxFineAmount end
        tickets[ply] = n
        TriggerClientEvent('cnr:ticket_client', ply, cop, tickets[ply])
        TriggerClientEvent('chat:addMessage', cop, {args={
          "^2You have issued ^7"..GetPlayerName(ply).." ^2a ticket "..
          "for ^7$"..tickets[ply].."^2.\nWait to see if they pay the fine..."
        }})

        -- Create ticketTime timer
        Citizen.CreateThread(function()
          local cl = ply
          Citizen.Wait(ticketTime * 1000)
          if tickets[cl] > 0 then
            exports['cnr_wanted']:WantedPoints(cl, 'unpaid')
            TriggerClientEvent('chat:addMessage', cl, {templateId = 'crimeMsg',
              args = {"Failure to Pay a Citation"}
            })
          end
        end)

      end
      return 0 -- Return as to not run the WantedLevel() export below

    else
      TriggerClientEvent('chat:addMessage', cop, { args = {
        "^1Player #"..ply.." is not wanted!"
      }})
      return 0 -- Return as to not run the WantedLevel() export below

    end

    exports['cnr_wanted']:WantedPoints(ply, 'jailed')

  end
end
AddEventHandler('cnr:prison_sendto', function(ply)
  local cop = source
  if exports['cnr_police']:DutyStatus(cop) then
    ImprisonClient(ply, cop)
  end
end)


AddEventHandler('cnr:ticket_payment', function(idOfficer)
  local ply = source
  if not tickets[ply] then tickets[ply] = 0 end
  if tickets[ply] > 0 then
    local tPay = tickets[ply]
    local plyCash = exports['cnr_cash']:GetPlayerCash(ply)
    if tPay <= plyCash then
      exports['cnr_cash']:CashTransaction(tPay, ply)
      tickets[ply] = 0
    else
      plyCash = exports['cnr_cash']:GetPlayerBank(ply)
      if tPay <= plyCash then
        exports['cnr_cash']:BankTransaction(tPay, ply)
      else
        TriggerClientEvent('chat:addMessage', ply, { args = {
          "^1You don't have enough money to pay the ticket!!"
        }})
        return 0
      end
    end
    if idOfficer then
      exports['cnr_wanted']:WantedPoints(ply, 'jailed')
      TriggerClientEvent('chat:addMessage', idOfficer, { args = {
        "^3"..GetPlayerName(ply).."^2 paid the ticket and is no longer wanted."
      }})
      exports['cnr_cash']:CashTransaction(math.floor(tPay*0.33), idOfficer)
    end
    TriggerClientEvent('chat:addMessage', ply, { args = {
      "^2You have paid the ticket and are no longer wanted by the police."
    }})
    tickets[ply] = 0
  end
end)


AddEventHandler('playerDropped', function(reason)

  local ply        = source
  local pName      = GetPlayerName(ply)
  local isInmate   = inmates[ply]
  local isPrisoner = 0
  if prisoners[ply] then isPrisoner = 1 end
  
  if isInmate or isPrisoner == 1 then
    local uid = exports['cnrobbers']:UniqueId(ply)
    local jTime = serveTime[ply]
    if not pName then pName = "Unknown" end
    if not jTime then jTime = 5;cprint("^1WARNING:^7 serveTime not found!") end
    exports['ghmattimysql']:executeSync(
      "CALL offline_inmate(@uid, @jTime, @bigJail)",
      {['uid'] = uid, ['jTime'] = jTime, ['bigJail'] = isPrisoner}
    )
    exports['cnrobbers']:ConsolePrint(
      tostring(pName).." logged off with "..tostring(jTime)..
      " seconds left to serve. Their time has been added to SQL."
    )
    serveTime[ply] = 0
    prisoners[ply] = nil
    inmates[ply]   = nil
  end
end)


-- Checks to see if player last logged off with time in jail/prison to serve
AddEventHandler('cnr:client_loaded', function()
  local ply   = source
  local pName = GetPlayerName(ply)
  local uid   = exports['cnrobbers']:UniqueId(ply)
  if not uid then uid = 0 end

  -- Send current door lock status
  for i = 1, #pdDoors do
    TriggerClientEvent('cnr:police_doors', (-1), i, pdDoors[i].locked)
  end

  -- Check inmate status
  if uid > 0 then
    exports['ghmattimysql']:execute(
      "SELECT * FROM inmates WHERE idUnique = @uid",
      {['uid'] = uid},
      function(jailInfo)
        if jailInfo[1] then
          cprint(pName.." last logged off with time to serve.")
          if jailInfo[1]["sentence"] > 0 then
            inmates[ply]   = true
            serveTime[ply] = jailInfo[1]["sentence"]
            if jailInfo[1]["isPrisoner"] == 1 then
              prisoners[ply] = true
              cprint(pName.." has been sent back to prison.")
            else
              cprint(pName.." has been sent back to jail.")
            end
            cprint(
              "Time remaining: "..
              math.floor(jailInfo[1]["sentence"]/60).." minutes & "..
              math.floor(jailInfo[1]["sentence"]%60).." seconds."
            )
            print(jailInfo[1]["sentence"], jailInfo[1]["isPrison"])
            TriggerEvent('cnr:imprisoned', ply)
            TriggerClientEvent('cnr:prison_rejail', ply,
              jailInfo[1]["sentence"], jailInfo[1]["isPrison"]
            )
          else
            cprint("Fugitive record found but no time remaining. Releasing.")
            ReleaseFugitive(ply)
          end
        else
          cprint(pName.." is not a prisoner/inmate.")
        end
      end
    )
  else cprint("sv_prison.lua unable to load Unique ID for "..pName)
  end
end)


-- Handles jail / inmate timers
Citizen.CreateThread(function()
  while true do
    for k,v in pairs (serveTime) do
      if v then
        if v < 1 then
          if GetPlayerName(k) then
            print(GetPlayerName(k).." has served their time and has been released!")
            ReleaseFugitive(k)
          end
        end
        if v then serveTime[k] = v - 1 end
      end
    end
    Citizen.Wait(1000)
  end
end)


--[[
  This is to catch incase a client is in prison but is supposed to be released.
  Basically, this is called by the client if their timer is up but they
  were not released. When received, we verify that they are in fact a prisoner
  or an inmate. If they are, and they have less than 1 minute of time to go,
  they are released. If they are not, they are released. Otherwise, we notify
  an admin that they tried to get released.
]]
AddEventHandler('cnr:prison_time_served', function()
  local ply       = source
  local isJailed  = inmates[ply]
  local isPrison  = prisoners[ply]
  if isJailed or isPrison then
    if serveTime[ply] then
      -- If less than 1 minute remaining
      if serveTime[ply] < 61 then
        print("DEBUG - Player stuck in jail, releasing.")
        ReleaseFugitive(ply)
      end
    else
      print("DEBUG - Player stuck in jail, releasing.")
      ReleaseFugitive(ply)
    end
  else
    print("DEBUG - Player stuck in jail, releasing.")
    ReleaseFugitive(ply)
  end
  -- DEBUG - Add an admin note for all failing cases (non-release)
end)


AddEventHandler('cnr:police_door', function(doorNumber, isLocked)
  if DutyStatus(source) then
    if pdDoors[doorNumber] then
      pdDoors[doorNumber].locked = isLocked
      TriggerClientEvent('cnr:police_doors', (-1), doorNumber, isLocked)
    end
  end
end)



