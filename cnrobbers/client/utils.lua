
--- EXPORT GetClosestPlayer()
-- Finds the closest player
-- @return Player local ID. Must be turned into a ped object or server ID from there.
function GetClosestPlayer()
	local ped  = PlayerPedId()
	local plys = GetActivePlayers()
	local cPly = 0
	local cDst = 80.0
	for _,i in ipairs (plys) do
		local tgt = GetPlayerPed(i)
		if tgt ~= ped then
			local dist = GetDistanceBetweenCoords(GetEntityCoords(ped), GetEntityCoords(tgt))
			if cDst > dist then
				cPly = i;	cDst = dist
			end
		end
	end
	return cPly
end