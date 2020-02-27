
RegisterNetEvent('cnr:stores_start')
RegisterNetEvent('cnr:stores_usage')

local menuEnabled = false
local near = 0


local function BuildStoreItems()
  local htmlTable = {}
  for k,v in pairs (storeItems) do 
    table.insert(htmlTable,
      '<div class="item" id="i'..k..'"><img src="img/'..(v["img"])..'.png">'..
      '<span class="iname">'..(v["title"])..'</span></div>'
    )
  end
  SendNUIMessage({storeitems = table.concat(htmlTable)})
end


AddEventHandler('cnr:close_all_nui', function()
  SendNUIMessage({hidestore = true})
  SetNuiFocus(false)
  TriggerServerEvent('cnr:stores_start', near, false)
  menuEnabled = false
end)


AddEventHandler('cnr:stores_usage', function(client, n, usage)
  stores[n].inUse = usage
  if usage then
    if usage == GetPlayerServerId(PlayerId()) then
      BuildStoreItems()
      SendNUIMessage({showstore = true, storetitle = stores[n].title})
      SetNuiFocus(true, true)
    end
  end
end)

Citizen.CreateThread(function()

  while true do 
    if near > 0 then 
      local stPos = stores[near].pos
      DrawMarker(1, stPos.x, stPos.y, stPos.z - 1.12,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        1.4, 1.4, 0.4, 0, 255, 0, 120,
        false, false, 0, false
      )
      DrawMarker(29, stPos.x, stPos.y, stPos.z + 0.2,
        0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
        0.8, 0.8, 0.8, 255, 180, 0, 255,
        false, false, 0, true
      )
      if IsControlJustPressed(0, 38) then 
        if not stores[near].inUse then
          if #(GetEntityCoords(PlayerPedId()) - stPos) < 2.25 then
            TriggerServerEvent('cnr:stores_start', near, true)
            Citizen.Wait(3000)
          end
        else
          TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
            args = {"Wait your turn! Somebody else is shopping here right now."}
          })
        end
      end
    else
      Citizen.Wait(2000)
    end
    Citizen.Wait(0)
  end
end)


Citizen.CreateThread(function()

  SetNuiFocus(false) -- DEBUG
  
  Citizen.Wait(2000)
  while true do 
    local myPos = GetEntityCoords(PlayerPedId())
    local cDist = math.huge
    
    if near > 0 then 
      if #(myPos - stores[near].pos) > 80.0 then 
        near = 0
      end
    end
    
    -- Find closest store
    if near == 0 then
      for k,v in pairs (stores) do 
        local vPos = v.pos
        local dist = #(myPos - vPos)
        if dist < cDist and dist < 60.0 then cDist = dist; near = k end
        Citizen.Wait(10)
      end
    end
    
    Citizen.Wait(10)
  end
end)


local nextPurchase = 0
RegisterNUICallback("storeMenu", function(data, callback)
  if data.action == "exit" then 
    TriggerServerEvent('cnr:stores_start', near, false)
    SendNUIMessage({hidestore = true})
    SetNuiFocus(false)
  
  elseif data.action == "purchase" then 
    local n = tonumber(data.qty)
    local i = tonumber(data.item)
    if not storeItems[i] then
      TriggerEvent('chat:addMessage', {templateId = 'errMsg', args = {
        "Store Error: 15342",
        "An error occured when purchasing that item. Contact Administration."
      }})
    else
      local item = storeItems[i]
      if nextPurchase > GetGameTimer() then 
        TriggerEvent('chat:addMessage', {templateId = 'sysMsg', args = {
          "Stop impulse-buying! You must wait "..
          math.ceil((nextPurchase - GetGameTimer())/1000)..
          " seconds to buy something."
        }})
      else
        nextPurchase = GetGameTimer() + 4999
        TriggerServerEvent('cnr:stores_purchase', i, n)
      end
    end
  
  elseif data.action == "viewItem" then 
    local i = tonumber(data.iNum)
    if not storeItems[i] then
      TriggerEvent('chat:addMessage', {templateId = 'errMsg', args = {
        "Store Error: 15343",
        "An error occured when selecting that item. Contact Administration."
      }})
      SendNUIMessage({
        buyenable = false
      })
    else
      SendNUIMessage({
        buyenable = true,
        iteminfo = true,
        itemName = storeItems[i].title,
        itemCost = "$"..(storeItems[i].price)
      })
    end
  
  end
end)

