-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\SentryBattery.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Powers up to three sentries. Required for building them.
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
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/PowerConsumerMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/BlightMixin.lua")
Script.Load("lua/BlowtorchTargetMixin.lua")

class 'SentryBattery' (ScriptActor)
SentryBattery.kMapName = "sentrybattery"
SentryBattery.kRange = 4.0

SentryBattery.kModelName = PrecacheAsset("models/marine/portable_node/portable_node.model")
local kAnimationGraph = PrecacheAsset("models/marine/portable_node/portable_node.animation_graph")

local networkVars =
{
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(RecycleMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)

AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(PowerConsumerMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(BlightMixin, networkVars)

function SentryBattery:OnCreate()

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
    InitMixin(self, CorrodeMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, RecycleMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
	InitMixin(self, BlightMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, BlowtorchTargetMixin)
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
end

function SentryBattery:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    if Server then
    
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, SupplyUserMixin)
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    self:SetModel(SentryBattery.kModelName, kAnimationGraph)

end

function SentryBattery:GetReceivesStructuralDamage()
    return true
end

function SentryBattery:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function SentryBattery:GetRequiresPower()
    return false
end
function SentryBattery:GetHealthbarOffset()
    return 0.75
end 

function GetSentryBatteryInRoom(origin)

    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    
    if locationName then
    
        local batteries = Shared.GetEntitiesWithClassname("SentryBattery")
        for b = 0, batteries:GetSize() - 1 do
        
            local battery = batteries:GetEntityAtIndex(b)
            if battery and battery:GetLocationName() == locationName then
                return battery
            end
            
        end
        
    end
    
    return nil
    
end

function GetRoomHasNoSentryBattery(techId, origin, normal, commander)

    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil
    local validRoom = false
    
    if locationName then
    
        validRoom = true
    
        for index, sentryBattery in ientitylist(Shared.GetEntitiesWithClassname("SentryBattery")) do
            
            if sentryBattery:GetLocationName() == locationName then
                validRoom = false
                break
            end
            
        end
    
    end
    
    return validRoom

end

if Server then

    function SentryBattery:GetDestroyOnKill()
        return true
    end

    function SentryBattery:OnKill()

        self:TriggerEffects("death")

    end

    function SentryBattery:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.ShieldBatteryUpgrade then
        
            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.SentryBattery) 
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
        end
    end


    function SentryBattery:OnResearchCancel(researchId)

        if researchId == kTechId.ShieldBatteryUpgrade then
        
            local team = self:GetTeam()
            
            if team then
            
                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.SentryBattery)
                if researchNode then
                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
                end
            end  
        end
    end

    -- Called when research or upgrade complete
    function SentryBattery:OnResearchComplete(researchId)

        if researchId == kTechId.ShieldBatteryUpgrade then
        
            self:UpgradeToTechId(kTechId.ShieldBattery)

            self:MarkBlipDirty()
            
            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.SentryBattery)
            
            if researchNode then     
    
                researchNode:SetResearchProgress(1)
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.ShieldBattery, self)

            end
        end
    end

end

function SentryBattery:GetTechButtons(techId)

    local techButtons = { kTechId.None, kTechId.None, kTechId.None, kTechId.None,
                    kTechId.None, kTechId.None, kTechId.None, kTechId.None }
        
    --if self:GetTechId() == kTechId.SentryBattery and self:GetResearchingId() ~= kTechId.ShieldBatteryUpgrade then
    --    techButtons[1] = kTechId.ShieldBatteryUpgrade
    --end
	
	return techButtons
    
end

Shared.LinkClassToMap("SentryBattery", SentryBattery.kMapName, networkVars)

class 'ShieldedSentryBattery' (SentryBattery)

ShieldedSentryBattery.kMapName = "shieldedsentrybattery"

Shared.LinkClassToMap("ShieldedSentryBattery", ShieldedSentryBattery.kMapName, {})

ShieldedSentryBattery.kRange = 4.0
ShieldedSentryBattery.kModelName = PrecacheAsset("models/marine/portable_node/portable_node.model")

