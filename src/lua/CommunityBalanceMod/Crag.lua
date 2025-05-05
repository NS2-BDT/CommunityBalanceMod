-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Crag.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- Alien structure that gives the commander defense and protection abilities.
--
-- Passive ability - heals nearby players and structures
-- Triggered ability - emit defensive Douse (8 seconds)
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
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/ScriptActor.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/SleeperMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/TargetCacheMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/CommunityBalanceMod/DouseMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/BiomassMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ConsumeMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/CommunityBalanceMod/BlowtorchTargetMixin.lua")
Script.Load("lua/BiomassHealthMixin.lua")

class 'Crag' (ScriptActor)

Crag.kMapName = "crag"

Crag.kModelName = PrecacheAsset("models/alien/crag/crag.model")

local CragkAnimationGraph = PrecacheAsset("models/alien/crag/crag.animation_graph")
local CragkfortressCragMaterial = PrecacheAsset("models/alien/crag/crag_adv.material")
local kElectrifiedMaterialName = PrecacheAsset("cinematics/vfx_materials/pulse_gre_elec.material")
Crag.kMoveSpeed = 2.9
Crag.kMaxInfestationCharge = 10

Crag.kModelScale = 0.8
Crag.kDouseInterval = 2
Crag.kCragDouse = 3
Crag.kDouseRadius = 10

-- Same as NS1
Crag.kHealRadius = 14
Crag.kHealAmount = 10
Crag.kHealWaveAmount = 50
Crag.kMaxTargets = 3
Crag.kThinkInterval = .25
Crag.kHealInterval = 2
Crag.kHealEffectInterval = 1

Crag.kHealWaveDuration = 8
Crag.kHealWaveInterval = 1

Crag.kHealPercentage = 0.042
Crag.kMinHeal = 7
Crag.kMaxHeal = 42
Crag.kHealWaveMultiplier = 1.3

Crag.kMaxSpeed = 2.9

local networkVars =
{
    -- For client animations
    healingActive = "boolean",
    healWaveActive = "boolean",
    
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

function Crag:OnCreate()

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
    InitMixin(self, ObstacleMixin)
    InitMixin(self, CatalystMixin)
    InitMixin(self, TeleportMixin)    
	InitMixin(self, UmbraMixin)
	InitMixin(self, DouseMixin)
	InitMixin(self, FireMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, MaturityMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, BiomassMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, ConsumeMixin)
	InitMixin(self, BiomassHealthMixin)
    
    self.healingActive = false
    self.healWaveActive = false
	self.fortressCragAbilityActive = false
    self.fortressCragMaterial = false
    self:SetUpdates(true, Crag.kThinkInterval)
    
    if Server then
        InitMixin(self, InfestationTrackerMixin)
        self.timeOfLastHeal = 0
        self.timeOfLastHealWave = 0
		self.timeOfLastHealWavePulse = 0
		self.timeOfLastDouse = 0
		self.infestationSpeedCharge = 0
		self.electrified = false
		self.timeElectrifyEnds = 0
    elseif Client then    
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, RailgunTargetMixin)
		InitMixin(self, BlowtorchTargetMixin)
		self.electrifiedClient = false		
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
end

function Crag:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Crag.kModelName, CragkAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, SleeperMixin)
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SupplyUserMixin)
        
        -- TODO: USE TRIGGERS, see shade

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

function Crag:PreventTurning()
    return true
end

function Crag:GetBioMassLevel()
    return kCragBiomass
end

function Crag:GetCanReposition()
    return true
end

function Crag:OverrideRepositioningSpeed()
    return Crag.kMoveSpeed
end

function Crag:GetMaturityRate()
    return kCragMaturationTime
end

function Crag:GetHealthPerBioMass()
    if self:GetTechId() == kTechId.FortressCrag then
        return kFortressCragHealthPerBioMass
    end

    return 0
end

function Crag:GetMatureMaxHealth()

    if self:GetTechId() == kTechId.FortressCrag then
        return kFortressMatureCragHealth
    end

    return kMatureCragHealth
end

function Crag:GetMatureMaxArmor()

    if self:GetTechId() == kTechId.FortressCrag then
        return kFortressMatureCragArmor
    end

    return kMatureCragArmor
end    

function Crag:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function Crag:GetCanSleep()
    return not self.healingActive and not self.healWaveActive
end

