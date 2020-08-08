
-- Client Main

AddEventHandler('onResourceStop', function(rn)
  restarted[rn] = true
end)

AddEventHandler('playerSpawned', function()
  SetCanAttackFriendly(PlayerPedId(), true, true)
  NetworkSetFriendlyFireOption(true)
end)

AddEventHandler('onResourceStart', function(rn)
  if restarted[rn] then
    if debugging then
      TriggerEvent('chat:addMessage', {args={
        "The ^3"..rn.." ^7resource has been restarted!"
      }})
    end
  end
end)

