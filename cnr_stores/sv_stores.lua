
RegisterServerEvent('cnr:stores_start')
RegisterServerEvent('cnr:stores_purchase')


local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end


AddEventHandler('cnr:stores_start', function(n, useStore)
  local client = source
  
  if not stores[n].inUse then
    if useStore then
      stores[n].inUse = client
    end
    
  else
    if not useStore then 
      stores[n].inUse = nil
    end
    
  end
  
  TriggerClientEvent('cnr:stores_usage', (-1), client, n, stores[n].inUse)
  
end)


-- If a player quits while shopping we need to free up their spot
AddEventHandler('playerDropped', function(reason)
  local client = source
  for k,v in pairs(stores) do
    if v.inUse then 
      if v.inUse == client then 
        v.inUse = nil
      end
    end
  end
end)


AddEventHandler('cnr:stores_purchase', function(i, n)
  local client = source
  local item = storeItems[i]
  
  -- Check if player has the funds
  local buyFlag = 0 -- 0:No Funds 1:UseCash 2:UseBank
  local useBank = false
  local bal = exports['cnr_cash']:GetPlayerCash(client)
  
  if bal < (item.price * n) then
    bal = exports['cnr_cash']:GetPlayerBank(client)
    if bal < (item.price * n) then 
      buyFlag = 2
    end
  else
    buyFlag = 1
  end
  
  if buyFlag > 0 then
    -- If they can afford it, submit it to 'cnr_inventory' & deduct price
    item['resname'] = "cnr_stores"
    local success = exports['cnr_inventory']:ItemAdd(client, item, n)
    if success then 
      if buyFlag == 1 then 
        exports['cnr_cash']:CashTransaction(client, (0 - (item.price * n)))
      else
        exports['cnr_cash']:BankTransaction(client, (0 - (item.price * n)))
      end
      TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg', args = {
        "Purchased "..(n).." "..(item.title).." for ^2$"..(item.price * n).."^7."
      }})
      
    else
      cprint("^1[STORES] ^7Failed to add item "..(item.title).." to "..
        GetPlayerName(client).."'s (#"..client..") inventory."..
        "They were NOT charged for the purchase"
      )
    end
  
  else
    TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg', args = {
      "You can't afford to buy ^2"..(item.title).." ^7(Costs $^1"..(item.price).."^7)"
    }})
  end
end)