function Crag:GetHealTargets()

    local targets = {}

    for _, healable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), Crag.kHealRadius)) do
        if healable:GetIsAlive() then
            table.insert(targets, healable)
        end
    end

    return targets

end

function Crag:PerformHealing()

    PROFILE("Crag:PerformHealing")

    local targets = self:GetHealTargets()

    local totalHealed = 0
    for _, target in ipairs(targets) do
        totalHealed = totalHealed + self:TryHeal(target)
    end

    if #targets > 0 and totalHealed > 0 then
        self.timeOfLastHeal = Shared.GetTime()
    end

    if totalHealed == 0 then
        self.timeOfLastHeal = 0
    end

end

local kTechIdToLifeformHeal =
{
    [kTechId.Skulk] = 10,
    [kTechId.Gorge] = 15,
    [kTechId.Lerk] = 16,
    [kTechId.Fade] = 25,
    [kTechId.Onos] = 80,
}

function Crag:TryHeal(target)

    local unclampedHeal = target:GetMaxHealth() * Crag.kHealPercentage
    local heal = Clamp(unclampedHeal, Crag.kMinHeal, Crag.kMaxHeal)
    
    if target.GetTechId then
        heal = kTechIdToLifeformHeal[target:GetTechId()] or heal
    end

    --[[if self.healWaveActive then
        heal = heal * Crag.kHealWaveMultiplier
    end]]
    
    if target:GetHealthScalar() ~= 1 and (not target.timeLastCragHeal or target.timeLastCragHeal + Crag.kHealInterval <= Shared.GetTime()) then
    

        local amountHealed = target:AddHealth(heal, false, false, false, self, true)
        target.timeLastCragHeal = Shared.GetTime()
        return amountHealed
        
    else
        return 0
    end
    
end

function Crag:UpdateHealing()    
    if not self:GetIsOnFire() and ( self.timeOfLastHeal == 0 or (Shared.GetTime() > self.timeOfLastHeal + Crag.kHealInterval) ) then    
        self:PerformHealing()
    end
end

function Crag:UpdateMucous()
	if not self:GetIsOnFire() and self.healWaveActive then
		if (self.timeOfLastHealWavePulse == 0 or (Shared.GetTime() > self.timeOfLastHealWavePulse + Crag.kHealWaveInterval)) then
			--Activate shield on any 'mucousable' ents nearby
			for _, unit in ipairs(GetEntitiesWithMixinForTeamWithinRange("Mucousable", self:GetTeamNumber(), self:GetOrigin(), Crag.kHealRadius)) do
				--local maxHealth = unit:GetMaxHealth()
				--unit:AddOverShield(0.02*maxHealth)
				unit:SetMucousShield()
			end
			self.timeOfLastHealWavePulse = Shared.GetTime()
		end
	end
end

function Crag:OnConsumeTriggered()
    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
        self:CompletedCurrentOrder()
        self:ClearOrders()
    end
end

function Crag:GetMaxSpeed()

    if self:GetTechId() == kTechId.FortressCrag then
        return Crag.kMoveSpeed * (0.5 + 0.75 * self.infestationSpeedCharge/Crag.kMaxInfestationCharge)
    end

	if self.electrified then
		return Crag.kMoveSpeed * 0.5
	end

    return Crag.kMoveSpeed * 1.25
end

function Crag:OnOrderChanged()
    if self:GetIsConsuming() then
        self:CancelResearch()
    end

    local currentOrder = self:GetCurrentOrder()
    if GetIsUnitActive(self) and currentOrder and currentOrder:GetType() == kTechId.Move then
        self:SetUpdateRate(kRealTimeUpdateRate)
    end
end

function Crag:OnOrderComplete()
    self:SetUpdateRate(Crag.kThinkInterval)
end

