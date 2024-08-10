local oldGetIsResearchRelevant = debug.getupvaluex(PlayingTeam.OnResearchComplete, "GetIsResearchRelevant")
local function extGetIsResearchRelevant(techId)
    if techId == kTechId.BabblerBombAbility then
        return 1
    end

    return oldGetIsResearchRelevant(techId)
end
debug.setupvaluex(PlayingTeam.OnResearchComplete, "GetIsResearchRelevant", extGetIsResearchRelevant)