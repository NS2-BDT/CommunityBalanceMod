-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\DrifterEgg.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DouseMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/DrifterVariantMixin.lua")

class 'DrifterEgg' (ScriptActor)
DrifterEgg.kMapName = "drifteregg"

DrifterEgg.kModelName = PrecacheAsset("models/alien/cocoon/cocoon.model")
local kAnimationGraph = PrecacheAsset("models/alien/cocoon/cocoon.animation_graph")

local networkVars =
{
    creationTime = "time"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DouseMixin, networkVars)
AddMixinNetworkVars(DrifterVariantMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)


function DrifterEgg:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, GameEffectsMixin)
    InitMixin(self, FlinchMixin, { kPlayFlinchAnimations = true })
    InitMixin(self, TeamMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, SelectableMixin)
    InitMixin(self, EntityChangeMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, UmbraMixin)
	InitMixin(self, DouseMixin)
	InitMixin(self, CloakableMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
end

function DrifterEgg:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    
    if Server then
        
        InitMixin(self, SupplyUserMixin)
        InitMixin(self, StaticTargetMixin)
        self:AddTimedCallback(DrifterEgg.Hatch, kDrifterHatchTime)        
        self:AddTimedCallback(DrifterEgg.UpdateTech, 0.2)
    
	    if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        
    end
    
    self:SetModel(DrifterEgg.kModelName, kAnimationGraph)

    if not Predict then
        InitMixin(self, DrifterVariantMixin)
        self:ForceDrifterSkinUpdate()
    end

end

function DrifterEgg:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false
end

function DrifterEgg:OverrideGetStatusInfo()

    return { Locale.ResolveString("COMM_SEL_HATCHING"), 
             self:GetHatchProgress(),
             kTechId.Drifter
   }

end

function DrifterEgg:GetIsMoveable()
    return true
end

function DrifterEgg:GetHatchProgress()
    return Clamp((Shared.GetTime() - self.creationTime) / kDrifterHatchTime, 0, 1)
end

if Server then

    function DrifterEgg:UpdateTech()
    
        if not self:GetIsDestroyed() then
    
            local progress = self:GetHatchProgress()

            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Drifter)    
            researchNode:SetResearchProgress(progress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", progress)) 
            
            if GetGamerules():GetAutobuild() then
                self:Hatch()
            end
        
            return true
        
        end
    
    end
    
    local function InNeedOfConstructor(constructor, entity)
        return  entity ~= nil and
                HasMixin(entity, "Construct") and
                not entity:GetIsBuilt() and
                GetAreFriends(constructor, entity)
    end
    
    local function IsBeingGrown(self, target)
        
        if target.hasDrifterEnzyme then
            return true
        end
        
        for _, drifter in ipairs(GetEntitiesForTeam("Drifter", target:GetTeamNumber())) do
            
            if self ~= drifter then
                
                local order = drifter:GetCurrentOrder()
                if order and order:GetType() == kTechId.Grow then
                    
                    local growTarget = Shared.GetEntity(order:GetParam())
                    if growTarget == target then
                        return true
                    end
                    
                end
                
            end
            
        end
        
        return false
        
    end
    
    function DrifterEgg:OnOverrideOrder(order)
        
        local orderTarget
        local orderParam = order:GetParam()
        if orderParam ~= nil then
            orderTarget = Shared.GetEntity(orderParam)
        end
        
        local orderType = order:GetType()
        
        -- Check for grow orders.
        if      orderTarget ~= nil and
                HasMixin(orderTarget, "Construct") and
                not orderTarget:GetIsBuilt() and
                GetAreFriends(self, orderTarget) and
                not IsBeingGrown(self, orderTarget) and
                (not orderTarget.GetCanAutoBuild or orderTarget:GetCanAutoBuild()) then
            
            order:SetType(kTechId.Grow)
        
        -- Check for alien follow orders.
        elseif  orderTarget ~= nil and
                orderTarget:isa("Alien") and
                orderTarget:GetIsAlive() then
            
            order:SetType(kTechId.Follow)
            
        -- Finally just treat it as a rally point.
        else
            order:SetType(kTechId.SetRally)
        end
        
    end

    function DrifterEgg:Hatch()
        
        local drifter = CreateEntity(Drifter.kMapName, self:GetOrigin() + Vector(0, Drifter.kHoverHeight, 0), self:GetTeamNumber())
        drifter:ProcessRallyOrder(self)
        drifter:SetHealth(self:GetHealth())
        drifter:SetArmor(self:GetArmor())
        
        -- inherit selection
        drifter.selectionMask = self.selectionMask
        drifter.hotGroupNumber = self.hotGroupNumber
        
        self:TriggerEffects("death")
        
        local techTree = self:GetTeam():GetTechTree()    
        local researchNode = techTree:GetTechNode(kTechId.Drifter)    
        researchNode:SetResearchProgress(1)
        techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 1))

        -- Handle Stats (Must be Server only)
        StatsUI_AddBuildingStat(self:GetTeamNumber(), kTechId.Drifter, false)
        -- Drifter hatched
        StatsUI_AddExportBuilding(self:GetTeamNumber(),
            kTechId.Drifter,
            drifter:GetId(),
            self:GetOrigin(),
            StatsUI_kLifecycle.Built,
            true)
        
        DestroyEntity(self)

    end
    
    function DrifterEgg:GetDestroyOnKill()
        return true
    end

    function DrifterEgg:OnKill()
    
        self:TriggerEffects("death")
    
    end
    
end   

function DrifterEgg:OnUpdatePoseParameters()

    self:SetPoseParam("grow", self:GetHatchProgress())
    
end    

Shared.LinkClassToMap("DrifterEgg", DrifterEgg.kMapName, networkVars)
