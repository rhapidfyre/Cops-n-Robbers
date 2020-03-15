
RegisterServerEvent('cnr:stores_purchase')
RegisterServerEvent('cnr:lotto_choice')
RegisterServerEvent('cnr:stores_start')
RegisterServerEvent('cnr:consume_sv')
RegisterServerEvent('cnr:death_insured')


local cprint = function(msg) exports['cnrobbers']:ConsolePrint(msg) end
local lotto = {
  interval = 30, -- Minutes between lotto drawings
  waitTime = 5,  -- Minutes until drawing locks
  pot      = 50000,
  starting = 50000,
  increase = function() return (math.random(25, 100) * 1000) end,
  timer    = 0,
  mini     = 1,  -- Minimum number possibility
  maxi     = 30, -- Maximum number possibility
  lockout  = false, -- Prevent people from buying a ticket
  players  = {}
}

local scratcher = {
  {cash = 4000,  beat = 997},
  {cash = 2500,  beat = 995},
  {cash = 1250,  beat = 990},
  {cash = 450,   beat = 988},
  {cash = 300,   beat = 944},
  {cash = 200,   beat = 988},
  {cash = 150,   beat = 962},
  {cash = 100,   beat = 788},
  {cash = 50,    beat = 690}
}

AddEventHandler('cnr:death_insured', function(client, isInsured)
  if isInsured < 1 then 
    if lotto.players[client] then 
      lotto.players[client] = nil
      TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg', args = {
        "Your lotto number has been unregistered due to your death!"
      }})
    end
  end
end)

AddEventHandler('cnr:consume_sv', function(client, itemName)
  if itemName == "lotto_scratcher" then
    print("DEBUG - Consuming a scratcher")
    local chance = math.random(1, 1000)
    local prize  = 0
    if chance == 1000 then 
      prize = 25000
    else
      for _,info in pairs (scratcher) do 
        if info.beat > chance then prize = info.cash end
      end
    end
    
    if prize > 0 then 
      if chance == 1000 then
        TriggerClientEvent('chat:addMessage', client, {templateId = 'lotto', args = {
          "^3GRAND PRIZE^7! Your won^2 $"..prize.."^7! Return it to any 24/7 for your prize!"
        }})
      else
        TriggerClientEvent('chat:addMessage', client, {templateId = 'lotto', args = {
          "Your scratcher wins^2 $"..prize.."^7! Return it to any 24/7 for your prize!"
        }})
      end
      local retValue = exports['cnr_inventory']:ItemAdd(client, {
        ['name']    = "lotto_winnings",
        ['title']   = "Winning Scratcher",
        ['resname'] = "cnr_stores",
        ['img']     = "scratchers",
        ['stack']   = 1
      }, prize)
      print("DEBUG - ItemAdd returned "..tostring(retValue))
    else
      TriggerClientEvent('chat:addMessage', client, {templateId = 'lotto', args = {
        "Your scratcher lost.. Better luck next time!"
      }})
      
    end
    
  end
end)


AddEventHandler('cnr:lotto_choice', function(ticketType)
  local client = source
  local failed = false
  print("DEBUG - Player #"..client.." chose lotto number "..ticketType)
  if lotto.lockout then 
    TriggerClientEvent('chat:addMessage', client, {templateId = 'lotto', args = {
      "You can't submit a ticket when a drawing is about to start!"
    }})
    failed = true
  else
  
    if ticketType <= lotto.maxi and ticketType >= lotto.mini then
  
      local taken = false
      for ply,v in pairs (lotto.players) do 
        if v.draw == ticketType then 
          taken = true
        end
      end
      
      if not taken then 
        TriggerClientEvent('chat:addMessage', client, {templateId = 'lotto', args = {
          "Your lotto drawing number has been registered: "..ticketType
        }})
        lotto.players[client] = ticketType
        
      else
        TriggerClientEvent('chat:addMessage', client, {templateId = 'lotto', args = {
          "Someone has chosen that number already!"
        }})
        failed = true
        
      end
    else
      TriggerClientEvent('chat:addMessage', client, {templateId = 'lotto', args = {
        "Sorry, only numbers ^3"..(lotto.mini).." thru "..(lotto.maxi).." are valid for this drawing!"
      }})
      failed = true
    end
  end
  if failed then
    print("DEBUG - Choice Rejected.")
    exports['cnr_inventory']:ItemAdd(client, {
      ['name']    = "lotto_ticket",
      ['title']   = "Lotto Ticket",
      ['resname'] = "cnr_stores",
      ['img']     = "lotto_ticket"
    })
    TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg', args = {
      "Your lotto ticket has been returned to your inventory."
    }})
  else
    print("DEBUG - Choice Accepted.")
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
  
  -- Cash in lotto winnings
  exports['ghmattimysql']:scalar(
    "SELECT LottoTurnin(@uid)",
    {['uid'] = exports['cnrobbers']:UniqueId(client)},
    function(winnings)
      if winnings then
        print("DEBUG - Cashing in $"..winnings.." of lotto winnings.")
        exports['cnr_cash']:CashTransaction(client, winnings)
        exports['cnr_inventory']:UpdateInventory(client)
      else
        print("DEBUG - No Lotto Winnings found for Player #"..client)
      end
    end
  )
  
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
  lotto.timer = GetGameTimer() + (60000 * lotto.interval)
  while true do
    if lotto.timer < GetGameTimer() then
      cprint("The lottery will draw the winning number in "..(lotto.waitTime).." minutes!")
      TriggerClientEvent('cnr:chat_notification', (-1),
        "CHAR_SOCIAL_CLUB", "5M-CNR Lottery",
        "Drawing Soon",
        "~y~"..(lotto.waitTime).." ~w~Minutes until the draw! Get your ticket at ~y~24/7~w~!"
      )
      
      Citizen.Wait(1000 * (lotto.waitTime))
    
      lotto.lockout = true
      cprint("The lottery is locked from receiving new numbers!")
      TriggerClientEvent('cnr:chat_notification', (-1),
        "CHAR_SOCIAL_CLUB", "5M-CNR Lottery",
        "Drawing Now",
        "Lottery ~r~CLOSED~w~! Drawing in ~y~1 minute!"
      )
      
      Citizen.Wait(2000)
      
      local jackpot = math.random(lotto.mini, lotto.maxi)
      local winner  = 0
      for ply,drawNumber in pairs (lotto.players) do 
        if drawNumber == jackpot then winner = ply end
      end
      
      cprint("The winning number is "..jackpot.."!")
      if winner > 0 then 
        lotto.pot = lotto.starting
        cprint("Player #"..winner.." wins the lotto jackpot of $"..(lotto.pot).."!")
        exports['cnr_cash']:BankTransaction(winner, lotto.pot)
        
      else
        lotto.pot = lotto.pot + lotto.increase()
        
      end
      
      TriggerClientEvent('cnr:lotto_drawing', (-1), jackpot, winner, lotto.pot)
      
      lotto.timer   = GetGameTimer() + (60000 * lotto.interval)
      lotto.players = {}
      lotto.lockout = false
    end
    Citizen.Wait(1000)
  end
end)