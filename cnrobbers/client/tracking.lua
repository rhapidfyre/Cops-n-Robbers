
-- blip Colors by wanted level
local bColors = {
  [0]   = 0,  [1] = 36, [2] = 36, [3] = 36,
  [4]   = 5,  [5] =  5, [6] =  5,
  [7]   = 17, [8] = 81, [9] = 47, [10] = 51,
  [11]  = 1
}

local copColor = 38

Citizen.CreateThread(function()
  while true do
    for _,i in ipairs (GetActivePlayers()) do
      local ply   = tonumber(i)
      local pped  = GetPlayerPed(ply)
      if DoesEntityExist(pped) and pped ~= ped then
      
        local svid = GetPlayerServerId(ply)
        local isCop = CNR.police[svid]
        local wl    = CNR.wanted[svid]
        if not wl then wl = 0 end
        
        -- if blip doesn't exist, create it
        local gBlip = GetBlipFromEntity(pped)
        if not DoesBlipExist(gBlip) then
          local temp  = AddBlipForEntity(pped)
          SetBlipScale(temp, 0.72)
          SetBlipDisplay(temp, 2)
          SetBlipCategory(temp, 7)
          if isCop then SetBlipColour(temp, 26)
          elseif wl > 0 then
          else SetBlipColour(temp, 0)
          end
          
        -- if blip does exist, change color accordingly
        else
          local gbCol = GetBlipColour(gBlip)
          if isCop then
            if gbCol ~= copColor then SetBlipColour(gBlip, copColor) end
          else
            if GetBlipColour(gBlip) ~= bColors[wl] then
              SetBlipColour(gBlip, bColors[wl])
            end
          end
        end
      end
    end
    Citizen.Wait(100)
  end
end)