
--- ConsolePrint()
-- Nicely formatted console print with timestamp
-- @param msg The message to be displayed
function ConsolePrint(msg)
  if msg then
    local dt = os.date("%H:%M", os.time())
    print("[CNR "..dt.."] ^7"..(msg).."^7")
  end
end
AddEventHandler('cnr:print', ConsolePrint)
AddEventHandler('cnr:cprint', ConsolePrint)