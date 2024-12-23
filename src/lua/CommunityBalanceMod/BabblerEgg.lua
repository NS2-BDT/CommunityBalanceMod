-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\BabblerEgg.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    X babblers will hatch out of it when construction is completed.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Babbler.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/StaticTargetMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/OwnerMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/ClogFallMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/CommunityBalanceMod/DouseMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/Weapons/DotMarker.lua")
Script.Load("lua/CloakableMixin.lua")

class 'BabblerEgg' (ScriptActor)

BabblerEgg.kMapName = "babbleregg"
BabblerEgg.kDropRange = 3

BabblerEgg.kModelName = PrecacheAsset("models/alien/babbler/babbler_egg.model")
BabblerEgg.kModelNameShadow = PrecacheAsset("models/alien/babbler/babbler_egg_shadow.model")
local kBabblerEggModelVariants =
{
    [kBabblerEggVariants.normal] = BabblerEgg.kModelName,
    [kBabblerEggVariants.Shadow] = BabblerEgg.kModelNameShadow,
    [kBabblerEggVariants.Abyss] = BabblerEgg.kModelName,
    [kBabblerEggVariants.Reaper] = BabblerEgg.kModelName,
    [kBabblerEggVariants.Nocturne] = BabblerEgg.kModelName,
    [kBabblerEggVariants.Kodiak] = BabblerEgg.kModelName,
    [kBabblerEggVariants.Toxin] = BabblerEgg.kModelName,
    [kBabblerEggVariants.Auric] = BabblerEgg.kModelNameShadow,
}
local kBabblerEggWorldMaterialIndex = 0

local kAnimationGraph = PrecacheAsset("models/alien/babbler/babbler_egg.animation_graph")
PrecacheAsset("sound/NS2.fev/alien/babbler/hatch")

local networkVars =
{
    ownerId = "entityid",
    variant = "enum kBabblerEggVariants"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DouseMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)

function BabblerEgg:OnCreate()

    ScriptActor.OnCreate(self)

    InitMixin(self, ClogFallMixin)
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    
    InitMixin(self, LiveMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, SelectableMixin)

    InitMixin(self, MaturityMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, UmbraMixin)
	InitMixin(self, DouseMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, CloakableMixin)

    self.variant = kGorgeVariants.normal
    
    if Server then
        self.silenced = false
    end
    
    self:SetRelevancyDistance(kMaxRelevancyDistance)

end

function BabblerEgg:OnInitialized()

    self:SetModel(BabblerEgg.kModelName, kAnimationGraph)
    
    if Server then    

        ScriptActor.OnInitialized(self)

        InitMixin(self, StaticTargetMixin)
    
        local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom)
        
        if self:GetTeamNumber() == 1 then
            mask = bit.bor(mask, kRelevantToTeam1Commander)
        elseif self:GetTeamNumber() == 2 then
            mask = bit.bor(mask, kRelevantToTeam2Commander)
        end
        
        self:SetExcludeRelevancyMask(mask)

    elseif Client then

        InitMixin(self, UnitStatusMixin)

        self.dirtySkinState = false
        self.delayedSkinUpdate = false

    end

    self:SetPhysicsGroup(PhysicsGroup.SmallStructuresGroup)
    InitMixin(self, IdleMixin)
    
end

function BabblerEgg:GetCanSleep()
    return true
end

function BabblerEgg:GetMinimumAwakeTime()
    return 0
end

function BabblerEgg:SetVariant(gorgeVariant)
    self.variant = gorgeVariant
    local model = kBabblerEggModelVariants[gorgeVariant] or BabblerEgg.kModelName
    self:SetModel(model, kAnimationGraph)
end

function BabblerEgg:GetMaturityRate()
    return kBabblerEggMaturationTime
end

function BabblerEgg:GetMatureMaxHealth()
    return kMatureBabblerEggHealth
end

function BabblerEgg:GetMatureMaxArmor()
    return kMatureBabblerEggArmor
end

function BabblerEgg:GetMatureMaxEnergy()
    return 0
end

function BabblerEgg:GetUseMaxRange()
    return BabblerEgg.kDropRange
end

