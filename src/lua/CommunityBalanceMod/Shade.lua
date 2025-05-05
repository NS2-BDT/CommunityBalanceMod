-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Shade.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- Alien structure that provides cloaking abilities and confuse and deceive capabilities.
--
-- Disorient (Passive) - Enemy structures and players flicker in and out when in range of Shade,
-- making it hard for Commander and team-mates to be able to support each other. Extreme reverb
-- sounds for enemies (and slight reverb sounds for friendlies) enhance the effect.
--
-- Cloak (Triggered) - Instantly cloaks self and all enemy structures and aliens in range
-- for a short time. Mutes or changes sounds too? Cleverly used, this would ideally allow a
-- team to get a stealth hive built. Allow players to stay cloaked for awhile, until they attack
-- (even if they move out of range - great for getting by sentries).
--
-- Hallucination - Allow Commander to create fake Fade, Onos, Hive (and possibly
-- ammo/medpacks). They can be pathed around and used to create tactical distractions or divert
-- forces elsewhere.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Mixins/ClientModelMixin.lua")
Script.Load("lua/LiveMixin.lua")
Script.Load("lua/UpgradableMixin.lua")
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
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/CommAbilities/Alien/ShadeInk.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/CommunityBalanceMod/DouseMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/TriggerMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/BiomassMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ConsumeMixin.lua")
Script.Load("lua/CommunityBalanceMod/ShadeHallucination.lua") -- by twilite
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/CommunityBalanceMod/BlowtorchTargetMixin.lua")
Script.Load("lua/BiomassHealthMixin.lua")

class 'Shade' (ScriptActor)

Shade.kMapName = "shade"

Shade.kModelName = PrecacheAsset("models/alien/shade/shade.model")
local kAnimationGraph = PrecacheAsset("models/alien/shade/shade.animation_graph")

local kCloakTriggered = PrecacheAsset("sound/NS2.fev/alien/structures/shade/cloak_triggered")
local kCloakTriggered2D = PrecacheAsset("sound/NS2.fev/alien/structures/shade/cloak_triggered_2D")
local kFortressShadeMaterial = PrecacheAsset("models/alien/Shade/Shade_adv.material")

Shade.kCloakRadius = 17
Shade.kSonarRadius = 33

Shade.kCloakUpdateRate = 0.2

Shade.kMoveSpeed = 2.9
Shade.kMaxInfestationCharge = 10
Shade.kModelScale = 0.8

Shade.kSonarInterval = 5
Shade.kSonarParaTime = 5.5

local networkVars = { 
    moving = "boolean",
	infestationSpeedCharge = "float",
	electrified = "boolean"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ClientModelMixin, networkVars)
AddMixinNetworkVars(LiveMixin, networkVars)
AddMixinNetworkVars(UpgradableMixin, networkVars)
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
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ConsumeMixin, networkVars)

function Shade:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ClientModelMixin)
    InitMixin(self, LiveMixin)
    InitMixin(self, UpgradableMixin)
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
    InitMixin(self, RagdollMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, ObstacleMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, TeleportMixin)
    InitMixin(self, UmbraMixin)
	InitMixin(self, DouseMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, MaturityMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, BiomassMixin)
    InitMixin(self, ConsumeMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
	InitMixin(self, BiomassHealthMixin)
    
	self.fortressShadeAbilityActive = false
    self.fortressShadeMaterial = false
	
    if Server then
		self.timeOfLastSonar = 0
		self.infestationSpeedCharge = 0
		self.electrified = false
		self.timeElectrifyEnds = 0
        --InitMixin(self, TriggerMixin, {kPhysicsGroup = PhysicsGroup.TriggerGroup, kFilterMask = PhysicsMask.AllButTriggers} )
        InitMixin(self, InfestationTrackerMixin)
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, RailgunTargetMixin)
		InitMixin(self, BlowtorchTargetMixin)		
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
end

function Shade:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Shade.kModelName, kAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SupplyUserMixin)

        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
    
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)
        InitMixin(self, HiveVisionMixin)
        
    end
    
    InitMixin(self, IdleMixin)

end

function Shade:GetBioMassLevel()
    return kShadeBiomass
end

function Shade:GetMaturityRate()
    return kShadeMaturationTime
end

function Shade:OverrideRepositioningSpeed()
    return Shade.kMoveSpeed
end

function Shade:PreventTurning()
    return true
end

function Shade:GetHealthPerBioMass()
    if self:GetTechId() == kTechId.FortressShade then
        return kFortressShadeHealthPerBioMass
    end

    return 0
end

function Shade:GetMatureMaxHealth()

    if self:GetTechId() == kTechId.FortressShade then
        return kFortressMatureShadeHealth
    end

    return kMatureShadeHealth
end


function Shade:GetMatureMaxArmor()

    if self:GetTechId() == kTechId.FortressShade then
        return kFortressMatureShadeArmor
    end

    return kMatureShadeArmor
end    

function Shade:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function Shade:GetCanDie(byDeathTrigger)
    return not byDeathTrigger
