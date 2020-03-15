
-- config (client)

local cacheMessages = { -- Crate Event
  "Found a drop, sent it to your GPS. Others will be looking for it, too.",
  "Got a hit on a drop, it's on your GPS. Better find it before someone else.",
  "Drop Located. Sent coords to your GPS. First come first serve, get going.",
  "Got another hit on a drop, better get moving. You're not alone.",
  "Another drop coming your way, better get on it."
}

function RandomCacheMessage()
  return cacheMessages[math.random(#cacheMessages)]
end

-- Draws text on screen as positional
function DrawText3D(x, y, z, text) 
  SetDrawOrigin(x, y, z, 0);
  BeginTextCommandDisplayText("STRING")
  SetTextScale(0.3, 0.3)
  SetTextFont(0)
  SetTextProportional(1)
  SetTextColour(80, 255, 80, 140)
  SetTextDropshadow(0, 0, 0, 0, 140)
  SetTextEdge(2, 0, 0, 0, 150)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(1)
  AddTextComponentString(text)
  DrawText(0.0, 0.0)
  ClearDrawOrigin()
end