if Server then

    function BabblerEgg:OnTakeDamage(_, attacker, doer)
        if self:GetIsBuilt() then
            local owner = self:GetOwner()
            local doerClassName = doer and doer:GetClassName()

            if owner and doer and attacker == owner and doerClassName == "Spit" then
                self:Explode()
            end
        end
    end

    function BabblerEgg:Explode()

        local dotMarker = CreateEntity(DotMarker.kMapName, self:GetOrigin(), self:GetTeamNumber())
        dotMarker:SetTechId(kTechId.BabblerEgg)
        dotMarker:SetDamageType(kBabblerEggDamageType)
        dotMarker:SetLifeTime(kBabblerEggDamageDuration)
        dotMarker:SetDamage(kBabblerEggDamage)
        dotMarker:SetRadius(kBabblerEggDamageRadius)
        dotMarker:SetDamageIntervall(kBabblerEggDotInterval)
        dotMarker:SetDotMarkerType(DotMarker.kType.Static)
        dotMarker:SetTargetEffectName("bilebomb_onstructure")
        dotMarker:SetDeathIconIndex(kDeathMessageIcon.BileBomb)
        dotMarker:SetOwner(self:GetOwner())

        local function NoFalloff()
            return 0
        end
        dotMarker:SetFallOffFunc(NoFalloff)

        dotMarker:TriggerEffects("bilebomb_hit")

        DestroyEntity(self)
    end

    function BabblerEgg:DetectThreatFilter()
        return function (t)
            return t ~= self and not t:isa("Clog")
        end
    end

    function BabblerEgg:DetectThreat()
        if self:GetIsBuilt() then
            local otherTeam = GetEnemyTeamNumber(self:GetTeamNumber())
            local allEnemies = GetEntitiesForTeamWithinRange("Player", otherTeam, self:GetOrigin(), kBabblerEggDamageRadius)
            local enemies = {}

            for _, ent in ipairs(allEnemies) do
                if ent:GetIsAlive() then
                    table.insert(enemies, ent)
                end
            end

            Shared.SortEntitiesByDistance(self:GetOrigin(), enemies)
            for _, ent in ipairs(enemies) do
                local dir = self:GetCoords().yAxis
                local startPoint = ent:GetEngagementPoint()
                local endPoint = self:GetOrigin() + dir * self:GetExtents().y
                local filter = self:DetectThreatFilter()

                local trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Move, PhysicsMask.Bullets, filter)
                local visibleTarget = trace.entity == self

                -- If a clog is blocking our LOS, check from our origin instead of our model top
                if not visibleTarget and GetIsPointInsideClogs(endPoint) then
                    -- Log("%s is inside clog, doing origin traceray", self)
                    endPoint = self:GetOrigin()
                    trace = Shared.TraceRay(startPoint, endPoint, CollisionRep.Move, PhysicsMask.Bullets, filter)
                end

                if visibleTarget and trace.fraction < 1 then
                    self:Explode()
                    break
                end
            end
        end

        return self:GetIsAlive()
    end

    function BabblerEgg:Arm()
        if self:DetectThreat() ~= false then
            self:AddTimedCallback(BabblerEgg.DetectThreat, 0.60)
        end
    end

    function BabblerEgg:OnConstructionComplete()
        self:AddTimedCallback(BabblerEgg.Arm, 1.60)
    end
    
    function BabblerEgg:GetDestroyOnKill()
        return true
    end

    function BabblerEgg:OnKill(attacker, doer, point, direction)
    
        self:TriggerEffects("death")
        
    end
    
    function BabblerEgg:SetOwner(owner)
    
        if GetHasSilenceUpgrade(owner) then
            self.silenced = true
        end
    
    end
    
end

function BabblerEgg:OnDestroy()
    
    ScriptActor.OnDestroy(self)
    
    if Client then
        Client.DestroyRenderDecal(self.decal)
        self.decal = nil
    elseif Server then
        self.preventEntityChangeCallback = true
    end
    
end

function BabblerEgg:GetEffectParams(tableParams)
    tableParams[kEffectFilterSilenceUpgrade] = self.silenced
end

function BabblerEgg:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = self.ownerId == player:GetId() and self:GetIsBuilt()
end

function BabblerEgg:OnModelChanged(hasModel)
    if hasModel then
        self.dirtySkinState = false
        self.delayedSkinUpdate = true
    end
end

if Client then
    function BabblerEgg:OnUpdate(deltaTime)
        if not Shared.GetIsRunningPrediction() then
            if self.delayedSkinUpdate then
                self.dirtySkinState = true
                self.delayedSkinUpdate = false
            end
        end
    end
end

function BabblerEgg:OnUpdateRender()

    local showDecal = self:GetIsVisible() and not self:GetIsCloaked()

    if not self.decal and showDecal then
        self.decal = CreateSimpleInfestationDecal(0.9, self:GetCoords())
    elseif self.decal and not showDecal then
        Client.DestroyRenderDecal(self.decal)
        self.decal = nil
    end

    if self.dirtySkinState and not self.delayedSkinUpdate then
        
        local model = self:GetRenderModel()
        if model then
            if self.variant ~= kBabblerEggVariants.normal and self.variant ~= kBabblerEggVariants.Shadow then
                local material = GetPrecachedCosmeticMaterial( self:GetClassName(), self.variant )
                if material then
                    model:SetOverrideMaterial( kBabblerEggWorldMaterialIndex, material )
                end
            else
                model:ClearOverrideMaterials()
            end

            self:SetHighlightNeedsUpdate()
        else
            return false --run again next frame
        end

        self.dirtySkinState = false
    end

end

Shared.LinkClassToMap("BabblerEgg", BabblerEgg.kMapName, networkVars)
