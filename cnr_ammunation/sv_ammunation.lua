
-- ammu server script
RegisterServerEvent('cnr:ammu_buyweapon')
RegisterServerEvent('cnr:ammu_buyammo')

AddEventHandler('cnr:ammu_buyweapon', function(idx)
  
  local client = source
  local uid    = exports['cnrobbers']:UniqueId(client)
  
  if not idx then 
    TriggerClientEvent('chat:addMessage', {templateId = 'errMsg',
      multiline = true, args = {
        "AMMUNATION ERROR",
        "Weapon Index [nil] was not found."
      }
    })
    
  else
    if not weaponsList[idx] then 
      TriggerClientEvent('chat:addMessage', {templateId = 'errMsg',
        multiline = true, args = {
          "AMMUNATION ERROR",
          "Weapon index ["..idx.."] was not found."
        }
      })
    else
    
      -- Can the player's funds cover it?
      local cash = exports['cnr_cash']:GetPlayerCash(client)
      if cash >= weaponsList[idx].price then
        TriggerClientEvent('cnr:ammu_authorize', client, idx)
        exports['cnr_cash']:CashTransaction(client, (0 - weaponsList[idx].price))
      
      else
      
        -- Can the player's bank funds cover it?
        local bank = exports['cnr_cash']:GetPlayerBank(client)
        if bank >= weaponsList[idx].price then
          TriggerClientEvent('cnr:ammu_authorize', client, idx)
          exports['cnr_cash']:BankTransaction(client, (0 - weaponsList[idx].price))
        
        -- Insufficient Funds
        else
          TriggerClientEvent('cnr:chat_notification', client,
            "CHAR_BANK_MAZE", "Maze Bank",
            "Insufficient Funds",
            "Insufficient funds to process that transaction."
          )
        
        end
      end
    end
  end
end)

AddEventHandler('cnr:ammu_buyammo', function(idx, ct)
  
  local client = source
  local uid    = exports['cnrobbers']:UniqueId(client)
  
  if not idx then 
    TriggerClientEvent('chat:addMessage', {templateId = 'errMsg',
      multiline = true, args = {
        "AMMUNATION ERROR",
        "Weapon Index [nil] was not found."
      }
    })
    
  else
    if not ct then ct = 1 end
    if not weaponsList[idx] then 
      TriggerClientEvent('chat:addMessage', {templateId = 'errMsg',
        multiline = true, args = {
          "AMMUNATION ERROR",
          "Weapon index ["..idx.."] was not found."
        }
      })
    else
    
      -- Does the player have the cash to cover it?
      local cash = exports['cnr_cash']:GetPlayerCash(client)
      local aCount = weaponsList[idx].ammo * ct
      local total  = weaponsList[idx].aprice * aCount
      if cash >= total then
        print("DEBUG - Buying with cash: ["..cash.." / "..total.."]")
        TriggerClientEvent('cnr:ammu_authorize', client, idx, ct)
        exports['cnr_cash']:CashTransaction(client, (0 - total))
      
      else
        print("DEBUG - Insufficient Cash: ["..cash.." / "..total.."]")
      
        -- Does the player have the bank funds to cover it?
        local bank = exports['cnr_cash']:GetPlayerBank(client)
        if bank >= total then
          print("DEBUG - Buying with Bank: ["..bank.." / "..total.."]")
          TriggerClientEvent('cnr:ammu_authorize', client, idx, ct)
          exports['cnr_cash']:BankTransaction(client, (0 - total))
        
        -- Dispatch "Insufficient Funds" warning
        else
          print("DEBUG - Insufficient Funds: ["..bank.." / "..total.."]")
          TriggerClientEvent('cnr:chat_notification', client,
            "CHAR_BANK_MAZE", "Maze Bank",
            "Insufficient Funds",
            "Insufficient funds to process that transaction."
          )
        
        end
      end
    end
  end

end)