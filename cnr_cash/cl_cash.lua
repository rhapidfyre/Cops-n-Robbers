
RegisterNetEvent('cnr:atm_user')

local myCash, myBank = 0, 0


-- addComma()
-- Adds a comma every 3 digits to format the cash value
-- @param
local function addComma(str)
	return #str % 3 == 0 and str:reverse():gsub("(%d%d%d)","%1,"):reverse():sub(2) or str:reverse():gsub("(%d%d%d)", "%1,"):reverse()
end


--- EXPORT: CashOnHand()
-- Returns the player's current wallet value
-- @return The player's wallet
function CashOnHand()
  return myCash
end


--- EXPORT: CashInBank()
-- Returns the player's bank account balance
-- @return The player's bank value
function CashInBank()
  return myBank
end


--- EVENT: cnr:wallet_value
RegisterNetEvent('cnr:wallet_value')
AddEventHandler('cnr:wallet_value', function(val)
	if val >= 1000 then  myCash = addComma(tostring(val))
	else                 myCash = val
	end
  -- Sets the actual cash/wallet balance on screen/in the ESC menu
	StatSetInt('MP0_WALLET_BALANCE', math.floor(val), true)
end)


--- EVENT: cnr:bank_account
RegisterNetEvent('cnr:bank_account')
AddEventHandler('cnr:bank_account', function(val)
	if val >= 1000 then  myBank = addComma(tostring(val))
	else                 myBank = val
	end
  -- Sets the actual bank account balance on the screen/ESC menu
	StatSetInt('BANK_BALANCE', math.floor(val), true)
end)