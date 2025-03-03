-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AlienStructure.lua
--
--    Created by:   Mats Olsson (mats.olsson@matsotech.se)
--
--    Base class for an alien building. Collects all the standard mixins.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")

-- None of the alien structures are continously animated on the server side
-- for performance reasons (and because it usually doesn't matter).
Script.Load("lua/Mixins/ClientModelMixin.lua")

Script.Load("lua/LiveMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/GameEffectsMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/FlinchMixin.lua")
Script.Load("lua/CloakableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/DetectableMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/EntityChangeMixin.lua")
Script.Load("lua/ConstructMixin.lua")
Script.Load("lua/ResearchMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/FireMixin.lua")
-- server side optimization
Script.Load("lua/SleeperMixin.lua")
-- allows the use of nutrientmist to speed up construction/maturity
Script.Load("lua/CatalystMixin.lua")
-- allows use of Echo
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/CommunityBalanceMod/DouseMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/BiomassMixin.lua")
Script.Load("lua/StaticTargetMixin.lua")

class 'AlienStructure' (ScriptActor)

local networkVars = {}

AlienStructure.kMapName = "AlienStructure"

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(GameEffectsMixin, networkVars)
AddMixinNetworkVars(FlinchMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(ConstructMixin, networkVars)
AddMixinNetworkVars(ResearchMixin, networkVars)
AddMixinNetworkVars(ObstacleMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(TeleportMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(DouseMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)

function AlienStructure:OnCreate(matureMaxHealth, matureMaxArmor, maturityRate, biomassLevel)

    ASSERT(matureMaxHealth)
    ASSERT(matureMaxArmor)
    ASSERT(maturityRate)
    ASSERT(biomassLevel)

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
    InitMixin(self, CloakableMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, DetectableMixin)
    InitMixin(self, ConstructMixin)
    InitMixin(self, ResearchMixin)
    InitMixin(self, ObstacleMixin)    
    InitMixin(self, FireMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, TeleportMixin)    
    InitMixin(self, UmbraMixin)
	InitMixin(self, DouseMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, MaturityMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, BiomassMixin)
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
    elseif Client then
        InitMixin(self, CommanderGlowMixin)    
    end
    
    self.matureMaxHealth = matureMaxHealth
    self.matureMaxArmor = matureMaxArmor
    self.maturityRate = maturityRate
    self.biomassLevel = biomassLevel
	    
    -- defaults
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
end

function AlienStructure:OnInitialized(modelName, animationGraph)

    ASSERT(modelName)
    ASSERT(animationGraph)

    ScriptActor.OnInitialized(self)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, SleeperMixin)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end

    self:SetModel(modelName, animationGraph)

end

function AlienStructure:GetBioMassLevel()
    return self.biomassLevel
end

function AlienStructure:GetMaturityRate()
    return self.maturityRate
end

function AlienStructure:GetMatureMaxHealth()
    return self.matureMaxHealth
end 

function AlienStructure:GetMatureMaxArmor()
    return self.matureMaxArmor
end 

-- ---
-- You MAY want to override these (but usually you don't)
-- ---
function AlienStructure:GetReceivesStructuralDamage()
    return true
end

-- used by the SleeperMixin to sleep the building when the server gets overloaded
function AlienStructure:GetCanSleep()
    return true
end

-- This is used for the Spreading damage type
function AlienStructure:GetIsSmallTarget()
    return true
end

-- if building should react to players trying to use it
function AlienStructure:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

-- most alien buildings can't be wallwalked on (they are to small to make it look good)
-- override if desired
function AlienStructure:GetIsWallWalkingAllowed()
    return false
end

function AlienStructure:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end


-- ---
-- End MAY override block
-- ---

if Server then
    
    function AlienStructure:GetDestroyOnKill()
        return true
    end

    function AlienStructure:OnKill(attacker, doer, point, direction)

        ScriptActor.OnKill(self, attacker, doer, point, direction)
        self:TriggerEffects("death")
    
    end

end



Shared.LinkClassToMap("AlienStructure", AlienStructure.kMapName, networkVars)
