
-- config (client)

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