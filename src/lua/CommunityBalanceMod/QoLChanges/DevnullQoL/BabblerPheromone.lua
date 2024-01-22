-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

local kBabblerSearchRange = 1000

-- Force order for all babblers to the same target
function BabblerPheromone:MoveBabblers()
	local orig = self:GetOrigin()
	local enemyTeamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
	local nearestTargets = GetEntitiesForTeamWithinRange("Player", enemyTeamNumber, orig, 15)
	local target
	local targetPos

	for _, ent in ipairs(nearestTargets) do
		if ent and not GetWallBetween(orig, ent:GetOrigin(), ent) then
			target = ent
			targetPos = ent.GetEngagementPoint and ent:GetEngagementPoint() or ent:GetOrigin()
			break
		end
	end

	local owner = self:GetOwner()
	for _, babbler in ipairs(GetEntitiesForTeamWithinRange("Babbler", self:GetTeamNumber(), orig, kBabblerSearchRange)) do
		if babbler:GetOwner() == owner then
			if babbler:GetIsClinged() and babbler:GetParent() == owner then
				babbler:Detach()
			end

			if target then
				-- Log("Attack group order issued by the bait toward %s", target)
				babbler:SetMoveType(kBabblerMoveType.Attack, target, targetPos, true)
			elseif babbler.moveType ~= kBabblerMoveType.Attack then
				-- Log("Move group order issued by the bait toward %s", target)
				babbler:SetMoveType(kBabblerMoveType.Move, nil, self:GetOrigin(), true)
			end
		end
	end
end

if Server then
	orgBabblerPheromoneProcessHit = BabblerPheromone.ProcessHit
	function BabblerPheromone:ProcessHit(entity)
		if not entity then -- the rest of the code will handle the case where we hit an entity
			self:MoveBabblers() -- Move babblers where the ball bounce
		else
			orgBabblerPheromoneProcessHit(self, entity)
		end
	end
end
