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
Script.Load("lua/EnergyMixin.lua")

class 'SentryBattery' (ScriptActor)
SentryBattery.kMapName = "sentrybattery"
SentryBattery.kRange = 4.0

SentryBattery.kModelName = PrecacheAsset("models/marine/portable_node/portable_node.model")
local kAnimationGraph = PrecacheAsset("models/marine/portable_node/portable_node.animation_graph")
local kPurificationEffect = PrecacheAsset("cinematics/common/lpb_purification.cinematic")

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
AddMixinNetworkVars(EnergyMixin, networkVars)

local function CreateSentryBatteryLineModel()

	local sentryBatteryLineHelp = DynamicMesh_Create()
	sentryBatteryLineHelp:SetIsVisible(false)
	sentryBatteryLineHelp:SetMaterial(kLineMaterial)
	return sentryBatteryLineHelp

end

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
	InitMixin(self, EnergyMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, BlowtorchTargetMixin)
		self:AddTimedCallback(SentryBattery.OnTimedUpdate, kUpdateIntervalLow)
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
	
	local entPower = GetEntitiesWithMixinForTeamWithinRange("PowerSource", self:GetTeamNumber(), self:GetOrigin(), SentryBattery.kRange)
	if entPower[1] then
		self.AttachablePowerNode = entPower[1]
	else
		self.AttachablePowerNode = false
	end
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

function GetCheckBatteryLimit(techId, origin, normal, commander)

	local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or nil

    -- Prevent the case where a Sentry in one room is being placed next to another one.
    local sentryBatteries = Shared.GetEntitiesWithClassname("SentryBattery")

	if sentryBatteries:GetSize() >= kBatteryLimit then
		return false
	end
	
	for b = 0, sentryBatteries:GetSize() - 1 do
		
		local sentryBatttery = sentryBatteries:GetEntityAtIndex(b)
		
		if (sentryBatttery:GetOrigin() - origin):GetLength() < SentryBattery.kRange then
			return false
		end
				
		if sentryBatttery:GetLocationName() == locationName then
			return false
		end
		
	end
	return true        
end

function SentryBattery:OnDestroy()

    Entity.OnDestroy(self)

    if Client then
		if self.PurificationEffect then
			Client.DestroyCinematic(self.PurificationEffect)
			self.PurificationEffect = nil    
		end	
    end
	
end

if Server then

    function SentryBattery:GetDestroyOnKill()
        return true
    end

	function SentryBattery:OnKill()
		
		self:TriggerEffects("death")
		
		if self:GetTechId() == kTechId.ShieldBattery then
			local locationName = self.AttachablePowerNode:GetLocationName()
			DestroyPowerForLocation(locationName, true)
			self.AttachablePowerNode:SetAttachedBattery(nil)
			
		end
	end

    function SentryBattery:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.ShieldBatteryUpgrade then
			if self.AttachablePowerNode.powering then
				local techTree = self:GetTeam():GetTechTree()    
				local researchNode = techTree:GetTechNode(kTechId.SentryBattery) 
				researchNode:SetResearchProgress(self.researchProgress)
				techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
			else
				self:CancelResearch()
			end
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
			
			self.AttachablePowerNode:SetAttachedBattery(self)

        end
    end
	
	function SentryBattery:OnUpdate(deltaTime)
		if self:GetTechId() == kTechId.ShieldBattery then
			if not self.AttachablePowerNode.powering then
				self:Kill()
				self.AttachablePowerNode:SetAttachedBattery(nil)
			end
		end
		self:SetEnergy(GetTeamInfoEntity(self:GetTeamNumber()).PurificationFraction*100)
	end
end

local function CreateEffects(self)

	local player = Client.GetLocalPlayer()
	
	if self:GetTechId() == kTechId.ShieldBattery and GetTeamInfoEntity(player:GetTeamNumber()).PurificationCharging and not self.PurificationEffect then
		self.PurificationEffect = Client.CreateCinematic(RenderScene.Zone_Default)
		self.PurificationEffect:SetCinematic(kPurificationEffect)
		self.PurificationEffect:SetRepeatStyle(Cinematic.Repeat_Loop)
		self.PurificationEffect:SetCoords(self:GetCoords())			
	end
end

local function DeleteEffects(self)

	local player = Client.GetLocalPlayer()

	if (not GetTeamInfoEntity(player:GetTeamNumber()).PurificationCharging or not self:GetIsAlive()) and self.PurificationEffect then
        Client.DestroyCinematic(self.PurificationEffect)
        self.PurificationEffect = nil    
    end
	
end

if Client then
    function SentryBattery:OnTimedUpdate(deltaTime)
        CreateEffects(self)
        DeleteEffects(self)
        return true
    end
end

function SentryBattery:GetTechButtons(techId)

	local techButtons = { kTechId.None, kTechId.None, kTechId.None, kTechId.None,
                    kTechId.None, kTechId.None, kTechId.None, kTechId.None }

    --[[local techButtons = { kTechId.None, kTechId.None, kTechId.None, kTechId.None,
                    kTechId.PuriProtocol, kTechId.None, kTechId.None, kTechId.None }
    
    if self:GetTechId() == kTechId.SentryBattery and self:GetResearchingId() ~= kTechId.ShieldBatteryUpgrade and self.AttachablePowerNode then
		if self.AttachablePowerNode.powering then
			techButtons[1] = kTechId.ShieldBatteryUpgrade
		end
    end]]
	
	return techButtons
    
end

function SentryBattery:GetCanRecycleOverride()
    return not GetTeamInfoEntity(self:GetTeamNumber()).PurificationCharging or self:GetTechId() == kTechId.SentryBattery
end

function SentryBattery:GetCanUpdateEnergy()
    return false
end

Shared.LinkClassToMap("SentryBattery", SentryBattery.kMapName, networkVars)

class 'ShieldedSentryBattery' (SentryBattery)

ShieldedSentryBattery.kMapName = "shieldedsentrybattery"

Shared.LinkClassToMap("ShieldedSentryBattery", ShieldedSentryBattery.kMapName, {})
