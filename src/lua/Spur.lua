-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Spur.lua
--
--    Created by:   Andreas Urwalek (a_urwa@sbox.tugraz.at)
--
--    Alien structure that hosts Spur upgrades. 1 Spur: level 1 upgrade, 2 Spurs: level 2 etc.
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
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/DouseMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/BiomassMixin.lua")
Script.Load("lua/ConsumeMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/BlowtorchTargetMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/AlienStructureMoveMixin.lua")

class 'Spur' (ScriptActor)

Spur.kMapName = "spur"

Spur.kModelName = PrecacheAsset("models/alien/spur/spur.model")

Spur.kAnimationGraph = PrecacheAsset("models/alien/spur/spur.animation_graph")

Spur.kWalkingSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/walk")
Spur.kMoveSpeed = 2.9 / 2

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
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(ConsumeMixin, networkVars)
AddMixinNetworkVars(AlienStructureMoveMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)

function Spur:OnCreate()

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
    InitMixin(self, MaturityMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, BiomassMixin)
    InitMixin(self, ConsumeMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, AlienStructureMoveMixin, { kAlienStructureMoveSound = Spur.kWalkingSound })
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
		self.electrified = false
		self.timeElectrifyEnds = 0
    elseif Client then
        InitMixin(self, CommanderGlowMixin)    
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
end

function Spur:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Spur.kModelName, Spur.kAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, SleeperMixin)
		InitMixin(self, RepositioningMixin)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
		InitMixin(self, RailgunTargetMixin)
		InitMixin(self, BlowtorchTargetMixin)
        
    end

end

function Spur:GetBioMassLevel()
    return kSpurBiomass
end

function Spur:GetHealthbarOffset()
    return 0.6
end

function Spur:GetMaturityRate()
    return kSpurMaturationTime
end

function Spur:GetMatureMaxHealth()
    return kMatureSpurHealth
end 

function Spur:GetMatureMaxArmor()
    return kMatureSpurArmor
end 

function Spur:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function Spur:GetReceivesStructuralDamage()
    return true
end

function Spur:GetIsSmallTarget()
    return true
end

function Spur:GetCanSleep()
    return true
end

function Spur:GetIsWallWalkingAllowed()
    return false
end 

if Server then

    function Spur:GetDestroyOnKill()
        return true
    end

    function Spur:OnKill(attacker, doer, point, direction)

        ScriptActor.OnKill(self, attacker, doer, point, direction)
        self:TriggerEffects("death")
    
    end

end

function Spur:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function Spur:OverrideHintString(hintString)

    if self:GetIsUpgrading() then
        return "COMM_SEL_UPGRADING"
    end
    
    return hintString
    
end

function Spur:GetTechButtons(techId)

    local techButtons = { kTechId.Move, kTechId.SpurPassive, kTechId.None, kTechId.None,
                          kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }

    if self.moving then
        techButtons[1] = kTechId.Stop
    end

    return techButtons
end

-- %%% New CBM Functions %%% --
function Spur:GetMaxSpeed()
    return Spur.kMoveSpeed
end

function Spur:OverrideRepositioningSpeed()
    return Spur.kMoveSpeed
end

function Spur:GetCanReposition()
    return true
end

function Spur:OnOrderChanged()
    if self:GetIsConsuming() then
        self:CancelResearch()
    end

    local currentOrder = self:GetCurrentOrder()
    if GetIsUnitActive(self) and currentOrder and currentOrder:GetType() == kTechId.Move then
        self:SetUpdateRate(kRealTimeUpdateRate)
    end
end


function Spur:PerformAction(techNode)
    if techNode:GetTechId() == kTechId.Stop then
        self:ClearOrders()
    end
end

Shared.LinkClassToMap("Spur", Spur.kMapName, networkVars)

if Client then
    
	function Spur:GetShowElectrifyEffect()
		return self.electrified
	end
	
    function Spur:OnUpdateRender()

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

function Spur:OnUpdate(deltaTime)

    if Server then
		self.electrified = self.timeElectrifyEnds > Shared.GetTime()
		
        if self.electrified then
			Spur.kMoveSpeed = 0
		else
			Spur.kMoveSpeed = 2.9 / 2
		end
    end
end

function Spur:SetElectrified(time)

    if self.timeElectrifyEnds - Shared.GetTime() < time then

        self.timeElectrifyEnds = Shared.GetTime() + time
        self.electrified = true

    end
end