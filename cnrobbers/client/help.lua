
local helpAlerts = true
local helpMessages = {
  "~r~Red circles~w~ on the map? A ~r~crate~w~ is waiting to be collected!",
  "Help with a job, controls or commands? Type ~y~/help~w~ for info.",
  "Go on/off ~b~police duty~w~ at anytime by entering a ~b~Police Station",
  "Bored? Why not rob a 24/7? Grab a gun and aim it at the clerk!",
  "Rob an ~g~ATM ~w~by smashing it with a melee weapon!",
  "Need clean cash on the side? Try fishing or hunting!",
  "Try out some legal jobs at one of the briefcases on the map!"
}


RegisterCommand('help', function()
  SendNUIMessage({show = 'help-main'})
  SetNuiFocus(true, true)
end)


RegisterCommand('togglehelp', function()
  helpAlerts = not helpAlerts
  if helpAlerts then
    ChatNotification("CHAR_SOCIAL_CLUB", "System Help",
    "/togglehelp", "~g~ENABLED")
  else
    ChatNotification("CHAR_SOCIAL_CLUB", "System Help",
    "/togglehelp", "~r~DISABLED")
  end
end)


Citizen.CreateThread(function()
  local helpNum = math.random(#helpMessages)
  while true do 
    ChatNotification("CHAR_SOCIAL_CLUB", "~y~System Help",
    "/togglehelp", helpMessages[helpNum])
    helpNum = helpNum + 1
    if helpNum > #helpMessages then helpNum = 1 end
    Citizen.Wait(300000)
  end
end)


RegisterNUICallback("helpMenu", function(data, callback)
  if data.action == "action" then

  -- All other actions default to exit/close
  else
    SendNUIMessage({hide = 'help-main'})
    SetNuiFocus(false)

  end
  
  
end)