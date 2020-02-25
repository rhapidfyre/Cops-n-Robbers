
--[[
  Cops and Robbers: Inventory Script - Client Primary Script
  Created by Michael Harris ( mike@harrisonline.us )
  02/24/2020

  This file contains all inventory related information as well as
  interfaces. Adding, removing, manipulating items as well as 24/7 purchasing
--]]

local menuEnabled = false
local toggle_inv = 288 -- F1

-- Returns truth value of whether the player should be 
-- allowed/able to use the inventory menu
local function IsInventoryAccessible()

  if IsPauseMenuActive() then
    print("Cannot open CNR Inventory with the pause menu open.")
    return false
  elseif exports['chat']:IsTyping() then
    print("Cannot open CNR Inventory while chatting.")
    return false
  elseif IsPedDeadOrDying(PlayerPedId()) then
    print("Cannot open CNR Inventory while dead.")
    return false
  end
  
  return true
end

Citizen.CreateThread(function()
  while true do 
  
    -- While the menu is OPEN
    if menuEnabled then 
    
      -- If player pauses, dies, or the chat box opens, close menu
      if not IsInventoryAccessible() then
        CloseInventory()
        
      end
    
    -- While the menu is CLOSED
    else
      if IsControlJustPressed(0, toggle_inv) then 
        if IsInventoryAccessible() then
          if not menuEnabled then
            OpenInventory()
          end
        else Citizen.Wait(999)
        end
      end
    
    end
    Citizen.Wait(1)
  end
end)


function CloseInventory()
  print("DEBUG - Closing Inventory.")
  SendNUIMessage({hideinv = true})
  SetNuiFocus(false)
  menuEnabled = false
end


function OpenInventory()
  print("DEBUG - Opening Inventory.")
  menuEnabled = true
  SendNUIMessage({showinv = true})
  SetNuiFocus(true, true)
end

-- Emergency Close / Menu's are Stuck
AddEventHandler('cnr:close_all_nui', function()
  CloseInventory()
end)


RegisterNUICallback('inventoryActions', function(data, callback)
  
  if data.action == "exit" then
    CloseInventory()
  
  elseif data.action == "doAction" then 
    
  
  --elseif data.action == "quantity" then 
    
  
  end
  
end)