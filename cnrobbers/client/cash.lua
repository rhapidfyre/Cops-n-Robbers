
RegisterNetEvent('cnr:wallet')
RegisterNetEvent('cnr:bank')


--- EXPORT: CashOnHand()
-- Returns the player's current wallet value
-- @return The player's wallet
local myCash = 0
function Cash() return myCash end


--- EXPORT: CashInBank()
-- Returns the player's bank account balance
-- @return The player's bank value
local myBank = 0
function Bank() return myBank end


AddEventHandler('cnr:bigmap', function(mapOpened)
  if mapOpened then SendNUIMessage({showmoney = true})
  else              SendNUIMessage({hidemoney = true})
  end
end)


--- EVENT: cnr:wallet_value
AddEventHandler('cnr:wallet', function(val)
	if val >= 1000 then  myCash = addComma(tostring(val))
	else                 myCash = val
	end
  -- Sets the actual cash/wallet balance on screen/in the ESC menu
  SendNUIMessage({cashbalance = myCash})
	StatSetInt('MP0_WALLET_BALANCE', math.floor(val), true)
end)


--- EVENT: cnr:bank_account
AddEventHandler('cnr:bank', function(val)
	if val >= 1000 then  myBank = addComma(tostring(val))
	else                 myBank = val
	end
  -- Sets the actual bank account balance on the screen/ESC menu
  SendNUIMessage({bankbalance = myBank})
	StatSetInt('BANK_BALANCE', math.floor(val), true)
end)