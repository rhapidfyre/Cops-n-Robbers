
RegisterServerEvent('cnr:cash_transaction')
RegisterServerEvent('cnr:bank_transaction')
RegisterServerEvent('cnr:bank_transfer')
RegisterServerEvent('cnr:client_loaded')
RegisterServerEvent('cnr:death_insured')

RegisterServerEvent('cnr:atm_usage')

AddEventHandler('cnr:death_insured', function(client, isInsured)
  if isInsured < 1 then
    TriggerClientEvent('cnr:wallet_value', client, 0)
    TriggerClientEvent('cnr:bank_account', client, 0)
  end
end)

local plyCash = {}
local plyBank = {}


--- BankTransaction()
-- Moves money in the bank for given player.
-- If the data comes in as an event, it goes through verification.
-- @param ply The player to modify
-- @param n The amount to modify (negative takes away)
-- @return The value of the player's bank account
function BankTransaction(ply, n)
  local dt  = os.date("%H:%M.%I", os.time())
  local msg = ""
  if ply then
    if n then
      local uid = exports['cnrobbers']:UniqueId(ply)
      if uid then
        if not plyBank[uid] then plyBank[uid] = 0 end
        -- SQL: Change bank value
        local bank = exports['ghmattimysql']:scalarSync(
          "SELECT bank FROM characters WHERE idUnique = @uid",
          {['uid'] = uid}
        )
        if bank then
          local cont   = true
          local newVal = bank + n
          if n < 0 then
            if newVal < 0 then
              cont = false
            end
          end
          if cont then
            -- SQL: Get current value of player's bank account
            exports['ghmattimysql']:execute(
              "UPDATE characters SET bank = @v WHERE idUnique = @u",
              {['v'] = newVal, ['u'] = uid}
            )
            plyBank[uid] = newVal
            TriggerClientEvent('cnr:bank_account', ply, newVal)
            return plyBank[uid]
          else
            msg = "Bank deduction would result in negative balance ("..(bank + n)..")."
          end
        else
          msg = "No SQL record found for UID "..uid
        end
      else
        msg = "'uid' nil in function BankTransaction() (sv_cash.lua)"
      end
    end
  else msg = "'ply' nil in function BankTransaction() (sv_cash.lua)"
  end
  print("[CNR "..dt.."] ^1."..msg.."^7")
  return 0
end
AddEventHandler('cnr:bank_transaction', function(value, client)
  local ply = source
  if client then ply = client end
  if not client then -- Sent by player, verify it.
    if value > max_transact then
      return 0 -- Illegitimate, reject it.
    elseif value < min_transact and value > 0 then
      return 0 -- Illegitimate, reject it (unless it's negative.)
    elseif (lastTransact < GetGameTimer() + 3000) and value > 0 then
      return 0 -- Too fast, reject it... Unless it's negative
    end
  end
  BankTransaction(ply, value)
end)

--- CashTransaction()
-- Puts/takes money into/out of the player's wallet (hand)
-- If the data comes in as an event, it goes through verification.
-- @param ply The player to modify
-- @param n The amount to change (negative takes away)
-- @return val The player's wallet value
function CashTransaction(ply, n)
  local dt  = os.date("%H:%M.%I", os.time())
  local msg = ""
  if ply then
    if n then
      local uid = exports['cnrobbers']:UniqueId(ply)
      if uid then
        if not plyCash[uid] then plyCash[uid] = 0 end
        -- SQL: Change cash value
        local cash = exports['ghmattimysql']:scalarSync(
          "SELECT cash FROM characters WHERE idUnique = @uid",
          {['uid'] = uid}
        )
        if cash then
          local cont   = true
          local newVal = cash + n
          if n < 0 then
            if newVal < 0 then
              cont = false
            end
          end
          if cont then
            -- SQL: Get current value of player's cash account
            exports['ghmattimysql']:execute(
              "UPDATE characters SET cash = @v WHERE idUnique = @u",
              {['v'] = newVal, ['u'] = uid}
            )
            plyCash[uid] = newVal
            TriggerClientEvent('cnr:wallet_value', ply, newVal)
            return plyCash[uid]
          else
            msg = "Cash deduction would result in negative balance ("..(cash + n)..")."
          end
        else
          msg = "No SQL record found for UID "..uid
        end
      else
        msg = "'uid' nil in function BankTransaction() (sv_cash.lua)"
      end
    end
  else msg = "'ply' nil in function BankTransaction() (sv_cash.lua)"
  end
  print("[CNR "..dt.."] ^1."..msg.."^7")
  return 0
end
AddEventHandler('cnr:cash_transaction', function(value, client)
  local ply = source
  if client then ply = client end
  if not client then -- Sent by player, verify it.
    if value > max_transact then
      return 0 -- Illegitimate, reject it.
    elseif (value < min_transact) and value > 0 then
      return 0 -- Illegitimate, reject it.
    elseif (lastTransact < GetGameTimer() + 3000) and value > 0 then
      return 0 -- Too fast, reject it.
    end
  end
  CashTransaction(ply, value)
end)


function SetPlayerCashValues(ply)
  local uid = exports['cnrobbers']:UniqueId(ply)
  if uid then
    -- SQL: Get player's cash values
    exports['ghmattimysql']:execute(
      "SELECT cash,bank FROM characters WHERE idUnique = @u",
      {['u'] = uid},
      function(money)
        if money[1] then
          plyCash[uid] = money[1]["cash"]
          plyBank[uid] = money[1]["bank"]
          TriggerClientEvent('cnr:wallet_value', ply, money[1]["cash"])
          TriggerClientEvent('cnr:bank_account', ply, money[1]["bank"])
        else
          plyCash[uid] = 0
          plyBank[uid] = 0
          TriggerClientEvent('cnr:wallet_value', ply, 0)
          TriggerClientEvent('cnr:bank_account', ply, 0)
        end
      end
    )
  end
  return {0,0}
end
AddEventHandler('cnr:client_loaded', function(client)
  local ply = source
  if client then ply = client end
  SetPlayerCashValues(tonumber(ply))
end)

Citizen.CreateThread(function()
  Citizen.Wait(3000)
  local plys = GetPlayers()
  for _,i in ipairs(plys) do
    SetPlayerCashValues(tonumber(i))
  end
end)

--- EXPORT: GetPlayerCash()
-- Returns the player's cash roll
-- @param ply The player's server ID
-- @return The player's cash on hand. If ply is nil, returns 0
function GetPlayerCash(ply)
  if not ply then return 0 end
  local uid = exports['cnrobbers']:UniqueId(ply)
  if not plyCash[uid] then plyCash[uid] = 0 end
  return plyCash[uid]
end


--- EXPORT: GetPlayerBank()
-- Returns the player's bank roll
-- @param ply The player's server ID
-- @return The player's cash in bank. If ply is nil, returns 0
function GetPlayerBank(ply)
  if not ply then return 0 end
  local uid = exports['cnrobbers']:UniqueId(ply)
  if not plyBank[uid] then plyBank[uid] = 0 end
  return plyBank[uid]
end
