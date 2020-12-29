
Citizen.CreateThread(function()

  -- Don't allow any scripts to execute until the metatable exists
  while not CNR.activeZone do Wait(100) end
  CNR.ready = true
  
  TriggerEvent('chat:addTemplate', 'crimeMsg',
    '<font color="#F80"><b>CRIME COMMITTED:</b></font> {0}'
  )
  TriggerEvent('chat:addTemplate', 'levelMsg',
    '<font color="#F80"><b>WANTED LEVEL:</b></font> {0} - ({1})'
  )
  
end)