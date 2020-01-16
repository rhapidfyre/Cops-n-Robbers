
-- client cfg
function CommandInvalid(cmd)
  TriggerEvent('chat:addMessage', {templateId = 'errMsg',
    args = {"INVALID COMMAND", cmd}
  })
end