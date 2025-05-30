-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\PhaseGate.lua
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
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/RecycleMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/GhostStructureMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/MinimapConnectionMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/BlightMixin.lua")
Script.Load("lua/BlowtorchTargetMixin.lua")

local kAnimationGraph = PrecacheAsset("models/marine/phase_gate/phase_gate.animation_graph")
--local kPhaseSound = PrecacheAsset("sound/NS2.fev/marine/structures/phase_gate_teleport")

local kPhaseGatePushForce = 500
local kPhaseGateTimeout = 0.6

-- Offset about the phase gate origin where the player will spawn
local kSpawnOffset = Vector(0, 0.1, 0)

-- Transform angles, view angles and velocity from srcCoords to destCoords (when going through phase gate)
local function TransformPlayerCoordsForPhaseGate(player, srcCoords, dstCoords)

    local viewCoords = player:GetViewCoords()
    
    -- If we're going through the backside of the phase gate, orient us
    -- so we go out of the front side of the other gate.
    if Math.DotProduct(viewCoords.zAxis, srcCoords.zAxis) < 0 then
    
        srcCoords.zAxis = -srcCoords.zAxis
        srcCoords.xAxis = -srcCoords.xAxis
        
    end
    
    -- Redirect player velocity relative to gates
    local invSrcCoords = srcCoords:GetInverse()
    local invVel = invSrcCoords:TransformVector(player:GetVelocity())
    local newVelocity = dstCoords:TransformVector(invVel)
    player:SetVelocity(newVelocity)
    
    local viewCoords = dstCoords * (invSrcCoords * viewCoords)
    local viewAngles = Angles()
    viewAngles:BuildFromCoords(viewCoords)
    
    player:SetBaseViewAngles(Angles(0,0,0))
    player:SetViewAngles(viewAngles)
    
end

local function GetDestinationOrigin(origin, direction, player, phaseGate, extents)

    local capusuleOffset = Vector(0, 0.4, 0)
    origin = origin + kSpawnOffset
    if not extents then
        extents = Vector(0.17, 0.2, 0.17)
    end

    -- check at first a desired spawn, if that one is free we use that
    if GetHasRoomForCapsule(extents, origin + capusuleOffset, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, phaseGate) then
        return origin
    end
    
    local numChecks = 6
    
    for i = 0, numChecks do
    
        local offset = direction * (i - numChecks/2) * -0.5
        if GetHasRoomForCapsule(extents, origin + offset + capusuleOffset, CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls, phaseGate) then
            origin = origin + offset
            break
        end
        
    end
    
    return origin

end

class 'PhaseGate' (ScriptActor)

PhaseGate.kMapName = "phasegate"

PhaseGate.kModelName = PrecacheAsset("models/marine/phase_gate/phase_gate.model")

PhaseGate.kRelevancyPortalRadius = 15.0

local kUpdateInterval = 0.085

local kPushRange = 3
local kPushImpulseStrength = 40

local networkVars =
{
    linked = "boolean",
    phase = "boolean",
    deployed = "boolean",
    destLocationId = "entityid",
    targetYaw = "float (-3.14159265 to 3.14159265 by 0.003)",
    destinationEndpoint = "position",
    directionBackwards = "boolean",
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
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(PowerConsumerMixin, networkVars)
AddMixinNetworkVars(GhostStructureMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(BlightMixin, networkVars)

function PhaseGate:OnCreate()

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
    InitMixin(self, DissolveMixin)
    InitMixin(self, GhostStructureMixin)
    InitMixin(self, PowerConsumerMixin)
    InitMixin(self, ParasiteMixin)
	InitMixin(self, BlightMixin)
	
    if Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, BlowtorchTargetMixin)
    end
    
    -- Compute link state on server and propagate to client for looping effects
    self.linked = false
    self.phase = false
    self.deployed = false
    self.destLocationId = Entity.invalidId
    if Server then
        self.directionBackwards = false
    end

    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.BigStructuresGroup)
    
    self.relevancyPortalIndex = -1 -- invalid index = no relevancyPortal.
    
end

function PhaseGate:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)
    
    self:SetModel(PhaseGate.kModelName, kAnimationGraph)
    
    if Server then
    
        self:AddTimedCallback(PhaseGate.Update, kUpdateInterval)
        self.timeOfLastPhase = nil
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, InfestationTrackerMixin)
        InitMixin(self, MinimapConnectionMixin)
        InitMixin(self, SupplyUserMixin)

        self.performedPhaseLastUpdate = false
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)
    
