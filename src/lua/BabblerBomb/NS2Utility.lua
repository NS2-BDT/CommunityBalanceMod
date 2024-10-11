local loadBombler = true
local oldGetTexCoordsForTechId = GetTexCoordsForTechId
function GetTexCoordsForTechId(techId)
	if loadBombler and gTechIdPosition then
		gTechIdPosition[kTechId.BabblerBombAbility] = kDeathMessageIcon.Babbler
		loadBombler = false
	end
	return oldGetTexCoordsForTechId(techId)
end