-- Look for nearby friendlies to heal
function Crag:OnUpdate(deltaTime)
    
    PROFILE("Crag:OnUpdate")

    ScriptActor.OnUpdate(self, deltaTime)
    
    UpdateAlienStructureMove(self, deltaTime)
    
    local time = Shared.GetTime()

    if Server then
		
		self.electrified = self.timeElectrifyEnds > Shared.GetTime()
		
        if GetIsUnitActive(self) then
			
			if self.electrified then
				self.healingActive = false
				self.healWaveActive = time < self.timeOfLastHealWave + Crag.kHealWaveDuration and self.timeOfLastHealWave > 0
				self.infestationSpeedCharge = 0
			else
				if (self:GetTechId() == kTechId.FortressCrag) and GetHasTech(self, kTechId.CragHive) and not self.moving then
					self:PerformDouse()
				end
			
				self:UpdateHealing()
				self.healingActive = time < self.timeOfLastHeal + Crag.kHealInterval and self.timeOfLastHeal > 0
				self.healWaveActive = time < self.timeOfLastHealWave + Crag.kHealWaveDuration and self.timeOfLastHealWave > 0
				
				if self:GetGameEffectMask(kGameEffect.OnInfestation) then
					self.timeOfLastInfestion = Shared.GetTime()
					self.infestationSpeedCharge = math.max(0, math.min(Crag.kMaxInfestationCharge, self.infestationSpeedCharge + 2.0*deltaTime))
				else
					self.infestationSpeedCharge = math.max(0, math.min(Crag.kMaxInfestationCharge, self.infestationSpeedCharge - deltaTime))
				end
			end
			
			self:UpdateMucous()
			
		end

    elseif Client then

        if self.healWaveActive or self.healingActive then
        
            if not self.lastHealEffect or self.lastHealEffect + Crag.kHealEffectInterval < time then
            
                local localPlayer = Client.GetLocalPlayer()
                local showHeal = not HasMixin(self, "Cloakable") or not self:GetIsCloaked() or not GetAreEnemies(self, localPlayer)
        
                if showHeal then
                
                    if self.healWaveActive then
                        self:TriggerEffects("crag_heal_wave")
                    elseif self.healingActive then
                        self:TriggerEffects("crag_heal")
                    end
                    
                end
                
                self.lastHealEffect = time
            
            end
            
        end
    
    end
    
end

