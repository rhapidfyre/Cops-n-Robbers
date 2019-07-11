
--[[
  Cops and Robbers: Character Creation (CLIENT)
  Created by Michael Harris (mike@harrisonline.us)
  05/11/2019
  
  This file handles all client-sided interaction to verifying character
  information, switching characters, and creating characters.
  
  Permission is granted only for executing this script for the purposes
  of playing the gamemode as intended by the developer.
--]]

local cam

-- Handles joining the server
Citizen.CreateThread(function()
  
	  exports.spawnmanager:spawnPlayer({
	  	x = cams.start.ped.x,
	  	y = cams.start.ped.y,
	  	z = cams.start.ped.z + 1.0,
	  	model = "mp_m_freemode_01"
	  }, function()
	  	SetPedDefaultComponentVariation(PlayerPedId())
      print("DEBUG - Spawned Player!")
	  end)
    
  local c = cams.start
	if not DoesCamExist(cam) then cam = CreateCam('DEFAULT_SCRIPTED_CAMERA', true) end
	SetCamActive(cam, true)
	RenderScriptCams(true, true, 500, true, true)
	SetCamParams(cam,
    c.view.x, c.view.y, c.view.z,
    c.rotx, c.roty, c.h,
    50.0
  )
  
  TriggerServerEvent('cnr:create_player')
  
end)