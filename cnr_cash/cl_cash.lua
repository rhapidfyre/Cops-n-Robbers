
--[[
  Cops and Robbers: Cash Script (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  07/22/2019
  
  Handles cash, bank, and HUD affairs relating to money.
  This resource is an open license and free for anyone to modify or use
--]]


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
RegisterNetEvent('srp:wallet_cash')
AddEventHandler('srp:wallet_cash', function(cash)
	if cash >= 1000 then
		myCash = addComma(tostring(cash))
	else
		myCash = cash
	end
	--TriggerEvent('srp:hud_update', "cash", myCash)
	StatSetInt('MP0_WALLET_BALANCE', math.floor(cash), true)
end)


--- EVENT: srp:bank_account
RegisterNetEvent('srp:bank_cash')
AddEventHandler('srp:bank_cash', function(cash)
	if cash >= 1000 then
		myCash = addComma(tostring(cash))
	else
		myCash = cash
	end
	--TriggerEvent('srp:hud_update', "bank", myCash)
	StatSetInt('BANK_BALANCE', math.floor(cash), true)
end)