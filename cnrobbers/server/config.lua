
SetGameType('5M Cops and Robbers')

Citizen.CreateThread(function()
  
  while not CNR do Wait(1) end
  
  CNR.SQL = {
  
    -- Execute and Forget
    -- Executes 'cb' (callback) function on result with result as argument
    -- Script doesn't wait for a response/result
    EXECUTE = function(query,tbl,cb)
      if not query then return error("No querystring given to CNR.SQL.") end
      if not tbl then tbl = {} end
      exports['ghmattimysql']:execute(query, tbl,
        function(result) if cb then cb(result) end end
      )
    end,
    
    -- As EXECUTE
    -- Script waits for a response
    QUERY = function(query,tbl)
      if not query then return error("No querystring given to CNR.SQL.") end
      if not tbl then tbl = {} end
      return ( exports['ghmattimysql']:executeSync(query, tbl) )
    end,
    
    -- Fetches first column of the first row
    -- Executes 'cb' (callback) function on result with result as argument
    -- Runs without waiting on a return
    SCALAR = function(query,tbl,cb)
      if not query then return error("No querystring given to CNR.SQL.") end
      if not tbl then tbl = {} end
      exports['ghmattimysql']:scalar(query, tbl,
        function(result) p:resolve(result); if cb then cb(result) end end
      )
    end,
    
    -- As SCALAR
    -- Script waits for a response
    RSYNC = function(query,tbl)
      if not query then return error("No querystring given to CNR.SQL.") end
      if not tbl then tbl = {} end
      return ( exports['ghmattimysql']:scalarSync(query, tbl) )
    end
    
  }
  
  CNR.unique      = {} -- Unique ID Assignments
  
  -- Playzone Information
  CNR.zones = {
  
      -- The currently active zone
      active  = math.random(Config.GetNumberOfZones()),
      count   = Config.GetNumberOfZones(),
      pick    = Config.MinutesPerZone() * (os.time() * 60), -- os.time() is in seconds
      timer   = Config.MinutesPerZone() * (os.time() * 60)  -- os.time() is in seconds
      
  }

  TriggerClientEvent('cnr:active_zone', (-1), CNR.zones.active)
  CNR.ready = true
  
  ConsolePrint("Metatable configuration complete. The game is now ready!")
  ConsolePrint("Zone "..(CNR.zones.active).." is the active zone!")
  
end)