end

function Shade:GetTechButtons(techId)


    local techButtons = { kTechId.ShadeInk, kTechId.Move, kTechId.ShadeCloak, kTechId.None, 
                          kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
                          
    if self.moving then
        techButtons[2] = kTechId.Stop
    end
    

    if self:GetTechId() == kTechId.Shade and self:GetResearchingId() ~= kTechId.UpgradeToFortressShade then
        techButtons[5] = kTechId.UpgradeToFortressShade
      end

    -- remove fortress ability button for normal shade if there is a fortress shade somewhere
    if not ( self:GetTechId() == kTechId.Shade and GetHasTech(self, kTechId.FortressShade) ) and not self.moving then 
        techButtons[6] = kTechId.ShadeHallucination
        techButtons[7] = kTechId.SelectHallucinations
		techButtons[4] = kTechId.ShadeSonar
    end

    return techButtons
    
end


function Shade:OnConsumeTriggered()
    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
        self:CompletedCurrentOrder()
        self:ClearOrders()
    end
end

function Shade:OnOrderGiven(order)
end

function Shade:PerformAction(techNode)

    if techNode:GetTechId() == kTechId.Stop then
        self:ClearOrders()
    end

end

function Shade:OnResearchComplete(researchId)

    -- Transform into mature shade
    if researchId == kTechId.EvolveHallucinations then
        success = self:GiveUpgrade(kTechId.ShadePhantomMenu)
    end
    
end

function Shade:TriggerInk()

    -- Create ShadeInk entity in world at this position with a small offset
    CreateEntity(ShadeInk.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())
    self:TriggerEffects("shade_ink")
    return true

end

function Shade:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if techId == kTechId.ShadeInk then
        success = self:TriggerInk()
    end
	
	if techId == kTechId.ShadeHallucination then
        success = self:TriggerFortressShadeAbility(commander)
    end
    
    return success, true
    
end

function Shade:GetReceivesStructuralDamage()
    return true
end

function Shade:OnUpdateAnimationInput(modelMixin)

    PROFILE("Shade:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("cloak", true)
    modelMixin:SetAnimationInput("moving", self.moving)
    
end

function Shade:GetMaxSpeed()

    if self:GetTechId() == kTechId.FortressShade then
        return Shade.kMoveSpeed * (0.5 + 0.75 * self.infestationSpeedCharge/Shade.kMaxInfestationCharge)
    end
	
	if self.electrified then
		return Shade.kMoveSpeed * 0.5
	end

    return Shade.kMoveSpeed * 1.25
end

function Shade:OnTeleportEnd()
    self:ResetPathing()
end

function Shade:GetCanReposition()
    return true
end

if Server then

    function Shade:OnConstructionComplete()
        self:AddTimedCallback(Shade.UpdateCloaking, Shade.kCloakUpdateRate)    
    end
    
    function Shade:UpdateCloaking()
    
        if not self:GetIsOnFire() and not self.electrified then
            for _, cloakable in ipairs( GetEntitiesWithMixinForTeamWithinRange("Cloakable", self:GetTeamNumber(), self:GetOrigin(), Shade.kCloakRadius) ) do
                cloakable:TriggerCloak()
            end
        end
        
        return self:GetIsAlive()
    
    end

end

function Shade:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function Shade:OnOrderChanged()
    --This will cancel Consume if it is running.
    if self:GetIsConsuming() then
        self:CancelResearch()
    end

    local currentOrder = self:GetCurrentOrder()
    if GetIsUnitActive(self) and currentOrder and currentOrder:GetType() == kTechId.Move then
        self:SetUpdateRate(kRealTimeUpdateRate)
    end
end

function Shade:OnOrderComplete()
    self:SetUpdateRate(kDefaultUpdateRate)
end

function Shade:OnUpdate(deltaTime)

    ScriptActor.OnUpdate(self, deltaTime)        
    UpdateAlienStructureMove(self, deltaTime)
		
	if Server then
	
		self.electrified = self.timeElectrifyEnds > Shared.GetTime()
			
		if GetIsUnitActive(self) then
		
			if self.electrified then
				self.infestationSpeedCharge = 0
			else
				if (self:GetTechId() == kTechId.FortressShade) and GetHasTech(self, kTechId.ShadeHive) and not self.moving then
					self:PerformSonar()
				end
			
				if self:GetGameEffectMask(kGameEffect.OnInfestation) then
					self.timeOfLastInfestion = Shared.GetTime()
					self.infestationSpeedCharge = math.max(0, math.min(Shade.kMaxInfestationCharge, self.infestationSpeedCharge + 2.0*deltaTime))
				else
					self.infestationSpeedCharge = math.max(0, math.min(Shade.kMaxInfestationCharge, self.infestationSpeedCharge - deltaTime))
				end
			end
		end
    end
end

function Shade:GetTechAllowed(techId, techNode, player)

   
    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    allowed = allowed and not self:GetIsOnFire()


     -- dont allow upgrading while moving or if something else researches upgrade or another fortress Shade exists.
    if techId == kTechId.UpgradeToFortressShade then
        allowed = allowed and not self.moving

        allowed = allowed and not GetHasTech(self, kTechId.FortressShade) and not  GetIsTechResearching(self, techId)
    end

    -- dont allow normal Shades to use the new fortress ability
    if techId == kTechId.ShadeHallucination then
        allowed = allowed and ( self:GetTechId() == kTechId.FortressShade ) and GetHasTech(self, kTechId.ShadeHive)
    end

    -- ShadeInk Shadehive requirement got removed
    if techId == kTechId.ShadeInk and self:GetTechId() == kTechId.Shade then 
        allowed = allowed and GetHasTech(self, kTechId.ShadeHive)
    end



    return allowed, canAfford
    
end

Shared.LinkClassToMap("Shade", Shade.kMapName, networkVars)

-- %%% New CBM Functions %%% --
function Shade:GetOffInfestationHurtPercentPerSecond()

    if self:GetTechId() == kTechId.FortressShade then 
        return kBalanceOffInfestationHurtPercentPerSecondFortress
    end

    return kBalanceOffInfestationHurtPercentPerSecond
end

function Shade:GetShouldRepositionDuringMove()
    return false
end

function Shade:OverrideRepositioningDistance()
    return 0.7
end  

function Shade:PerformSonar()

	if not self:GetIsOnFire() and (self.timeOfLastSonar == 0 or (Shared.GetTime() > self.timeOfLastSonar + Shade.kSonarInterval) ) then

		local enemyTeamNumber = GetEnemyTeamNumber(self:GetTeamNumber())
		local targets = GetEntitiesWithMixinForTeamWithinRange("BlightAble", enemyTeamNumber, self:GetOrigin(), Shade.kSonarRadius)
		
		for _, target in ipairs(targets) do
			if target:GetIsAlive() then
				target:SetBlighted(Shade.kSonarParaTime)
			end
		end
		
		if #targets > 0 then
			self.timeOfLastSonar = Shared.GetTime()
		end	
	end
end

class 'FortressShade' (Shade)
FortressShade.kMapName = "fortressShade"
Shared.LinkClassToMap("FortressShade", FortressShade.kMapName, {})

if Server then 
    
    function Shade:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeToFortressShade then
        
            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Shade)   -- get a progress bar at the Shade in the tech tree. TODO Does this affect spec, comm view?
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
            
        end
    end


    function Shade:OnResearchCancel(researchId)

        if researchId == kTechId.UpgradeToFortressShade then
        
            local team = self:GetTeam()
            
            if team then
            
                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.Shade)
                if researchNode then
                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
                end
            end  
        end
    end

    -- Called when research or upgrade complete
    function Shade:OnResearchComplete(researchId)

        if researchId == kTechId.UpgradeToFortressShade then
        
           -- self:SetTechId(kTechId.FortressShade)
            self:UpgradeToTechId(kTechId.FortressShade)
            
            self:MarkBlipDirty()

            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.Shade)
            
            if researchNode then     
    
                researchNode:SetResearchProgress(1)
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.FortressShade, self)
            end

			local team = self:GetTeam()
			local bioMassLevel = team and team.GetBioMassLevel and team:GetBioMassLevel() or 0
			self:UpdateHealthAmount(bioMassLevel)
        end
    end