end

local function DestroyRelevancyPortal(self)
    if self.relevancyPortalIndex ~= -1 then
        Server.DestroyRelevancyPortal(self.relevancyPortalIndex)
        self.relevancyPortalIndex = -1
    end
end

function PhaseGate:OnDestroy()
    
    ScriptActor.OnDestroy(self)
    
    DestroyRelevancyPortal(self)
    
end

function PhaseGate:GetIsWallWalkingAllowed()
    return false
end 

function PhaseGate:GetTechButtons(techId)

    return { kTechId.None, kTechId.None, kTechId.None, kTechId.None, 
             kTechId.None, kTechId.None, kTechId.None, kTechId.None }
    
end

-- Temporarily don't use "target" attach point
local kPhaseGateEngagementPointOffset = Vector(0, 0.1, 0)
function PhaseGate:GetEngagementPointOverride()
    return self:GetOrigin() + kPhaseGateEngagementPointOffset
end

function PhaseGate:GetRequiresPower()
    return true
end

function PhaseGate:GetDestLocationId()
    return self.destLocationId
end

function PhaseGate:GetEffectParams(tableParams)

    -- Override active field here to mean "linked"
    tableParams[kEffectFilterActive] = self.linked
    
end

function PhaseGate:GetReceivesStructuralDamage()
    return true
end

function PhaseGate:GetDamagedAlertId()
    return kTechId.MarineAlertStructureUnderAttack
end

function PhaseGate:GetPlayIdleSound()
    return ScriptActor.GetPlayIdleSound(self) and self.linked
end

-- Returns next phase gate in round-robin order. Returns nil if there are no other built/active phase gates
local function GetDestinationGate(self)

    -- Find next phase gate to teleport to
    local phaseGates = {}    
    for index, phaseGate in ipairs( GetEntitiesForTeam("PhaseGate", self:GetTeamNumber()) ) do
        if GetIsUnitActive(phaseGate) then
            table.insert(phaseGates, phaseGate)
        end
    end    
    
    if table.icount(phaseGates) < 2 then
        return nil
    end
    
    -- Find our index and add 1
    local index = table.find(phaseGates, self)
    if (index ~= nil) then
        local nextIndex
        if directionBackwards then
            nextIndex = ConditionalValue(index == 1, table.icount(phaseGates), index - 1)
        else
            nextIndex = ConditionalValue(index == table.icount(phaseGates), 1, index + 1)
        end

        ASSERT(nextIndex >= 1)
        ASSERT(nextIndex <= table.icount(phaseGates))
        return phaseGates[nextIndex]
        
    end
    
    return nil
    
end

local function ComputeDestinationLocationId(self, destGate)

    local destLocationId = Entity.invalidId
    if destGate then
    
        local location = GetLocationForPoint(destGate:GetOrigin())
        if location then
            destLocationId = location:GetId()
        end
        
    end
    
    return destLocationId
    
end

function PhaseGate:Phase(user)

    if self.phase then
        return false
    end

    if HasMixin(user, "PhaseGateUser") and self.linked then

        local destinationCoords = Angles(0, self.targetYaw, 0):GetCoords()
        destinationCoords.origin = self.destinationEndpoint
        
        user:OnPhaseGateEntry(self.destinationEndpoint) --McG: Obsolete for PGs themselves, but required for Achievements
        
        TransformPlayerCoordsForPhaseGate(user, self:GetCoords(), destinationCoords)
        
        user:SetOrigin(self.destinationEndpoint)

        --Mark PG to trigger Phase/teleport FX next update loop. This does incure a _slight_ delay in FX but it's worth it
        --to remove the need for the plyaer-centric 2D sound, and simplify effects definitions
        self.performedPhaseLastUpdate = true

        self.timeOfLastPhase = Shared.GetTime()
        
        return true
        
    end
    
    return false

end

function PhaseGate:GetTechButtons(techId)

    return { kTechId.ReversePhaseGate, kTechId.None, kTechId.None, kTechId.None,
             kTechId.None, kTechId.None, kTechId.None, kTechId.None }

end

