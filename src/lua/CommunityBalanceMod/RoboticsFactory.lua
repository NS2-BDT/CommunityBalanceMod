-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\RoboticsFactory.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/PowerConsumerMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CommunityBalanceMod/BlightMixin.lua")

class 'RoboticsFactory' (ScriptActor)

local kAnimationGraph = PrecacheAsset("models/marine/robotics_factory/robotics_factory.animation_graph")

RoboticsFactory.kMapName = "roboticsfactory"

RoboticsFactory.kModelName = PrecacheAsset("models/marine/robotics_factory/robotics_factory.model")

RoboticsFactory.kAttachPoint = "target"

RoboticsFactory.kCloseDelay  = .5
--RoboticsFactory.kActiveEffect = PrecacheAsset("cinematics/marine/roboticsfactory/active.cinematic")  --McG: Never used
RoboticsFactory.kAnimOpen   = "open"
RoboticsFactory.kAnimClose  = "close"

RoboticsFactory.kRolloutLength = 3

local networkVars =
{
    open = "boolean",
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
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
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(PowerConsumerMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(HiveVisionMixin, networkVars)
AddMixinNetworkVars(BlightMixin, networkVars)

function RoboticsFactory:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
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
    InitMixin(self, RagdollMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
	InitMixin(self, BlightMixin)
    
    if Client then
        InitMixin(self, CommanderGlowMixin)
    end

    self:SetLagCompensated(true)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
        
    self.open = false

    self:SetUpdateRate(kRealTimeUpdateRate)

end

function RoboticsFactory:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, HiveVisionMixin)
    
    self:SetModel(RoboticsFactory.kModelName, kAnimationGraph)
    
    self:SetPhysicsType(PhysicsType.Kinematic)
    
    self.researchId = Entity.invalidId
    
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
        
    end

end

function RoboticsFactory:GetReceivesStructuralDamage()
    return true
end

function RoboticsFactory:GetRequiresPower()
    return true
end

function RoboticsFactory:GetNanoShieldOffset()
    return Vector(0, -0.8, 0)
end

function RoboticsFactory:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    
    -- Do not allow tech while open or researching or we may lose res.
    -- Research progress is checked here instead of GetIsResearching() because
    -- there is a delay in the tech tree when tech is queued which causes
    -- GetIsResearching() to return true before the research is 100% complete.
    -- Checking the progress is 0 is the sure way to get around that limit.
    -- $AU: Which causes the cancel button to not work anymore. I want to make the tech tree
    -- finally entity based (this will also make both tech trees available for insight) with clearer API.
    allowed = allowed and not self.open and self:GetResearchProgress() == 0
    
    if techId == kTechId.ARC then
        allowed = allowed and self:GetTechId() == kTechId.ARCRoboticsFactory
        allowed = allowed and #GetEntitiesForTeam("ARC", self:GetTeamNumber()) < kMaxARCs
    elseif techId == kTechId.Cancel then
        allowed = self:GetResearchProgress() < 1
    end
	
	if techId == kTechId.DIS then
        allowed = allowed and self:GetTechId() == kTechId.ARCRoboticsFactory
        allowed = allowed and #GetEntitiesForTeam("DIS", self:GetTeamNumber()) < kMaxDISs
    elseif techId == kTechId.Cancel then
        allowed = self:GetResearchProgress() < 1
    end
    
    return allowed, canAfford
    
end

function RoboticsFactory:GetTechButtons(techId)

    local techButtons = {  kTechId.ARC, kTechId.MAC, kTechId.DIS, kTechId.None, 
               kTechId.None, kTechId.None, kTechId.None, kTechId.None }
               
    if self:GetTechId() ~= kTechId.ARCRoboticsFactory then
        techButtons[5] = kTechId.UpgradeRoboticsFactory
    end           

    return techButtons
    
end

function RoboticsFactory:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function RoboticsFactory:GetPositionForEntity(entity)
    
    local direction = Vector(self:GetAngles():GetCoords().zAxis)    
    local origin = self:GetOrigin() + direction * 3.2
    
    if entity:GetIsFlying() then
        origin = GetHoverAt(entity, origin)
    end
    
    return Coords.GetLookIn( origin, direction )

end

function RoboticsFactory:ManufactureEntity()

    local mapName = LookupTechData(self.researchId, kTechDataMapName)    
    local owner = Shared.GetEntity(self.researchingPlayerId)
    
    local builtEntity = CreateEntity(mapName, self:GetOrigin(), self:GetTeamNumber())        
                
    if builtEntity ~= nil then             
    
        local newPosition = self:GetPositionForEntity(builtEntity)
        builtEntity:SetOwner(owner)
        builtEntity:SetCoords(newPosition)
        builtEntity:ProcessRallyOrder(self)
        
    end
    
end

-- Actual creation of entity happens delayed.
function RoboticsFactory:OverrideCreateManufactureEntity(techId)

    if techId == kTechId.ARC or techId == kTechId.MAC then
    
        self.researchId = techId
        self.open = true
        
    end
    
end

function RoboticsFactory:OnResearchComplete(researchId)

    if researchId == kTechId.UpgradeRoboticsFactory then
        self:UpgradeToTechId(kTechId.ARCRoboticsFactory)
    end
        
end

function RoboticsFactory:OnTag(tagName)
    
    PROFILE("RoboticsFactory:OnTag")

    if self.open and self.builtEntity and self.researchId ~= Entity.invalidId and tagName == "end" then

        self.builtEntity:Rollout(self, RoboticsFactory.kRolloutLength)
        self.builtEntity = nil
        
    end
    
    if tagName == "open_start" then
        self:TriggerEffects("robofactory_door_open")
    elseif tagName == "close_start" then
        self:TriggerEffects("robofactory_door_close")
    end
    
end

function RoboticsFactory:OnUpdateAnimationInput(modelMixin)

    PROFILE("RoboticsFactory:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("open", self.open)

end

if Server then

    --[[
    function RoboticsFactory:OnUpdate()
       
        -- Create free MAC when built
        if self.deployed and GetIsUnitActive(self) and self.spawnedFreeMAC == nil and not self:GetIsResearching() and not self.open then
        
            self:OverrideCreateManufactureEntity(kTechId.MAC)
            self.spawnedFreeMAC = true
            
        end
        
    end
    --]]

    function RoboticsFactory:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeRoboticsFactory then

            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.ARCRoboticsFactory)
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))

        end

    end

    function RoboticsFactory:OnResearchCancel(researchId)

        if researchId == kTechId.UpgradeRoboticsFactory then

            local team = self:GetTeam()

            if team then

                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.ARCRoboticsFactory)
                if researchNode then

                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))

                end
            end
        end
    end
    
    function RoboticsFactory:Deploy()
        self.deployed = true
        return false
    end
    
    function RoboticsFactory:OnConstructionComplete()    
    
        self:AddTimedCallback(RoboticsFactory.Deploy, 3)      

    end
    
