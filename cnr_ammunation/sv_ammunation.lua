
-- ammu server script
RegisterServerEvent('cnr:ammu_buyweapon')
RegisterServerEvent('cnr:ammu_buyammo')
RegisterServerEvent('cnr:ammu_ammo_update')
RegisterServerEvent('cnr:client_loaded')

local function UID(client)
  return exports['cnrobbers']:UniqueId(client)
end


-- Updates the ammo record in SQL
-- Never trust clients; This should REDUCE the ammo, never ADD.
-- Ensure they have the weapon and they're not trying to give it to themselves
AddEventHandler('cnr:ammu_ammo_update', function(wHash, wAmmo)
  
  local client = source
  local uid    = UID(client)
  
  local aCount = exports['ghmattimysql']:scalarSync(
    "SELECT ammo FROM weapons WHERE character_id = @c AND hash = @h",
    {['c'] = uid, ['h'] = wHash}
  )
  
  if aCount then 
    if aCount > wAmmo then
      exports['ghmattimysql']:execute(
        "UPDATE weapons SET ammo = @a WHERE character_id = @c AND hash = @h",
        {['a'] = wAmmo, ['c'] = uid, ['h'] = wHash}
      )
    end
  
  end
  
end)

--- EXPORT: CheckWeapon()
-- Checks if the player already owns that weapon (SQL)
-- @return (-1) on failure, (0) if not found, (>0) if player has it already
function CheckWeapon(client, idx)
  if not client then return (-1) end
  local wCount = exports['ghmattimysql']:scalarSync(
    "SELECT COUNT(*) FROM weapons WHERE character_id = @c AND hash = @h",
    {
      ['c'] = UID(client),
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
    print("^1ERROR^7 - No client # given to StoreWeapon()"); return false
  end
  
  if idx then
  
    if not wAmmo then 
    
      -- If player already has this weapon, reject the storage
      if CheckWeapon(client, idx) > 0 then
        TriggerClientEvent('chat:addMessage', client, {
          templateId = 'sysMsg', args = {
            "Trying to duel wield firearms? Buy ammo, you already have this one."
          }
        })
        return false 
        
      -- Otherwise, store it 
      else
        local ammoCount = weaponsList[idx].ammo
        if wAmmo then ammoCount = wAmmo end
        local uid = UID(client)
        exports['ghmattimysql']:execute(
          "INSERT INTO weapons (character_id, ammo, hash) VALUES (@c, @a, @h)",
          {['c'] = uid, ['a'] = ammoCount, ['h'] = weaponsList[idx].mdl}
        )
        return true
      end
      
    else
    
      -- Does the player have this weapon?
      if CheckWeapon(client, idx) < 1 then 
        TriggerClientEvent('chat:addMessage', client, {
          templateId = 'sysMsg', args = {
            "Trying to stockpile ammo for the apocalypse? Buy the gun first."
          }
        })
        return false
        
      else
        local uid = UID(client)
        exports['ghmattimysql']:execute(
          "UPDATE weapons SET ammo = @a WHERE hash = @h AND character_id = @c",
          {['c'] = uid, ['a'] = wAmmo, ['h'] = weaponsList[idx].mdl}
        )
        return true
      end
      
    end
  else
    print("^1ERROR^7 - Unable to store weapon into MySQL. [idx] was 'nil'.")
    return false
  end
end


--- EXPORT: RevokeWeapon()
-- Revokes the weapon from SQL, OR the specified amount of ammo
-- @param client The player to revoke the weapon(s)/ammo from
-- @param idx The weaponsList index to search for
-- @param wAmmo The amount of ammo to revoke; If nil, revokes the whole weapon
-- @return -1 on failure, 0 if not found, 1 if successful
function RevokeWeapon(client, idx, wAmmo)
  
  if not idx then return (-1) end
  local uid = UID(client)
  local wpn = weaponsList[idx].mdl
  
  if CheckWeapon(client, idx) > 0 then
    if wAmmo then 
      
      -- SQL: Reduce ammo by `wAmmo`
      exports['ghmattimysql']:execute(
        "UPDATE weapons SET ammo = ammo - @a "..
        "WHERE character_id = @c AND hash = @h",
        {['a'] = wAmmo, ['c'] = uid, ['h'] = wpn}
      )
      
    else
      
      -- SQL: Delete the weapon
      exports['ghmattimysql']:execute(
        "DELETE FROM weapons WHERE character_id = @c AND hash = @h",
        {['c'] = uid, ['h'] = wpn}
      )
      
      -- Ensure client loses the weapon
      TriggerClientEvent('cnr:ammu_revoke_weapon', client, weaponsList[idx].mdl)
      
    end
    return 1
  end
  return 0
end


--- EXPORT: RevokeAllWeapons()
-- Revokes ALL weapons from the given player
-- @return True if successful; False if failed
function RevokeAllWeapons(client, isDead)
  if not client then return false end
  local uid = UID(client)
  if not uid then return false end
  exports['ghmattimysql']:execute(
    "DELETE FROM weapons WHERE character_id = @charid",
    {['charid'] = uid}
  )
  TriggerClientEvent('cnr:ammu_revoke_weapon', client, nil, nil, isDead)
  print(GetPlayerName(client).." [ID #"..client.."] has had all of their weapons revoked!")
  return true
end

AddEventHandler('cnr:imprisoned', function(ply)
  RevokeAllWeapons(ply, false, true)
end)


AddEventHandler('cnr:ammu_buyweapon', function(idx)
  
  local client = source
  local uid    = UID(client)
  
  if not idx then 
    TriggerClientEvent('chat:addMessage', client, {templateId = 'errMsg',
      multiline = true, args = {
        "AMMUNATION ERROR",
        "Weapon Index [nil] was not found."
      }
    })
    
  else
    if not weaponsList[idx] then 
      TriggerClientEvent('chat:addMessage', client, {templateId = 'errMsg',
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
  local uid    = UID(client)
  
  if not idx then 
    TriggerClientEvent('chat:addMessage', client, {templateId = 'errMsg',
      multiline = true, args = {
        "AMMUNATION ERROR",
        "Weapon Index [nil] was not found."
      }
    })
    
  else
    if not ct then ct = 1 end
    if not weaponsList[idx] then 
      TriggerClientEvent('chat:addMessage', client, {templateId = 'errMsg',
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
          TriggerClientEvent('cnr:ammu_authorize', client, idx, aCount)
          exports['cnr_cash']:CashTransaction(
            client, (0 - total)
          )
        end
      
      else
      
        -- Does the player have the bank funds to cover it?
        local bank = exports['cnr_cash']:GetPlayerBank(client)
        if bank >= total then
          if StoreWeapon(client, idx, aCount) then
            TriggerClientEvent('cnr:ammu_authorize', client, idx, aCount)
            exports['cnr_cash']:BankTransaction(
              client, (0 - total)
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

function RestoreWeapons(client)
  if not client then return false end
  exports['ghmattimysql']:execute(
    "SELECT * FROM weapons WHERE character_id = @charid",
    {['charid'] = UID(client)},
    function(weps)
      if weps[1] then 
        print("DEBUG - Found their weapons, restoring them.")
        TriggerClientEvent('cnr:ammu_restore', client, weps)
      else print("DEBUG - No weapons to restore.")
      end
      for k,v in pairs (weps) do 
        print("DEBUG - Restored "..
          GetWeaponNameFromHash(tonumber(v['hash'])).." ("..v['hash']..")"
        )
      end
    end
  )
end

AddEventHandler('cnr:client_loaded', function()
  local client = source
  print("DEBUG - Client #"..client.." has loaded in and wants to restore their weapons.")
  RestoreWeapons(client)
end)