if Server then

    function PhaseGate:Update()

        local destinationPhaseGate = GetDestinationGate(self)

        if self.performedPhaseLastUpdate then
            self:TriggerEffects("phase_gate_player_teleport", { effecthostcoords = self:GetCoords() })

            if destinationPhaseGate ~= nil then
                --Force destination gate to trigger effect so the teleporting FX is not visible to enemy with sight on self
                local destinationCoords = Angles(0, self.targetYaw, 0):GetCoords()
                destinationCoords.origin = self.destinationEndpoint
                destinationPhaseGate:TriggerEffects("phase_gate_player_teleport", { effecthostcoords = destinationCoords })
            end

            self.performedPhaseLastUpdate = false
        end

        self.phase = (self.timeOfLastPhase ~= nil) and (Shared.GetTime() < (self.timeOfLastPhase + kPhaseGateTimeout))

        if destinationPhaseGate ~= nil and GetIsUnitActive(self) and self.deployed and destinationPhaseGate.deployed then

            self.destinationEndpoint = destinationPhaseGate:GetOrigin()
            self.linked = true
            self.targetYaw = destinationPhaseGate:GetAngles().yaw
            self.destLocationId = ComputeDestinationLocationId(self, destinationPhaseGate)

            if self.relevancyPortalIndex == -1 then
                -- Create a relevancy portal to the destination to smooth out entity propagation.
                local mask = 0
                local teamNumber = self:GetTeamNumber()
                if teamNumber == 1 then
                    mask = kRelevantToTeam1Unit
                elseif teamNumber == 2 then
                    mask = kRelevantToTeam2Unit
                end

                if mask ~= 0 then
                    self.relevancyPortalIndex = Server.CreateRelevancyPortal(self:GetOrigin(), self.destinationEndpoint, mask, self.kRelevancyPortalRadius)
                end
            end

        else
            self.linked = false
            self.targetYaw = 0
            self.destLocationId = Entity.invalidId

            DestroyRelevancyPortal(self)

        end

        return true

    end

end

function PhaseGate:PerformActivation(techId, position, normal, commander)

    local success = false

    if techId == kTechId.ReversePhaseGate then
        success = true
        directionBackwards = not directionBackwards
    end

    return success, true

end

function PhaseGate:GetConnectionStartPoint()
    return self:GetOrigin()
end

function PhaseGate:GetConnectionEndPoint()

    if GetIsUnitActive(self) and self.linked then
        return self.destinationEndpoint
    end

end

function PhaseGate:OnTag(tagName)

    PROFILE("PhaseGate:OnTag")

    if tagName == "deploy_end" then
        self.deployed = true
    end
    
end

function PhaseGate:OnUpdateRender()

    PROFILE("PhaseGate:OnUpdateRender")

    if self.clientLinked ~= self.linked then
    
        self.clientLinked = self.linked
        
        local effects = ConditionalValue(self.linked and self:GetIsVisible(), "phase_gate_linked", "phase_gate_unlinked")
        self:TriggerEffects(effects) --FIXME This is really wasteful
        
    end

end

function PhaseGate:OnUpdateAnimationInput(modelMixin)

    PROFILE("PhaseGate:OnUpdateAnimationInput")

    modelMixin:SetAnimationInput("linked", self.linked)
    modelMixin:SetAnimationInput("phase", self.phase)
    
end

function PhaseGate:GetHealthbarOffset()
    return 1.2
end 

function PhaseGate:GetDestinationLocationName()

    local location = Shared.GetEntity(self.destLocationId)   
    if location then
        return location:GetName()
    end
    
end

function PhaseGate:GetIsDeployed()
    return self.deployed
end

function PhaseGate:GetIsLinked()
    return self.linked
end

function PhaseGate:OverrideHintString( hintString, forEntity )
    
    if not GetAreEnemies(self, forEntity) then
        local locationName = self:GetDestinationLocationName()
        if locationName and locationName~="" then
            return string.format(Locale.ResolveString( "PHASE_GATE_HINT_TO_LOCATION" ), locationName )
        end
    end

    return hintString
    
end

function CheckSpaceForPhaseGate(techId, origin, normal, commander)
    return GetHasRoomForCapsule(Vector(Player.kXZExtents, Player.kYExtents, Player.kXZExtents), origin + Vector(0, 0.1 + Player.kYExtents, 0), CollisionRep.Default, PhysicsMask.AllButPCsAndRagdolls)
end

Shared.LinkClassToMap("PhaseGate", PhaseGate.kMapName, networkVars)
