
--[[
  Cops and Robbers: Cash / Banking / Money Transaction(s)
  Created by RhapidFyre

  These files contain all the features to using money.

  Contributors:
    -

  Created 07/22/2019
--]]

resource_manifest_version  '05cfa83c-a124-4cfa-a768-c24a5811d8f9'

ui_page "nui/ui.html"
dependency 'cnrobbers'

files {
	"nui/ui.html",
  "nui/ui.js",
  "nui/ui.css"
}

client_scripts {
  "sh_config.lua",
  "cl_cash.lua"
}

server_scripts {
  "sh_config.lua",
  "sv_cash.lua"
}

server_exports {
  'BankTransaction',     -- Add/Remove?Return player's bank worth
  'BankTransfer',        -- Changes bank to wallet and wallet to bank
  'CashTransaction',     -- Add / Remove / Return player's cash
  'SetPlayerCashValues', -- Manually set HUD cash values; Retrieve from SQL
  'GetPlayerCash',       -- Gets the player's current cash on hand
  'GetPlayerBank',       -- Gets the player's current bank account value
  'ListATMs',   -- Return a list of ATM info
}

exports {
  'CashOnHand', -- Return value of client's wallet
  'CashInBank',  -- Return value of client's bank
  'ListATMs',   -- Return a list of ATM info
}