-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\PointGiverMixin.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com) and
--                  Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

--
-- PointGiverMixin handles awarding points on kills and other events.
--
PointGiverMixin = CreateMixin(PointGiverMixin)
PointGiverMixin.type = "PointGiver"

local kPointsPerUpgrade = 1

PointGiverMixin.expectedCallbacks =
{
    GetTeamNumber = "Returns the team number this PointGiver is on.",
    GetTechId = "Returns the tech Id of this PointGiver."
}

function PointGiverMixin:__initmixin()
    
    PROFILE("PointGiverMixin:__initmixin")
    
    if Server then
        self.damagePoints = {
            attackers = { } -- List of attacker Ids
        }
    end

end

function PointGiverMixin:GetPointValue()

    if self.isHallucination then
        return 0
    end

    local numUpgrades = HasMixin(self, "Upgradable") and #self:GetUpgrades() or 0
    local techId = self:GetTechId()
    local points = LookupTechData(techId, kTechDataPointValue, 0) +
            math.floor(numUpgrades * LookupTechData(techId, kTechDataUpgradeCost, 0) / 2)

    for i = 0, self:GetNumChildren() - 1 do

        local child = self:GetChildAtIndex(i)
        if HasMixin(child, "PointGiver") then
            points = points + child:GetPointValue()
        end

    end

    -- give additional points for enemies which got alot of score in their current life
    -- but don't give more than twice the default point value
    if HasMixin(self, "Scoring") then

        local scoreGained = self:GetScoreGainedCurrentLife() or 0
        points = points + math.min(points, scoreGained * 0.1)

    end

    if self:isa("Hive") then
        points = points + math.min((self:GetBioMassLevel() - 1) * kBioMassUpgradePointValue, 0)
        if self:isa("ShiftHive") or self:isa("CragHive") or self:isa(" ShadeHive") then
            points = points + kUgradedHivePointValue
        end
    end

    return points

end

if Server then

    local kNoConstructPoints = { "Cyst", "Clog", "BabblerEgg" }
    local function GetGivesConstructReward(self)
        return not table.icontains(kNoConstructPoints, self:GetClassName())
    end

    function PointGiverMixin:OnConstruct(builder, newFraction, oldFraction)

        if self:GetClassName() == "Hydra" then
            return
        end

        if not self.constructer then
            self.constructPoints = {}
            self.constructer = {}
        end

        if builder and builder:isa("Player") and GetAreFriends(self, builder) and GetGivesConstructReward(self) then

            local builderId = builder:GetId()

            if not self.constructPoints[builderId] then
                self.constructPoints[builderId] = 0
                self.constructer[#self.constructer + 1] = builderId
            end

            self.constructPoints[builderId] = self.constructPoints[builderId] + (newFraction - oldFraction)

        end

    end

    function PointGiverMixin:OnConstructionComplete()

        if self.constructer then

            for _, builderId in ipairs(self.constructer) do

                local builder = Shared.GetEntity(builderId)
                if builder and builder:isa("Player") and HasMixin(builder, "Scoring") then

  

                    local buildtime = LookupTechData(self:GetTechId(), kTechDataBuildTime, kBuildPointValue)
                    local buildPointValue

                    local constructionFraction = self.constructPoints[builderId]

                    if builder:isa("Alien") and buildtime then 
                        buildPointValue = math.max(math.ceil( (buildtime / 5 ) * Clamp(constructionFraction + 0.01 , 0, 1) ), 1)
    
                    elseif builder:isa("Marine") and buildtime then 
                        buildPointValue = math.max(math.ceil( (buildtime / 2 ) * Clamp(constructionFraction + 0.01 , 0, 1) ), 1)
                        
                    else 
                        buildPointValue = math.max(math.floor(kBuildPointValue * Clamp(constructionFraction, 0, 1)), 1)
                    end

                    builder:AddScore(buildPointValue)

                end

            end

        end

        self.constructPoints = nil
        self.constructer = nil

    end

    function PointGiverMixin:OnEntityChange(oldId, newId)

        if self.damagePoints[oldId] then
            if newId and newId ~= Entity.invalidId then
                self.damagePoints[newId] = self.damagePoints[oldId]
                table.insert(self.damagePoints.attackers, newId)
            end
            self.damagePoints[oldId] = nil
            table.removevalue(self.damagePoints.attackers, oldId)
        end

        if self.constructPoints and self.constructPoints[oldId] then
            if newId and newId ~= Entity.invalidId then
                self.constructPoints[newId] = self.constructPoints[oldId]
                table.insert(self.constructer, newId)
            end
            self.constructPoints[oldId] = nil
            table.removevalue(self.constructer, oldId)
        end

    end

    function PointGiverMixin:OnTakeDamage(damage, attacker, doer, point, direction, damageType, preventAlert)

        if attacker and attacker:isa("Player") and GetAreEnemies(self, attacker) then

            local attackerId = attacker:GetId()

            if not self.damagePoints[attackerId] then
                self.damagePoints[attackerId] = 0
                table.insert(self.damagePoints.attackers, attackerId)
            end

            self.damagePoints[attackerId] = self.damagePoints[attackerId] + damage

        end

    end

    function PointGiverMixin:PreOnKill(attacker, doer, point, direction)

        if self.isHallucination then
            return
        end

        local totalDamageDone = self:GetMaxHealth() + self:GetMaxArmor() * 2
        local points = self:GetPointValue()
        local resReward = self:isa("Player") and kPersonalResPerKill or 0

        -- award partial res and score to players who assisted
        for _, attackerId in ipairs(self.damagePoints.attackers) do

            local currentAttacker = Shared.GetEntity(attackerId)
            if currentAttacker and HasMixin(currentAttacker, "Scoring") then

                local damageDone = self.damagePoints[attackerId]
                local damageFraction = Clamp(damageDone / totalDamageDone, 0, 1)
                local scoreReward = points >= 1 and math.max(1, math.round(points * damageFraction)) or 0

                currentAttacker:AddScore(scoreReward, resReward * damageFraction, attacker == currentAttacker)

                if self:isa("Player") and currentAttacker ~= attacker then
                    currentAttacker:AddAssistKill()
                end

            end

        end

        if self:isa("Player") and attacker and GetAreEnemies(self, attacker) then

            if attacker:isa("Player") then
                attacker:AddKill()
            end

            self:GetTeam():AddTeamResources(kKillTeamReward)

        end

    end

end