
-- cl admin
RegisterNetEvent('cnr:admin_assigned')
local aLevel = 1
local aid    = 0

RegisterCommand('checkadmin', function()
  TriggerServerEvent('cnr:admin_check')
end)

AddEventHandler('cnr:admin_assigned', function(aNumber)
  aid = aNumber
  TriggerEvent('chat:addMessage', {templateId = 'sysMsg',
    args = {"^2Successfully logged in as admin. ID Assigned: ^7"..aid}
  })
end)