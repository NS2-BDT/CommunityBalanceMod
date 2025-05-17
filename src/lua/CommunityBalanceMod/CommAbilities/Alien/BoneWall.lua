-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\BoneWall.lua
--
-- Created by: Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/CommanderAbility.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/MapBlipMixin.lua")

class 'BoneWall' (CommanderAbility)

BoneWall.kMapName = "bonewall"

BoneWall.kModelName = PrecacheAsset("models/alien/infestationspike/infestationspike.model")
local kAnimationGraph = PrecacheAsset("models/alien/infestationspike/infestationspike.animation_graph")

local kCommanderAbilityType = CommanderAbility.kType.OverTime
local kLifeSpan = 6

local kMoveOffset = 4
local kMoveDuration = 0.4

local networkVars =
{
    spawnPoint = "vector"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)

function AlignBoneWalls(coords)

    local nearbyMarines = GetEntitiesWithinRange("Marine", coords.origin, 20)
    Shared.SortEntitiesByDistance(coords.origin, nearbyMarines)

    for _, marine in ipairs(nearbyMarines) do
    
        if marine:GetIsAlive() and marine:GetIsVisible() then

            local newZAxis = GetNormalizedVectorXZ(marine:GetOrigin() - coords.origin)
            local newXAxis = coords.yAxis:CrossProduct(newZAxis)
            coords.zAxis = newZAxis
            coords.xAxis = newXAxis
            break
        
        end
    
    end
    
    return coords

end


function BoneWall:GetDestroyOnKill()
    return true
end

function BoneWall:OnKill(attacker, doer, point, direction)

    self:TriggerEffects("death")

end

function BoneWall:OnCreate()

    CommanderAbility.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, ObstacleMixin)
    
    if Server then
        InitMixin(self, MapBlipMixin)
    end
    
end

function BoneWall:OnInitialized()

    CommanderAbility.OnInitialized(self)
    
    self.spawnPoint = self:GetOrigin()
    self:SetModel(BoneWall.kModelName, kAnimationGraph)
    
    if Server then
        self:TriggerEffects("bone_wall_burst")
        
        local team = self:GetTeam()
        if team then
            local level = math.max(0, team:GetBioMassLevel() - 1)
            local newMaxHealth = kBoneWallHealth + level * kBoneWallHealthPerBioMass
            if newMaxHealth ~= self.maxHealth  then
                self:SetMaxHealth(newMaxHealth)
                self:SetHealth(self.maxHealth)
            end
        end
    end
    
    -- Make the structure kinematic so that the player will collide with it.
    self:SetPhysicsType(PhysicsType.Kinematic)

end

function BoneWall:GetSurfaceOverride()
    return "infestation"
end    

function BoneWall:GetType()
    return kCommanderAbilityType
end

function BoneWall:GetResetsPathing()
    return true
end

function BoneWall:GetLifeSpan()
    return kLifeSpan
end

function BoneWall:OnUpdate(deltaTime)

    CommanderAbility.OnUpdate(self, deltaTime)
    
    local lifeTime = math.max(0, Shared.GetTime() - self:GetTimeCreated())
    local remainingTime = self:GetLifeSpan() - lifeTime
    
    if remainingTime < self:GetLifeSpan() then
        
        local moveFraction = 0

        if remainingTime <= 1 then
            moveFraction = 1 - Clamp(remainingTime / kMoveDuration, 0, 1)
        end
        
        local piFraction = moveFraction * (math.pi / 2)

        self:SetOrigin(self.spawnPoint - Vector(0, math.sin(piFraction) * kMoveOffset, 0))
    
    end

end

function BoneWall:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function BoneWall:GetIsFlameAble()
    return false
end

function BoneWall:GetReceivesStructuralDamage()
    return false
end

Shared.LinkClassToMap("BoneWall", BoneWall.kMapName, networkVars)
