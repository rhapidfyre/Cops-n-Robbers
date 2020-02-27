
RegisterServerEvent('cnr:stores_start')


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