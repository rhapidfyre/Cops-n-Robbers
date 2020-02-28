
--[[
  Cops and Robbers: Death Scripts (SERVER)
  Created by Michael Harris (mike@harrisonline.us)
  08/26/2019

  Handles all death events, and life saving/resurrection type scripting.
--]]

RegisterServerEvent('cnr:death_check')
RegisterServerEvent('cnr:death_noted')
RegisterServerEvent('cnr:player_death')
RegisterServerEvent('cnr:death_buy_insurance')


local hiCost = 25000

AddEventHandler('cnr:death_buy_insurance', function()
  local client = source
  local uid    = exports['cnrobbers']:UniqueId(client)
  
  exports['ghmattimysql']:scalar(
    "SELECT insured FROM characters WHERE idUnique = @u",
    {['u'] = uid},
    function(isInsured)
      if isInsured then 
        TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg', args = {
          "You already have Health Insurance!"
        }})
      else
        local cash = exports['cnr_cash']:GetPlayerCash(client)
        local bank = exports['cnr_cash']:GetPlayerBank(client)
        if cash >= hiCost or bank >= hiCost then 
          if cash >= hiCost then
            exports['cnr_cash']:CashTransaction(client, (0 - hiCost))
            TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg', args = {
              "You have purchased Health Insurance! (Paid $^2"..hiCost.."^7 from cash)"
            }})
            
          else
            exports['cnr_cash']:BankTransaction(client, (0 - hiCost))
            TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg', args = {
              "You have purchased Health Insurance! (Paid $^2"..hiCost.."^7 from bank)"
            }})
          
          end
          TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg', args = {
            "You will retain your personal belongings next time you die."
          }})
          
          exports['ghmattimysql']:execute(
            "UPDATE characters SET insured = 1 WHERE idUnique = @u",
            {['u'] = uid}
          )
        
        else
          TriggerClientEvent('chat:addMessage', client, {templateId = 'sysMsg', args = {
            "You cannot afford to buy Health Insurance! (Costs $^1"..hiCost.."^7)"
          }})
        
        end
      end
    end
  )
  
end)


-- Check if the death was a crime, and then notify the players
AddEventHandler('cnr:death_check', function(killer)

  local victim = source
  local dMessage = GetPlayerName(victim).." died"
  if killer then
    if killer ~= victim then
      local isCop = exports['cnr_police']:DutyStatus(killer)
      if not isCop then
        print("DEBUG - cnr:death_check determined MURDER.")
        dMessage = GetPlayerName(killer).." killed "..GetPlayerName(victim)
        exports['cnr_wanted']:WantedPoints(killer, 'murder', true)
        local uid = exports['cnrobbers']:UniqueId(killer)
        if killer then
          exports['ghmattimysql']:execute(
            "UPDATE characters SET kills = kills + 1 WHERE idUnique = @uid",
            {['uid'] = uid}
          )
        end
      else
      
        -- If victim was not a wanted person
        local wLevel = exports['cnr_wanted']:WantedLevel(victim)
        if wLevel > 3 then 
          dMessage = GetPlayerName(killer).." neutralized "..GetPlayerName(victim)
          print("DEBUG - cnr:death_check determined JUSTIFIED POLICE SHOOTING.")
        
        else
        
          dMessage = GetPlayerName(killer).." unjustly killed "..GetPlayerName(victim)
          print("DEBUG - cnr:death_check determined UNJUSTIFIED POLICE SHOOTING")
          
          local msgg = GetPlayerName(victim).." for a ticket-only offense."
          if wLevel < 1 then
            msgg = GetPlayerName(victim)..", an innocent civilian."
          end
          exports['cnr_admin']:AdminMessage(
            "Officer "..GetPlayerName(killer).." killed "..msgg
          )
        
        end
      end
    else
      dMessage = GetPlayerName(victim).." killed themselves."
      print("DEBUG - cnr:death_check determined SUICIDE.")
    end
    TriggerClientEvent('cnr:death_notify', (-1), victim, killer)
  end
  exports['cnrobbers']:ConsolePrint(dMessage)
  exports['cnr_chat']:DiscordMessage(9807270, dMessage, "", "")
end)


-- Just note the death and notify the players
AddEventHandler('cnr:death_noted', function(killer)
  local dMessage = GetPlayerName(victim).." died"
  exports['cnrobbers']:ConsolePrint(dMessage)
  exports['cnr_chat']:DiscordMessage(9807270, dMessage, "", "")
  TriggerClientEvent('cnr:death_notify', (-1), source, killer)
end)


AddEventHandler('cnr:player_death', function()

  local client = source
  local uid    = exports['cnrobbers']:UniqueId(client)
  
  exports['ghmattimysql']:scalar(
    "SELECT PlayerDeath(@uid)",
    {['uid'] = uid},
    function(retValue)
      TriggerEvent('cnr:death_insured', client, retValue)
      TriggerClientEvent('cnr:death_insurance', client, retValue)
    end
  )
  
end)


AddEventHandler('cnr:client_loaded', function()
  local client = source
  local uid    = exports['ghmattimysql']:UniqueId(client)
  
  exports['ghmattimysql']:execute(
    "SELECT insured FROM characters WHERE idUnique = @u",
    {['u'] = uid},
    function(isInsured)
      if isInsured then 
        TriggerClientEvent('cnr:death_has_insurance', client)
      end
    end
  )
  
end)