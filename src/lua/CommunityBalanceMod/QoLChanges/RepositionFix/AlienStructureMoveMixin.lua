-- ========= Community Balance Mod ===============================
--
-- "lua\AlienStructureMoveMixin.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


if Server then

    local CanMove = debug.getupvaluex(AlienStructureMoveMixin.OnUpdate, "CanMove")

    -- Remove from mesh when we start moving and add back when we stop moving
    local function HandleObstacle(self)


        local isRepositoning = HasMixin(self, "RepositioningMixin") and self:GetIsRepositioning()

        --Balancemodfix:
        isRepositoning = HasMixin(self, "Repositioning") and self:GetIsRepositioning()

        local removeFromMesh = CanMove(self) or isRepositoning

        if not removeFromMesh and GetIsUnitActive(self) and self.removedMesh then
            self:AddToMesh()
            self.removedMesh = false
        end

        if removeFromMesh and not self.removedMesh then
            self:RemoveFromMesh()
            self:OnObstacleChanged()
            self.removedMesh = true
        end

    end

    debug.setupvaluex(AlienStructureMoveMixin.OnUpdate, "HandleObstacle", HandleObstacle)
    
end
