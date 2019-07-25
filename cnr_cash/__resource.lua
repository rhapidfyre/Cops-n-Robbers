
resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

--[[        RESOURCE EVENTS 
  CLIENT:
    cnr:bank_account  (n)  Changes the player's bank value on screen (abs)
    cnr:wallet_value  (n)  Changes the player's cash value on screen (abs)

  SERVER:
    (if cl param is given, replaces ply=source with given client)
    cnr:cash_transaction (n, cl)  Changes wallet by given value (+/-)
    cnr:bank_transfer    (n, cl)  (+): Hand to Bank, (-): Bank to Hand
    cnr:bank_transaction (n, cl)  Changes bank by given value (+/-)
]]

ui_page "nui/ui.html"
dependency 'cnrobbers'

files {
	"nui/ui.html",
  "nui/ui.js",
  "nui/ui.css"
}

client_scripts {
  "cl_cash.lua"
}

server_scripts {
  "sv_cash.lua"
}

server_exports {
  'BankTransaction',     -- Add/Remove?Return player's bank worth
  'BankTransfer',        -- Changes bank to wallet and wallet to bank
  'CashTransaction',     -- Add / Remove / Return player's cash
  'SetPlayerCashValues', -- Manually set HUD cash values; Retrieve from SQL
}

exports {
  'CashOnHand', -- Return value of client's wallet
  'CashInBank'  -- Return value of client's bank
}