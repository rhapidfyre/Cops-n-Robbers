
-- ammu server script
RegisterServerEvent('cnr:ammu_buyweapon')
RegisterServerEvent('cnr:ammu_buyammo')


--- EXPORT: CheckWeapon()
-- Checks if the player already owns that weapon (SQL)
-- @return (-1) on failure, (0) if not found, (>0) if player has it already
function CheckWeapon(client, idx)
  if not client then return (-1) end
  local wCount = exports['ghmattimysql']:scalarSync(
    "SELECT COUNT(*) FROM weapons WHERE character_id = @c AND hash = @h",
    {
      ['c'] = exports['cnrobbers']:UniqueId(client),
      ['h'] = weaponsList[idx].mdl
    }
  )
  return wCount
end


--- EXPORT: StoreWeapon()
-- Stores the weapon into MySQL
-- @param idx The weaponsList index number
-- @param wAmmo Amount of ammo; If nil, uses default from weaponsList[idx].ammo
-- @return True if the weapon could be added; False if not.
function StoreWeapon(client, idx, wAmmo)

  if not client then
    print("^1ERROR^7 - No client given to StoreWeapon()"); return false
  end
  
  if idx then
  
    -- If player already has this weapon, reject the storage
    if CheckWeapon(client, idx) > 0 then
      TriggerClientEvent('chat:addMessage', client, {
        templateId = 'sysMsg', args = {
          "That weapon is already in your wheel. Try purchasing ammo instead!"
        }
      })
      return false 
      
    -- Otherwise, store it 
    else
      local ammoCount = weaponsList[idx].ammo
      if wAmmo then ammoCount = wAmmo end
      local cid = exports['cnrobbers']:UniqueId(client)
      exports['ghmattimysql']:execute(
        "INSERT INTO weapons (character_id, ammo, hash) VALUES (@c, @a, @h)",
        {['c'] = cid, ['a'] = ammoCount, ['h'] = weaponsList[idx].mdl}
      )
      return true
    end
  else
    print("^1ERROR^7 - Unable to store weapon into MySQL. [idx] was 'nil'.")
    return false
  end
end


--- EXPORT: RevokeWeapon()
-- Revokes the weapon from SQL
function RevokeWeapon(idx, sqlRow)
end

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
        if StoreWeapon(client, idx) then 
          TriggerClientEvent('cnr:ammu_authorize', client, idx)
          exports['cnr_cash']:CashTransaction(
            client, (0 - weaponsList[idx].price)
          )
        else
          TriggerClientEvent('chat:addMessage', {templateId = 'errMsg',
            multiline = true, args = {
              "AMMUNATION ERROR",
              "Something went wrong with your purchase. You have not been charged."
            }
          })
          exports['cnr_admin']:AdminChat("AMMUNATION",
            GetPlayerName(client).." [ID "..client.."] tried to purchase a(n) "..
            (weaponList[idx].name)..", but something went wrong. Please investigate."
          )
        end
      
      else
      
        -- Can the player's bank funds cover it?
        local bank = exports['cnr_cash']:GetPlayerBank(client)
        if bank >= weaponsList[idx].price then
          if StoreWeapon(client, idx) then
            TriggerClientEvent('cnr:ammu_authorize', client, idx)
            exports['cnr_cash']:BankTransaction(
              client, (0 - weaponsList[idx].price)
            )
          else
            TriggerClientEvent('chat:addMessage', {templateId = 'errMsg',
              multiline = true, args = {
                "AMMUNATION ERROR",
                "Something went wrong with your purchase. You have not been charged."
              }
            })
            exports['cnr_admin']:AdminChat("AMMUNATION",
              GetPlayerName(client).." [ID "..client.."] tried to purchase a(n) "..
              (weaponList[idx].name)..", but something went wrong. Please investigate."
            )
          end
        
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
        if StoreWeapon(client, idx, aCount) then 
          TriggerClientEvent('cnr:ammu_authorize', client, idx)
          exports['cnr_cash']:CashTransaction(
            client, (0 - total)
          )
        else
          TriggerClientEvent('chat:addMessage', {templateId = 'errMsg',
            multiline = true, args = {
              "AMMUNATION ERROR",
              "Something went wrong with your purchase. You have not been charged."
            }
          })
          exports['cnr_admin']:AdminChat("AMMUNATION",
            GetPlayerName(client).." [ID "..client.."] tried to purchase ammo for a(n) "..
            (weaponList[idx].name)..", but something went wrong. Please investigate."
          )
        end
      
      else
      
        -- Does the player have the bank funds to cover it?
        local bank = exports['cnr_cash']:GetPlayerBank(client)
        if bank >= total then
          if StoreWeapon(client, idx, aCount) then
            TriggerClientEvent('cnr:ammu_authorize', client, idx)
            exports['cnr_cash']:BankTransaction(
              client, (0 - total)
            )
          else
            TriggerClientEvent('chat:addMessage', {templateId = 'errMsg',
              multiline = true, args = {
                "AMMUNATION ERROR",
                "Something went wrong with your purchase. You have not been charged."
              }
            })
            exports['cnr_admin']:AdminChat("AMMUNATION",
              GetPlayerName(client).." [ID "..client.."] tried to purchase ammo for a(n) "..
              (weaponList[idx].name)..", but something went wrong. Please investigate."
            )
          end
        
        -- Dispatch "Insufficient Funds" warning
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