function Crag:GetTechButtons(techId)

    local techButtons = { kTechId.HealWave, kTechId.Move, kTechId.CragHeal, kTechId.None,
                          kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
    
    if self.moving then
        techButtons[2] = kTechId.Stop
    end

    if self:GetTechId() == kTechId.Crag and self:GetResearchingId() ~= kTechId.UpgradeToFortressCrag then
        techButtons[5] = kTechId.UpgradeToFortressCrag
    end

    -- remove fortress ability button for normal crags if there is a fortress crag somewhere
    if not ( self:GetTechId() == kTechId.Crag and GetHasTech(self, kTechId.FortressCrag) ) and not self.moving then 
        techButtons[4] = kTechId.FortressCragAbility
    end

    return techButtons
    
end

function Crag:PerformAction(techNode)

    if techNode:GetTechId() == kTechId.Stop then
        self:ClearOrders()
    end

end

function Crag:OnTeleportEnd()
    self:ResetPathing()
end

function Crag:GetCanHeal()
    return self:GetIsAlive() and self:GetIsBuilt() and not self:GetIsOnFire()
end

function Crag:TriggerHealWave(commander)

    self.timeOfLastHealWave = Shared.GetTime()
    return true
    
end

function Crag:GetReceivesStructuralDamage()
    return true
end

function Crag:GetTechAllowed(techId, techNode, player)


    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    allowed = allowed and not self:GetIsOnFire()


     -- dont allow upgrading while moving or if something else researches upgrade or another fortress crag exists.
    if techId == kTechId.UpgradeToFortressCrag then
        allowed = allowed and not self.moving

        allowed = allowed and not GetHasTech(self, kTechId.FortressCrag) and not  GetIsTechResearching(self, techId)
    end

    -- dont allow normal crags to use the new fortress ability.
    if techId == kTechId.FortressCragAbility then
        allowed = allowed and ( self:GetTechId() == kTechId.FortressCrag ) and GetHasTech(self, kTechId.CragHive)
    end

    -- Healwave craghive requirement got removed
    if techId == kTechId.HealWave and self:GetTechId() == kTechId.Crag then 
        allowed = allowed and GetHasTech(self, kTechId.CragHive)
    end

    return allowed, canAfford

end

function Crag:PerformActivation(techId, position, normal, commander)

    local success = false
    
    if techId == kTechId.HealWave then
        success = self:TriggerHealWave(commander)
    end
    
    return success, true
    
end

function Crag:OnUpdateAnimationInput(modelMixin)

    PROFILE("Crag:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("heal", self.healingActive or self.healWaveActive)
    modelMixin:SetAnimationInput("moving", self.moving)
    
end

function Crag:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

-- %%% New CBM Functions %%% --
function Crag:GetOffInfestationHurtPercentPerSecond()

    if self:GetTechId() == kTechId.FortressCrag then 
        return kBalanceOffInfestationHurtPercentPerSecondFortress
    end

    return kBalanceOffInfestationHurtPercentPerSecond
end

function Crag:GetDouseTargets()

    local targets = {}

    for _, Douseble in ipairs(GetEntitiesWithMixinForTeamWithinRange("Douse", self:GetTeamNumber(), self:GetOrigin(), Crag.kDouseRadius)) do
        if Douseble:GetIsAlive() then
            table.insert(targets, Douseble)
        end
    end

    return targets

end

function Crag:PerformDouse()

    PROFILE("Crag:PerformDouse")
	--if not self:GetIsOnFire() and ( self.timeOfLastDouse == 0 or (Shared.GetTime() > self.timeOfLastDouse + Crag.kDouseInterval) ) then
	if self.timeOfLastDouse == 0 or (Shared.GetTime() > self.timeOfLastDouse + Crag.kDouseInterval) then
		local targets = self:GetDouseTargets()
		
		for _, target in ipairs(targets) do
			target:SetHasDouse(true, Crag.kCragDouse)
		end
		
		if #targets > 0 then
			self.timeOfLastDouse = Shared.GetTime()
		end		
	end
	
end

Shared.LinkClassToMap("Crag", Crag.kMapName, networkVars)

class 'FortressCrag' (Crag)
FortressCrag.kMapName = "fortresscrag"
Shared.LinkClassToMap("FortressCrag", FortressCrag.kMapName, {})

if Server then 
    
    function Crag:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeToFortressCrag then
        
            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Crag)   -- get a progress bar at the crag in the tech tree. TODO Does this affect spec, comm view?
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
            
        end
    end


    function Crag:OnResearchCancel(researchId)

        if researchId == kTechId.UpgradeToFortressCrag then
        
            local team = self:GetTeam()
            
            if team then
            
                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.Crag)
                if researchNode then
                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
                end
            end  
        end
    end

    -- Called when research or upgrade complete
    function Crag:OnResearchComplete(researchId)

        if researchId == kTechId.UpgradeToFortressCrag then
        
            self:UpgradeToTechId(kTechId.FortressCrag)
            --UpdateHealthValues(newtechid)
            --self:SetTechId(kTechId.FortressCrag)
            
            self:MarkBlipDirty()

            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.Crag)
            
            if researchNode then     
    
                researchNode:SetResearchProgress(1)
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.FortressCrag, self)

            end
			
			local team = self:GetTeam()
			local bioMassLevel = team and team.GetBioMassLevel and team:GetBioMassLevel() or 0
			self:UpdateHealthAmount(bioMassLevel)
        end
    end

end

if Client then
    
	function Crag:GetShowElectrifyEffect()
		return self.electrified
	end
	
    function Crag:OnUpdateRender()

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

            if not self.fortressCragMaterial and self:GetTechId() == kTechId.FortressCrag then
 
                if model and model:GetReadyForOverrideMaterials() then
                
                    model:ClearOverrideMaterials()
                    local material = CragkfortressCragMaterial
                    assert(material)
                    model:SetOverrideMaterial( 0, material )

                    model:SetMaterialParameter("highlight", 0.91)

                    self.fortressCragMaterial = true
                end

           end
    end
end

function Crag:GetShouldRepositionDuringMove()
    return false
end

function Crag:OverrideRepositioningDistance()
    return 0.7
end 

function Crag:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if self:GetTechId() == kTechId.Crag then
        modelCoords.xAxis = modelCoords.xAxis * Crag.kModelScale
        modelCoords.yAxis = modelCoords.yAxis * Crag.kModelScale
        modelCoords.zAxis = modelCoords.zAxis * Crag.kModelScale
    end
    return modelCoords
end

function Crag:GetCanTeleportOverride()
    return not ( self:GetTechId() == kTechId.FortressCrag )
end

function Crag:SetElectrified(time)

    if self.timeElectrifyEnds - Shared.GetTime() < time then

        self.timeElectrifyEnds = Shared.GetTime() + time
        self.electrified = true

    end

end

function Crag:GetElectrified()
    return self.electrified
end