
RegisterServerEvent('cnr:stores_purchase')
RegisterServerEvent('cnr:lotto_purchase')
RegisterServerEvent('cnr:stores_start')


local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local lotto = {
  interval = 10, -- Minutes between lotto drawings
  starting = 250000,
  increase = function() return (math.random(25, 100) * 1000) end,
  timer    = 0,
  mini     = 1,  -- Minimum number possibility
  maxi     = 10, -- Maximum number possibility
  lockout  = false, -- Prevent people from buying a ticket
  players  = {}
}

AddEventHandler('cnr:lotto_purchase', function(ticketType)
  local client = source
  
  -- Scratcher
  if ticketType == 0 then 
    
  -- Lotto Drawing, where ticketType is their chosen number
  else
    if lotto.lockout then 
      TriggerClientEvent('chat:addMessage', client, {templateId = 'lotto', args = {
        "You can't submit a ticket when a drawing is about to start!"
      }})
      
    else
      local taken = false
      for ply,v in pairs (lotto.players) do 
        if v.draw == ticketType then 
          taken = true
        end
      end
      
      if not taken then 
        TriggerClientEvent('chat:addMessage', client, {templateId = 'lotto', args = {
          "Someone has chosen that number already!"
        }})
      else
        TriggerClientEvent('chat:addMessage', client, {templateId = 'lotto', args = {
          "Your lotto drawing number has been registered: "..ticketType
        }})
        lotto.players[client] = ticketType
      end
    end
  end
end)


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
    if bal >= (item.price * n) then print("DEBUG - Using Bank."); buyFlag = 2 end
  else print("DEBUG - Using Cash."); buyFlag = 1
  end
  
  if buyFlag > 0 then
    -- If they can afford it, submit it to 'cnr_inventory' & deduct price
    item['resname'] = "cnr_stores"
    local success = exports['cnr_inventory']:ItemAdd(client, item, n)
    if success then 
      if buyFlag == 1 then exports['cnr_cash']:CashTransaction(client, (0 - (item.price * n)))
      else                 exports['cnr_cash']:BankTransaction(client, (0 - (item.price * n)))
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


Citizen.CreateThread(function()
  Citizen.Wait(1000)
  lotto.timer = GetGameTimer() + (1000 * 60 * lotto.interval)
  while true do
    if lotto.timer > GetGameTimer() then
      
      TriggerClientEvent('cnr:chat_notification', (-1),
        "CHAR_SOCIAL_CLUB", "5M-CNR Lottery",
        "Drawing Soon",
        "~y~5 ~w~Minutes until the draw! Get your ticket at ~y~24/7~w~!"
      )
      
      Citizen.Wait(3000)
    
      lotto.lockout = true
      TriggerClientEvent('cnr:chat_notification',
        "CHAR_SOCIAL_CLUB", "5M-CNR Lottery",
        "Drawing Now",
        "Lottery ~r~CLOSED~w~! Drawing in ~y~30 ~w~seconds."
      )
      
      Citizen.Wait(1000)
      
      local jackpot = math.random(lotto.mini, lotto.maxi)
      local winner  = 0
      for ply,drawNumber in pairs (lotto.players) do 
        if drawNumber == jackpot then winner = ply end
      end
      
      if winner > 0 then 
        lotto.pot = lotto.starting
        exports['cnr_cash']:BankTransaction(winner, lotto.pot)
        
      else
        lotto.pot = lotto.pot + lotto.increase()
        
      end
      
      TriggerClientEvent('cnr:lotto_drawing', (-1), jackpot, winner, lotto.pot)
      
      lotto.timer   = GetGameTimer() + (1000 * 60 * lotto.interval)
      lotto.players = {}
      lotto.lockout = false
    end
    Citizen.Wait(1000)
  end
end)