end

function RoboticsFactory:OnOverrideOrder(order)

    -- Convert default to set rally point.
    if order:GetType() == kTechId.Default then
        order:SetType(kTechId.SetRally)
    end
    
end

function RoboticsFactory:GetHealthbarOffset()
    return 1
end 

function RoboticsFactory:ManufactureEntity()

    local mapName = LookupTechData(self.researchId, kTechDataMapName)    
    local owner = Shared.GetEntity(self.researchingPlayerId)
    
    local builtEntity = CreateEntity(mapName, self:GetOrigin(), self:GetTeamNumber())        
                
    if builtEntity ~= nil then             
    
        builtEntity:SetOwner(owner)
        builtEntity:SetAngles(self:GetAngles())
        builtEntity:SetIgnoreOrders(true)
       
    end
    
    return builtEntity
    
end


-- Create entity but don't let the commander take control until it has rolled out
function RoboticsFactory:OverrideCreateManufactureEntity(techId)

    if techId == kTechId.ARC or techId == kTechId.MAC or techId == kTechId.DIS then
    
        self.researchId = techId
        self.open = true
        
        -- Create entity inside ourselves, but wait until we are open before we move
        self.builtEntity = self:ManufactureEntity()

        return self.builtEntity
        
    end
    
end

function RoboticsFactory:CompleteRollout(entity)

    self:ClearResearch()
    self.open = false
    entity:SetIgnoreOrders(false)
    entity:ProcessRallyOrder(self)
    
end

Shared.LinkClassToMap("RoboticsFactory", RoboticsFactory.kMapName, networkVars, true)


class 'ARCRoboticsFactory' (RoboticsFactory)
ARCRoboticsFactory.kMapName = "arcroboticsfactory"
Shared.LinkClassToMap("ARCRoboticsFactory", ARCRoboticsFactory.kMapName, { })

--[[
class 'RoboticsAddon' (ScriptActor)

RoboticsAddon.kMapName = "RoboticsAddon"

local addonNetworkVars = { }

AddMixinNetworkVars(ModelMixin, addonNetworkVars)
AddMixinNetworkVars(TeamMixin, addonNetworkVars)

function RoboticsAddon:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)    
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    
end

Shared.LinkClassToMap("RoboticsAddon", RoboticsAddon.kMapName, addonNetworkVars)
--]]

function GetRoboticsFactoryBuildValid(techId, origin, normal, player)
    local ents = GetEntitiesWithinXZRange("ScriptActor", origin, 3)
    return (#ents == 0)
end
