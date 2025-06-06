-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Shell.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
--    Alien structure that hosts Shell upgrades. 1 shell: level 1 upgrade, 2 shells: level 2 etc.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

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
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DouseMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/BiomassMixin.lua")
Script.Load("lua/ConsumeMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/BlowtorchTargetMixin.lua")

class 'Shell' (ScriptActor)

Shell.kMapName = "shell"

Shell.kModelName = PrecacheAsset("models/alien/shell/shell.model")

local kAnimationGraph = PrecacheAsset("models/alien/shell/shell.animation_graph")

Shell.kRegenHealRate = 0.01

local networkVars =
{ 
	electrified = "boolean"
}

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
AddMixinNetworkVars(ConsumeMixin, networkVars)

function Shell:OnCreate()

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
    InitMixin(self, ConsumeMixin)
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
		self.electrified = false
		self.timeElectrifyEnds = 0
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, RailgunTargetMixin)
		InitMixin(self, BlowtorchTargetMixin)		
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
end

function Shell:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Shell.kModelName, kAnimationGraph)
    
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

end

function Shell:GetIsSmallTarget()
    return true
end

function Shell:GetBioMassLevel()
    return kShellBiomass
end

function Shell:GetMaturityRate()
    return kShellMaturationTime
end

function Shell:GetMatureMaxHealth()
    return kMatureShellHealth
end 

function Shell:GetHealthbarOffset()
    return 0.45
end

function Shell:GetMatureMaxArmor()
    return kMatureShellArmor
end 

function Shell:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function Shell:GetCanSleep()
    return true
end

function Shell:GetIsWallWalkingAllowed()
    return false
end 

function Shell:GetReceivesStructuralDamage()
    return true
end

if Server then
    
    function Shell:GetDestroyOnKill()
        return true
    end

    function Shell:OnKill(attacker, doer, point, direction)

        ScriptActor.OnKill(self, attacker, doer, point, direction)
        self:TriggerEffects("death")
    
    end

end

function Shell:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function Shell:OverrideHintString(hintString)

    if self:GetIsUpgrading() then
        return "COMM_SEL_UPGRADING"
    end
    
    return hintString
    
end

function Shell:GetTechButtons(techId)

    local techButtons = { kTechId.ShellPassive, kTechId.None, kTechId.None, kTechId.None,
                          kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }

    return techButtons

end

Shared.LinkClassToMap("Shell", Shell.kMapName, networkVars)

-- %%% New CBM Functions %%% --

function Shell:OnUpdate(deltaTime)

    if Server then
		
		self.electrified = self.timeElectrifyEnds > Shared.GetTime()
		
        self.hasRegeneration = not self:GetIsInCombat() and self:GetIsBuilt() and not self.electrified

        if self.hasRegeneration then

            if self:GetIsHealable() and ( not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() ) then

                self:AddHealth(self.kRegenHealRate * self:GetMaxHealth())
                self.timeLastAlienAutoHeal = Shared.GetTime()

            end

        end
    end

end

if Client then
    
	function Shell:GetShowElectrifyEffect()
		return self.electrified
	end
	
    function Shell:OnUpdateRender()

		local model = self:GetRenderModel()
		local electrified = self:GetShowElectrifyEffect()

		if model then
			if self.electrifiedClient ~= electrified then
			
				if electrified then
					self.electrifiedMaterial = AddMaterial(model, Alien.kElectrifiedThirdpersonMaterialName)
					self.electrifiedMaterial:SetParameter("elecAmount",  1.5)
				else
					if RemoveMaterial(model, self.electrifiedMaterial) then
						self.electrifiedMaterial = nil
					end
				end
				self.electrifiedClient = electrified
			end
		end
    end
end

function Shell:SetElectrified(time)

    if self.timeElectrifyEnds - Shared.GetTime() < time then

        self.timeElectrifyEnds = Shared.GetTime() + time
        self.electrified = true

    end
end