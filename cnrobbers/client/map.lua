
local largeMap = false




local function ToggleBigMap()
  largeMap = not largeMap
  SetRadarBigmapEnabled(largeMap, false)
  TriggerEvent('cnr:bigmap', largeMap)
end

AddEventHandler('cnr:close_all_nui', function()
  largeMap = false
  SetRadarBigmapEnabled(largeMap, false)
  TriggerEvent('cnr:bigmap', false)
end)


RegisterCommand('bigmap', ToggleBigMap)
RegisterKeyMapping('bigmap', 'Expand Map', 'keyboard', 'shift')