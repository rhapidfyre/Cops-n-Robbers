
-- Config (Server)


--- LoadPoliceStations()
-- Sends list of valid police stations to player (if given) or all players
-- @param client The client to send it to. Defaults to all clients if nil
local function LoadPoliceStations(client)
  
  -- SQL: Return list of all stations that are law enforcement related
  local stations = exports['ghmattimysql']:execute(
    "SELECT st.id,st.agency_id,st.x,st.y,st.z,a.blip_color,a.blip_sprite "..
    "FROM stations st LEFT JOIN agencies a ON a.id = st.agency_id WHERE a.perms & 1",
    {}, function(stationList)
      local src = client
      if src then 
        TriggerClientEvent('cnr:police_stations', (-1), stationList)
      else
        local clients = GetPlayers()
        for _,client in ipairs (clients) do 
          TriggerClientEvent('cnr:police_stations', client, stationList)
        end
      end
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