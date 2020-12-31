
RegisterServerEvent('cnr:client_loaded')


-- SyncPlayerMoney()
-- Sets the player's money to the amount found within MySQL
-- @param idPlayer number The player ID
local function SyncPlayerMoney(idPlayer)
  if not idPlayer then return false end
  local client = idPlayer
	CNR.SQL.EXECUTE(
    "SELECT cash, bank FROM characters WHERE idUnique = @u",
		{['u'] = UniqueId(client)},
    function(results)
      if results[1] then
        print("DEBUG - ^2Successfully ^7retrieved cash & bank balance for Player #"..client)
        TriggerClientEvent('cnr:wallet', client, results[1]['cash'])
        TriggerClientEvent('cnr:bank', client, results[1]['bank'])
      else
        print("DEBUG - ^1Failed ^7to retrieve cash & bank balance for Player #"..client)
        TriggerClientEvent('cnr:wallet', client, 0)
        TriggerClientEvent('cnr:bank', client, 0)
      end
    end
	)
end


AddEventHandler('cnr:client_loaded', function()
  SyncPlayerMoney(source)
end)


--- SetPlayerWallet()
-- Modifies cash value for given player, with no checks or balances
-- exactValue: Sets the cash value *EXACTLY* to 'value', without checks
function SetPlayerWallet(ply, value, exactValue)
  if not ply then return 0 end
  if exactValue then 
    CNR.SQL.RSYNC("UPDATE characters SET cash = @v WHERE idUnique = @u",
      {['v'] = value, ['u'] = UniqueId(ply)}
    )
  else
    CNR.SQL.RSYNC("UPDATE characters SET cash = cash + @v WHERE idUnique = @u",
      {['v'] = value, ['u'] = UniqueId(ply)}
    )
  end
  SyncPlayerMoney(ply)
end


--- SetPlayerBalance()
-- Modifies bank value for given player, with no checks or balances
-- exactValue: Sets the bank value *EXACTLY* to 'value', without checks
function SetPlayerBalance(ply, value, exactValue)
  if not ply then return 0 end
  if exactValue then 
    CNR.SQL.RSYNC("UPDATE characters SET bank = @v WHERE idUnique = @u",
      {['v'] = value, ['u'] = UniqueId(ply)}
    )
  else
    CNR.SQL.RSYNC("UPDATE characters SET bank = bank + @v WHERE idUnique = @u",
      {['v'] = value, ['u'] = UniqueId(ply)}
    )
  end
  SyncPlayerMoney(ply)
end


--- EXPORT: GetPlayerCash()
-- Returns the player's cash roll
-- @param ply The player's server ID
-- @return The player's cash on hand. If ply is nil, returns 0
function GetPlayerCash(ply)
  if not ply then return 0 end
  local uid = UniqueId(ply)
  if uid < 1 then return 0 end
  return CNR.SQL.RSYNC("SELECT cash FROM characters WHERE idUnique = @u",{['u']=uid})
end


--- EXPORT: GetPlayerBank()
-- Returns the player's bank roll
-- @param ply The player's server ID
-- @return The player's cash in bank. If ply is nil, returns 0
function GetPlayerBank(ply)
  if not ply then return 0 end
  local uid = UniqueId(ply)
  if uid < 1 then return 0 end
  return CNR.SQL.RSYNC("SELECT bank FROM characters WHERE idUnique = @u",{['u']=uid})
end


--- BankTransaction()
-- Used to give or take the players money. Conducts negative checking internally.
-- Should only be used for purchases or income. This function does not allow
-- a resulting value to be negative.
-- For -/+ that should never fail, use 'SetPlayerBalance'
-- negative 'value': Charge
-- positive 'value': Income
function BankTransaction(ply, value, paySource)

  if not ply then return false end
  if not value then return false end
  if type(value) ~= "number" then value = tonumber(value) end
  
  local uid = UniqueId(ply)
	local bank = CNR.SQL.RSYNC(
    "SELECT bank FROM characters WHERE idUnique = @u",
		{['u'] = uid}
  )
  local newValue = math.floor(bank + value)
  
  -- If value was a debit, and result is negative, disallow it
  if newValue < 0 and value < 0 then
    if paySource then
      TriggerClientEvent('cnr:chat_notification', ply, 
        "CHAR_BANK_MAZE", "Insufficient Funds", "Debit Declined",
        "A charge by ~y~"..paySource.."~w~ for ~r~$"..math.abs(value).."~w~ was declined."
      )
    else
      TriggerClientEvent('cnr:chat_notification', ply, 
        "CHAR_BANK_MAZE", "Insufficient Funds", "Debit Declined",
        "A charge for ~r~$"..math.abs(value).."~w~ was declined."
      )
    end
    return false
    
  -- Always allow income sources regardless of negative/positive balance
  else
    TriggerClientEvent('cnr:bank_cash', ply, newValue)
    if value > 0 then
      if paySource then
        TriggerClientEvent('cnr:chat_notification', ply, 
          "CHAR_BANK_MAZE", "New Transaction", "ACH Credit",
          "Deposit received for $~g~"..value.."~w~ from ~y~"..paySource.."~w~."
        )
      else
        TriggerClientEvent('cnr:chat_notification', ply, 
          "CHAR_BANK_MAZE", "New Transaction", "ACH Credit",
          "Deposit received for $~g~"..value.."~w~."
        )
      end
    elseif value < 0 then 
      if paySource then
        TriggerClientEvent('cnr:chat_notification', ply, 
          "CHAR_BANK_MAZE", "New Transaction", "ACH Debit",
          "Paid ~r~$"..math.abs(value).." ~w~to ~y~"..paySource.."~w~."
        )
      else
        TriggerClientEvent('cnr:chat_notification', ply, 
          "CHAR_BANK_MAZE", "New Transaction", "ACH Debit",
          "Paid ~r~$"..math.abs(value).."~w~."
        )
      end
    end
  end
  return true
end
-- Thou shalt not network this event under any circumstances
AddEventHandler('cnr:bank_transaction', BankTransaction)


--- CashTransaction()
-- Used to give or take the players money. Conducts negative checking internally.
-- Should only be used for purchases or income. This function does not allow
-- a resulting value to be negative.
-- For -/+ that should never fail, use 'SetPlayerWallet'
-- negative 'value': Charge
-- positive 'value': Income
function CashTransaction(ply, value, payTitle)

  if not ply then return false end
  if not value then return false end
  if type(value) ~= "number" then value = tonumber(value) end
  
	local uid  = UniqueId(ply)
	local cash = CNR.SQL.RSYNC(
    "SELECT cash FROM characters WHERE idUnique = @u",
		{['u'] = uid}
  )
	local newValue = math.floor(cash + value)
  
  -- If the player can't afford it 
  if newValue < 0 then
  
    -- If no payTitle, then don't use the bank
    if not payTitle then return false end
    return BankTransaction(ply, value, payTitle) -- use bank, if allowed
    
  -- If funds allow it, then proceed
  else
    TriggerClientEvent('cnr:wallet', ply, newValue)
    CNR.SQL.EXECUTE(
    "UPDATE characters SET cash = @v WHERE idUnique = @u",
      {['u'] = uid, ['v'] = newValue}
    )
  end
  return true
  
end
-- Thou shalt not network this event under any circumstances
AddEventHandler('cnr:cash_transaction', CashTransaction)
