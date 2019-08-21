
--[[
  Cops and Robbers: Cash Script (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  07/22/2019
  
  Handles cash, bank, and HUD affairs relating to money.
  This resource is an open license and free for anyone to modify or use
--]]


RegisterServerEvent('cnr:cash_transaction')
RegisterServerEvent('cnr:bank_transaction')
RegisterServerEvent('cnr:bank_transfer')
RegisterServerEvent('cnr:client_loaded')


local plyCash = {}
local plyBank = {}


--- BankTransaction()
-- Moves money in the bank for given player.
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
            local bank = exports['ghmattimysql']:scalarSync(
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
  BankTransaction(ply, value)
end)


--- BankTransfer()
-- Moves money from the bank into the player's hand, or vice versa
-- @param ply The player to modify
-- @param n The amount to transfer (+: hand to bank, -: bank to hand)
function BankTransfer(ply, n) --[[
  local dt  = os.date("%H:%M.%I", os.time())
  local msg = ""
  if ply then 
    if n then 
      local uid = exports['cnrobbers']:UniqueId(ply)
      if uid then 
        if not plyBank[uid] then plyBank[uid] = 0 end
        if not plyCash[uid] then plyCash[uid] = 0 end
        local money = exports['ghmattimysql']:executeSync(
          "SELECT cash,bank FROM characters WHERE idUnique = @u",
          {['u'] = uid}
        )
        if money[1] then 
          -- From bank to hand
          if n < 0 then
            local newVal  = money[1]["bank"] + n
            local newCash = money[1]["cash"] + math.abs(n)
            if newVal < 0 then
              msg = "Transfer would result in a negative balance. Ignored."
            else
              -- SQL: Deduct money from bank
              exports['ghmattimysql']:scalar(
                "SELECT bank_transaction(@u, @v)",
                {['u'] = uid, ['v'] = newVal},
                function(newValue)
                  plyBank[uid] = newValue
                  TriggerClientEvent('cnr:bank_account', ply, newValue)
                end
              )
              -- SQL: Add money to hand
              exports['ghmattimysql']:scalar(
                "SELECT cash_transaction(@u, @v)",
                {['u'] = uid, ['v'] = newCash},
                function(newValue)
                  plyCash[uid] = newCash
                  TriggerClientEvent('cnr:wallet_value', ply, newCash)
                end
              )
            end
            
          -- From hand to bank
          elseif n > 0 then 
          
          else
            msg = "Transfer amount was zero. Ignoring."
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
  return 0]]
end
AddEventHandler('cnr:bank_transfer', function(value, client)
  local ply = source
  if client then ply = client end
  BankTransfer(ply, value)
end)

--- CashTransaction()
-- Puts/takes money into/out of the player's wallet (hand)
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
            local cash = exports['ghmattimysql']:scalarSync(
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
  CashTransaction(ply, value)
end)


function SetPlayerCashValues(val, ply)
  local dt  = os.date("%H:%M.%I", os.time())
  local msg = ""
  local uid = exports['cnrobbers']:UniqueId(ply)
  if not uid then 
    msg = "No Unique ID found for player "..tostring(ply)
  else
    -- SQL: Get player's cash values
    exports['ghmattimysql']:execute(
      "SELECT cash,bank FROM characters WHERE idUnique = @u",
      {['u'] = uid},
      function(money)
        if money[1] then 
          TriggerClientEvent('cnr:wallet_value', ply, money[1]["cash"])
          TriggerClientEvent('cnr:bank_account', ply, money[1]["bank"])
        else
          TriggerClientEvent('cnr:wallet_value', ply, 0)
          TriggerClientEvent('cnr:bank_account', ply, 0)
        end
      end
    )
  end
  print("[CNR "..dt.."] ^1."..msg.."^7")
  return {0,0}
end
AddEventHandler('cnr:client_loaded', function()
  local ply = source
  if client then ply = client end
  SetPlayerCashValues(val, ply)
end)