end

if Client then

	function Shade:GetShowElectrifyEffect()
		return self.electrified
	end
    
    function Shade:OnUpdateRender()

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

	    if not self.fortressShadeMaterial and self:GetTechId() == kTechId.FortressShade then

			if model and model:GetReadyForOverrideMaterials() then
			
				model:ClearOverrideMaterials()
				
				model:SetOverrideMaterial( 0, kFortressShadeMaterial )

				model:SetMaterialParameter("highlight", 0.91)

				self.fortressShadeMaterial = true
			end
	    end
    end
end

function Shade:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if self:GetTechId() == kTechId.Shade then
        modelCoords.xAxis = modelCoords.xAxis * Shade.kModelScale
        modelCoords.yAxis = modelCoords.yAxis * Shade.kModelScale
        modelCoords.zAxis = modelCoords.zAxis * Shade.kModelScale
    end

    return modelCoords
end

function Shade:GetCanTeleportOverride()
    return not ( self:GetTechId() == kTechId.FortressShade )
end

function Shade:TriggerFortressShadeAbility(commander)

     -- Create ShadeHallucination entity in world at this position with a small offset
     CreateEntity(ShadeHallucination.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())

     return true

end

if Server then
    function Shade:OnKill(attacker, doer, point, direction)
        ScriptActor.OnKill(self, attacker, doer, point, direction)
    end
end

function Shade:SetElectrified(time)

    if self.timeElectrifyEnds - Shared.GetTime() < time then

        self.timeElectrifyEnds = Shared.GetTime() + time
        self.electrified = true

    end

end

function Shade:GetElectrified()
    return self.electrified
end