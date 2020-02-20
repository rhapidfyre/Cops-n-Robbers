
-- Config (Server)
RegisterServerEvent('cnr:police_stations_req')

--- LoadPoliceStations()
-- Sends list of valid police stations to player (if given) or all players
-- @param client The client to send it to. Defaults to all clients if nil
local function LoadPoliceStations(client)
  
  -- SQL: Return list of all stations that are law enforcement related
  exports['ghmattimysql']:execute(
    "SELECT st.cams,st.zone,st.id,st.agency_id,st.x,st.y,st.z,st.duty_point,a.blip_color,a.blip_sprite "..
    "FROM stations st LEFT JOIN agencies a ON a.id = st.agency_id WHERE a.perms & 1",
    {}, function(stationList)
      local src = client
      if not src then src = (-1) end
      TriggerClientEvent('cnr:police_stations', src, stationList)
    end
  )
  
end


-- Used to trigger LoadPoliceStations()
AddEventHandler('cnr:client_loaded', function()
  local client = source
  LoadPoliceStations(client)
end)


-- Used to trigger LoadPoliceStations() on resource restart
Citizen.CreateThread(function()
  Citizen.Wait(5000)
  LoadPoliceStations()
end)

AddEventHandler('cnr:police_stations_req', function(stNumber)
  local client = source
  if stNumber then
    if stNumber > 0 then
    
      -- SQL: Return station information (armory, vehicles, etc)
      exports['ghmattimysql']:execute(
        "SELECT * FROM stations WHERE id = @n", {['n'] = stNumber},
        function(stationInfo)
          if not stationInfo then stationInfo = {}    end
          if not client      then client      = (-1)  end
          TriggerClientEvent('cnr:police_station_info', client, stationInfo[1])
        end
      )
    
    end -- stNumber > 0
  end -- stNumber
end)