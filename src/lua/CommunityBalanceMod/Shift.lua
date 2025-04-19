-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Shift.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- Alien structure that allows commander to outmaneuver and redeploy forces. 
--
-- Recall - Ability that lets players jump to nearest structure (or hive) under attack (cooldown 
-- of a few seconds)
-- Energize - Passive ability that gives energy to nearby players
-- Echo - Targeted ability that lets Commander move a structure or drifter elsewhere on the map
-- (even a hive or harvester!). 
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/CommAbilities/Alien/ShiftEcho.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
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
Script.Load("lua/FireMixin.lua")
Script.Load("lua/ObstacleMixin.lua")
Script.Load("lua/CatalystMixin.lua")
Script.Load("lua/TeleportMixin.lua")
Script.Load("lua/UmbraMixin.lua")
Script.Load("lua/CommunityBalanceMod/DouseMixin.lua")
Script.Load("lua/MaturityMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/CommanderGlowMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
Script.Load("lua/SupplyUserMixin.lua")
Script.Load("lua/BiomassMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/IdleMixin.lua")
Script.Load("lua/ConsumeMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/BiomassHealthMixin.lua")

class 'Shift' (ScriptActor)

Shift.kMapName = "shift"

Shift.kModelName = PrecacheAsset("models/alien/shift/shift.model")

local kAnimationGraph = PrecacheAsset("models/alien/shift/shift.animation_graph")

local kEchoTargetSound = PrecacheAsset("sound/NS2.fev/alien/structures/shift/energize")
local kShiftEchoSound2D = PrecacheAsset("sound/NS2.fev/alien/structures/shift/energize_player")

local kEnergizeSoundEffect = PrecacheAsset("sound/NS2.fev/alien/structures/shift/energize")
local kEnergizeTargetSoundEffect = PrecacheAsset("sound/NS2.fev/alien/structures/shift/energize_player")
--local kRecallSoundEffect = PrecacheAsset("sound/NS2.fev/alien/structures/shift/recall")


local kEnergizeEffect = PrecacheAsset("cinematics/alien/shift/energize.cinematic")
local kEnergizeSmallTargetEffect = PrecacheAsset("cinematics/alien/shift/energize_small.cinematic")
local kEnergizeLargeTargetEffect = PrecacheAsset("cinematics/alien/shift/energize_large.cinematic")

Shared.PrecacheSurfaceShader("cinematics/vfx_materials/storm.surface_shader")
local kFortressShiftMaterial = PrecacheAsset("models/alien/Shift/Shift_adv.material")

Shift.kEchoMaxRange = 20

Shift.kMoveSpeed = 2.9
Shift.kMaxInfestationCharge = 10
Shift.kModelScale = 0.8
Shift.kStormCloudInterval = 10
Shift.kEggSpawnInterval = 15

local kNumEggSpotsPerShift = 20
local kEggMinRange = 4
local kEggMaxRange = 10
local kShiftEggMax = 3

local kEchoCooldown = 1

local networkVars =
{
    hydraInRange = "boolean",
    whipInRange = "boolean",
    tunnelInRange = "boolean",
    cragInRange = "boolean",
    shadeInRange = "boolean",
    shiftInRange = "boolean",
    veilInRange = "boolean",
    spurInRange = "boolean",
    shellInRange = "boolean",
    hiveInRange = "boolean",
    eggInRange = "boolean",
    harvesterInRange = "boolean",
    echoActive = "boolean",
	fortressShiftAbilityActive = "boolean",
    
    moving = "boolean",
	infestationSpeedCharge = "float",
	electrified = "boolean"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
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
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(MaturityMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(ConsumeMixin, networkVars)

local function GetIsTeleport(techId)

return techId == kTechId.TeleportHydra or
       techId == kTechId.TeleportWhip or
       techId == kTechId.TeleportTunnel or
       techId == kTechId.TeleportCrag or
       techId == kTechId.TeleportShade or
       techId == kTechId.TeleportShift or
       techId == kTechId.TeleportVeil or
       techId == kTechId.TeleportSpur or
       techId == kTechId.TeleportShell or
       techId == kTechId.TeleportHive or
       techId == kTechId.TeleportEgg or
       techId == kTechId.TeleportHarvester

end

local gTeleportClassnames
local function GetTeleportClassname(techId)

    if not gTeleportClassnames then
    
        gTeleportClassnames = {}
        gTeleportClassnames[kTechId.TeleportHydra] = "Hydra"
        gTeleportClassnames[kTechId.TeleportWhip] = "Whip"
        gTeleportClassnames[kTechId.TeleportTunnel] = "TunnelEntrance"
        gTeleportClassnames[kTechId.TeleportCrag] = "Crag"
        gTeleportClassnames[kTechId.TeleportShade] = "Shade"
        gTeleportClassnames[kTechId.TeleportShift] = "Shift"
        gTeleportClassnames[kTechId.TeleportVeil] = "Veil"
        gTeleportClassnames[kTechId.TeleportSpur] = "Spur"
        gTeleportClassnames[kTechId.TeleportShell] = "Shell"
        gTeleportClassnames[kTechId.TeleportHive] = "Hive"
        gTeleportClassnames[kTechId.TeleportEgg] = "Egg"
        gTeleportClassnames[kTechId.TeleportHarvester] = "Harvester"
    
    end
    
    return gTeleportClassnames[techId]


end

local function ResetShiftButtons(self)

    self.hydraInRange = false
    self.whipInRange = false
    self.tunnelInRange = false
    self.cragInRange = false
    self.shadeInRange = false
    self.shiftInRange = false
    self.veilInRange = false
    self.spurInRange = false
    self.shellInRange = false
    self.hiveInRange = false
    self.eggInRange = false
    self.harvesterInRange = false
    
end

local function UpdateShiftButtons(self)

    ResetShiftButtons(self)

    local teleportAbles = GetEntitiesWithMixinForTeamWithinXZRange("TeleportAble", self:GetTeamNumber(), self:GetOrigin(), kEchoRange)    
    for _, teleportable in ipairs(teleportAbles) do
    
        if teleportable:GetCanTeleport() then
        
            if teleportable:isa("Hydra") then
                self.hydraInRange = true
            elseif teleportable:isa("Whip") and not ( teleportable:GetTechId() == kTechId.FortressWhip ) then
                self.whipInRange = true
            elseif teleportable:isa("TunnelEntrance") then
                self.tunnelInRange = true
            elseif teleportable:isa("Crag") and not ( teleportable:GetTechId() == kTechId.FortressCrag ) then
                self.cragInRange = true
            elseif teleportable:isa("Shade") and not ( teleportable:GetTechId() == kTechId.FortressShade ) then
                self.shadeInRange = true
            elseif teleportable:isa("Shift") and not  ( teleportable:GetTechId() == kTechId.FortressShift ) then
                self.shiftInRange = true
            elseif teleportable:isa("Veil") then
                self.veilInRange = true
            elseif teleportable:isa("Spur") then
                self.spurInRange = true
            elseif teleportable:isa("Shell") then
                self.shellInRange = true
            elseif teleportable:isa("Hive") then
                self.hiveInRange = true
            elseif teleportable:isa("Egg") then
                self.eggInRange = true
            elseif teleportable:isa("Harvester") then
                self.harvesterInRange = true
            end

        end
    end

end

function Shift:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
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
    InitMixin(self, MaturityMixin)
    InitMixin(self, CombatMixin)
    InitMixin(self, DissolveMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, BiomassMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, ConsumeMixin)
	InitMixin(self, BiomassHealthMixin)
    
    ResetShiftButtons(self)
    
    if Server then
    
        InitMixin(self, InfestationTrackerMixin)
        self.remainingFindEggSpotAttempts = 300
        self.eggSpots = {}
        self.timeOfLastStormCloud = 0
		self.timeOfLastEggSpawn = 0
		self.infestationSpeedCharge = 0
		self.electrified = false
		self.timeElectrifyEnds = 0
		self.timeOfLastEgg = Shared.GetTime()
		
    elseif Client then
        InitMixin(self, CommanderGlowMixin)
		InitMixin(self, RailgunTargetMixin)		
    end
    
    self:SetLagCompensated(false)
    self:SetPhysicsType(PhysicsType.Kinematic)
    self:SetPhysicsGroup(PhysicsGroup.MediumStructuresGroup)
    
    self.echoActive = false
    self.timeLastEcho = 0
    
	self.fortressShiftAbilityActive = false
    self.fortressShiftMaterial = false
end

function Shift:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetModel(Shift.kModelName, kAnimationGraph)
    
    if Server then
    
        InitMixin(self, StaticTargetMixin)
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SupplyUserMixin)
    
        self:AddTimedCallback(Shift.EnergizeInRange, 0.5)
        self.shiftEggs = {}
        
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

function Shift:GetBioMassLevel()
    return kShiftBiomass
end

function Shift:EnergizeInRange()

    if self:GetIsBuilt() and not self:GetIsOnFire() and not self.electrified then
    
        local energizeAbles = GetEntitiesWithMixinForTeamWithinXZRange("Energize", self:GetTeamNumber(), self:GetOrigin(), kEnergizeRange)
        
        for _, entity in ipairs(energizeAbles) do
        
            if entity ~= self then
                entity:Energize(self)
            end
            
        end
    
    end
    
    return self:GetIsAlive()
    
end

function Shift:GetDamagedAlertId()
    return kTechId.AlienAlertStructureUnderAttack
end

function Shift:GetReceivesStructuralDamage()
    return true
end

function Shift:GetMaturityRate()
    return kShiftMaturationTime
end

function Shift:GetHealthPerBioMass()
    if self:GetTechId() == kTechId.FortressShift then
        return kFortressShiftHealthPerBioMass
    end

    return 0
end

function Shift:GetMatureMaxHealth()

    if self:GetTechId() == kTechId.FortressShift then
        return kFortressMatureShiftHealth
    end

    return kMatureShiftHealth
end

function Shift:GetMatureMaxArmor()

    if self:GetTechId() == kTechId.FortressShift then
        return kFortressMatureShiftArmor
    end

    return kMatureShiftArmor
end    

function Shift:PreventTurning()
    return true
end

function Shift:OverrideRepositioningSpeed()
    return Shift.kMoveSpeed
end

function Shift:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player) 
    allowed = allowed and not self:GetIsOnFire()


    if techId == kTechId.ShiftEcho then
        allowed = allowed and (GetHasTech(self, kTechId.ShiftHive) or self:GetTechId() == kTechId.FortressShift)
    end
    
     -- dont allow upgrading while moving or if something else researches upgrade or another fortress Shift exists.
        if techId == kTechId.UpgradeToFortressShift then
            allowed = allowed and not self.moving
    
            allowed = allowed and not GetHasTech(self, kTechId.FortressShift) and not  GetIsTechResearching(self, techId)
        elseif techId == kTechId.FortressShiftAbility then
            allowed = allowed and ( self:GetTechId() == kTechId.FortressShift ) and GetHasTech(self, kTechId.ShiftHive)
        else


                allowed = allowed and not self.echoActive
                if allowed then
            
                    if techId == kTechId.TeleportHydra then
                        allowed = self.hydraInRange
                    elseif techId == kTechId.TeleportWhip then
                        allowed = self.whipInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportTunnel then
                        allowed = self.tunnelInRange
                    elseif techId == kTechId.TeleportCrag then
                        allowed = self.cragInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportShade then
                        allowed = self.shadeInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportShift then
                        allowed = self.shiftInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportVeil then
                        allowed = self.veilInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportSpur then 
                        allowed = self.spurInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportShell then
                        allowed = self.shellInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportHive then
                        allowed = self.hiveInRange
                    elseif techId == kTechId.TeleportEgg then
                        allowed = self.eggInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportHarvester then
                        allowed = self.harvesterInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    end
                
                end

        end
    


    return allowed, canAfford
    
end

function Shift:GetCanReposition()
    return true
end

function Shift:GetTechButtons(techId)


    local techButtons
                
    if techId == kTechId.ShiftEcho then

        techButtons = { kTechId.TeleportEgg, kTechId.TeleportWhip, kTechId.TeleportHarvester, kTechId.TeleportShift, 
                        kTechId.TeleportCrag, kTechId.TeleportShade, kTechId.None, kTechId.RootMenu }
                        

        if self.veilInRange then
            techButtons[7] = kTechId.TeleportVeil
        elseif self.shellInRange then
            techButtons[7] = kTechId.TeleportShell
        elseif self.spurInRange then
            techButtons[7] = kTechId.TeleportSpur
        end

    else

        techButtons = { kTechId.ShiftEcho, kTechId.Move, kTechId.ShiftEnergize, kTechId.None, 
                        kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
                        

        if self:GetTechId() == kTechId.Shift and self:GetResearchingId() ~= kTechId.UpgradeToFortressShift then
            techButtons[5] = kTechId.UpgradeToFortressShift
        end

         -- remove fortress ability button for normal Shift if there is a fortress Shift somewhere
        if not ( self:GetTechId() == kTechId.Shift and GetHasTech(self, kTechId.FortressShift) ) and not self.moving then 
			techButtons[4] = kTechId.FortressShiftAbility
        end       

        if self.moving then
            techButtons[2] = kTechId.Stop
        end

    end

    return techButtons
    
end

function Shift:OnUpdateAnimationInput(modelMixin)

    PROFILE("Shift:OnUpdateAnimationInput")
    modelMixin:SetAnimationInput("moving", self.moving)
    modelMixin:SetAnimationInput("echo", self.echoActive)
    
end

function Shift:GetMaxSpeed()
	
    if (self:GetTechId() == kTechId.FortressShift) then
		return  Shift.kMoveSpeed * (0.5 + 0.75 * self.infestationSpeedCharge/Shift.kMaxInfestationCharge)
    end

	if self.electrified then
		return Shift.kMoveSpeed * 0.5
	end

    return  Shift.kMoveSpeed * 1.25
end

function Shift:OnConsumeTriggered()
    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
        self:CompletedCurrentOrder()
        self:ClearOrders()
    end
end

function Shift:OnOrderChanged()
    if self:GetIsConsuming() then
        self:CancelResearch()
    end

    local currentOrder = self:GetCurrentOrder()
    if GetIsUnitActive(self) and currentOrder and currentOrder:GetType() == kTechId.Move then
        self:SetUpdateRate(kRealTimeUpdateRate)
    end
end

function Shift:OnOrderComplete()
    self:SetUpdateRate(kDefaultUpdateRate)
end

function Shift:OnUpdate(deltaTime)

    PROFILE("Shift:OnUpdate")

    ScriptActor.OnUpdate(self, deltaTime)
    UpdateAlienStructureMove(self, deltaTime)        

    if Server then

		self.electrified = self.timeElectrifyEnds > Shared.GetTime()

        if not self.timeLastButtonCheck or self.timeLastButtonCheck + 2 < Shared.GetTime() then
        
            self.timeLastButtonCheck = Shared.GetTime()
            UpdateShiftButtons(self)
            
        end
        
        self.echoActive = self.timeLastEcho + kEchoCooldown > Shared.GetTime()
		
		if GetIsUnitActive(self) then
		
			if self.electrified then
				self.infestationSpeedCharge = 0
			else
				if (self:GetTechId() == kTechId.FortressShift) and GetHasTech(self, kTechId.ShiftHive) and not self.moving then
					self:PerformStormCloud()
					self:PerformEggSpawn()
				end
			
				if self:GetGameEffectMask(kGameEffect.OnInfestation) then
					self.timeOfLastInfestion = Shared.GetTime()
					self.infestationSpeedCharge = math.max(0, math.min(Shift.kMaxInfestationCharge, self.infestationSpeedCharge + 2.0*deltaTime))
				else
					self.infestationSpeedCharge = math.max(0, math.min(Shift.kMaxInfestationCharge, self.infestationSpeedCharge - deltaTime))
				end
			end
		end
	
        if self.stormCloudEndTime then
            local isActive = Shared.GetTime() < self.stormCloudEndTime
            self.fortressShiftAbilityActive = isActive
            self.stormCloudEndTime = isActive and self.stormCloudEndTime or nil
        end
		
    end   
end

if Server then

    function Shift:OnTeleportEnd()
        self:ResetPathing()
    end

    function Shift:OnResearchComplete(researchId)

        -- Transform into mature shift
        if researchId == kTechId.EvolveEcho then
            self:GiveUpgrade(kTechId.ShiftEcho)
        end
        
    end

    function Shift:TriggerEcho(techId, position)
    
        local teleportClassname = GetTeleportClassname(techId)
        local teleportCost = LookupTechData(techId, kTechDataCostKey, 0)
        
        local success = false
        
        local validPos = GetIsBuildLegal(techId, position, 0, kStructureSnapRadius, self:GetOwner(), self)
        
        local builtStructures = {} 
        local matureStructures = {} 
        
        if validPos then
        
            local teleportAbles = GetEntitiesForTeamWithinXZRange(teleportClassname, self:GetTeamNumber(), self:GetOrigin(), kEchoRange)
            
                for index, entity in ipairs(teleportAbles) do
                    if HasMixin(entity, "Construct") and entity:GetIsBuilt() then

                        -- fortress pve cannot teleport due to GetCanTeleportOverride()
                        if entity:GetCanTeleport() then
                            Log("%s added to built Structures", entity)
                            table.insert(builtStructures, entity)
                        end
                        
                        if HasMixin(entity, "Maturity") and entity:GetIsMature() then


                            -- fortress pve cannot teleport due to GetCanTeleportOverride()
                            if entity:GetCanTeleport() then
                                Log("%s added to mature Structures", entity)
                                table.insert(matureStructures, entity)
                            end
                        end
                    end
                end

                if #matureStructures > 0 then
                    teleportAbles = matureStructures
                elseif #builtStructures > 0 then
                    teleportAbles = builtStructures
                end
                
                Shared.SortEntitiesByDistance(self:GetOrigin(), teleportAbles)
                
            for _, teleportAble in ipairs(teleportAbles) do
            
                if teleportAble:GetCanTeleport() then
                
                    teleportAble:TriggerTeleport(5, self:GetId(), position, teleportCost)
                        
                    if HasMixin(teleportAble, "Orders") then
                        teleportAble:ClearCurrentOrder()
                    end
                    
                    self:TriggerEffects("shift_echo")
                    success = true
                    self.echoActive = true
                    self.timeLastEcho = Shared.GetTime()
                    break
                    
                end
            
            end
        
        end
        
        return success
        
    end

    function Shift:GetNumEggs()
        return #self.shiftEggs
    end
    
    function Shift:PerformActivation(techId, position, normal, commander)
    
        local success = false
        local continue = true
        
        if GetIsTeleport(techId) then
        
            success = self:TriggerEcho(techId, position)
            if success then
                UpdateShiftButtons(self)
                Shared.PlayPrivateSound(commander, kShiftEchoSound2D, nil, 1.0, self:GetOrigin())
            end
            
        end
        
        return success, continue
        
    end
    
    function Shift:OnEntityChange(oldId, newId)
        
        if table.icontains(self.shiftEggs, oldId) then
            table.removevalue(self.shiftEggs, oldId)
        end
        
    end

end

function GetShiftIsBuilt(techId, origin, normal, commander)

    -- check if there is a built command station in our team
    if not commander then
        return false
    end    
    
    local attachRange = LookupTechData(kTechId.ShiftHatch, kStructureAttachRange, 1)
    
    local shifts = GetEntitiesForTeamWithinXZRange("Shift", commander:GetTeamNumber(), origin, attachRange)
    for _, shift in ipairs(shifts) do
        
        if shift:GetIsBuilt() then
            return true
        end    
        
    end
    
    return false
    
end

function GetShiftHatchGhostGuides(commander)

    local entities = { }
    local ranges = { }

    local shifts = GetEntitiesForTeam("Shift", commander:GetTeamNumber())
    local attachRange = LookupTechData(kTechId.ShiftHatch, kStructureAttachRange, 1)

    for _, shift in ipairs(shifts) do
        if shift:GetIsBuilt() then
            ranges[shift] = attachRange
            table.insert(entities, shift)
        end
    end

    return entities, ranges

end

function Shift:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

Shared.LinkClassToMap("Shift", Shift.kMapName, networkVars)

-- %%% New CBM Functions %%% --
function Shift:GetOffInfestationHurtPercentPerSecond()

    if self:GetTechId() == kTechId.FortressShift then 
        return kBalanceOffInfestationHurtPercentPerSecondFortress
    end

    return kBalanceOffInfestationHurtPercentPerSecond
end

function Shift:PerformStormCloud()
	if not self:GetIsOnFire() and ( self.timeOfLastStormCloud == 0 or (Shared.GetTime() > self.timeOfLastStormCloud + Shift.kStormCloudInterval) ) then
		CreateEntity(StormCloud.kMapName, self:GetOrigin() + Vector(0, 0.5, 0), self:GetTeamNumber())
		self.fortressShiftAbilityActive = true
		self:StartStormCloud()
		
		self.timeOfLastStormCloud = Shared.GetTime()
	end	
end

function Shift:PerformEggSpawn()
	if not self:GetIsOnFire() and self:GetNumEggs() < kShiftEggMax and ( self.timeOfLastEggSpawn == 0 or (Shared.GetTime() > self.timeOfLastEggSpawn + Shift.kEggSpawnInterval) ) then
		self:GenerateEggSpawns()
		self:HatchEggs()
		self.timeOfLastEggSpawn = Shared.GetTime()
	end	
end

function Shift:StartStormCloud()
    self.stormCloudEndTime = Shared.GetTime() + StormCloud.kLifeSpan
end

function Shift:GetStormTargets()

    local targets = {}

    for _, stormable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), kEnergizeRange)) do
        if stormable:GetIsAlive() then
            table.insert(targets, stormable)
        end
    end

    return targets

end

function Shift:GetShouldRepositionDuringMove()
    return false
end

function Shift:OverrideRepositioningDistance()
    return 0.8
end

function Shift:HatchEggs()
    local amountEggsForHatch = 1
    local eggCount = 0
    for i = 1, amountEggsForHatch do
        local egg = self:SpawnEgg()
        if egg then
			table.insert(self.shiftEggs, egg:GetId())
			eggCount = eggCount + 1
		end
    end

    --if eggCount > 0 then
    --    self:TriggerEffects("hatch")
    --    return true
    --end

    return false
end

function Shift:SpawnEgg()
    if self.eggSpawnPoints == nil or #self.eggSpawnPoints == 0 then

        --Print("Can't spawn egg. No spawn points!")
        return nil

    end

    local lastTakenSpawnPoint = self.lastTakenSpawnPoint or 0
    local maxAvailablePoints = #self.eggSpawnPoints
    for i = 1, maxAvailablePoints do

        local j = i + lastTakenSpawnPoint
        if j > maxAvailablePoints then
            j = j - maxAvailablePoints
        end

        local position = self.eggSpawnPoints[j]

        -- Need to check if this spawn is valid for an Egg and for a Skulk because
        -- the Skulk spawns from the Egg.
        local validForEgg = position and GetCanEggFit(position)

        if validForEgg then

            local egg = CreateEntity(Egg.kMapName, position, self:GetTeamNumber())

            if egg then
                egg:SetHive(self)

                self.lastTakenSpawnPoint = i

                -- Randomize starting angles
                local angles = self:GetAngles()
                angles.yaw = math.random() * math.pi * 2
                egg:SetAngles(angles)

                -- To make sure physics model is updated without waiting a tick
                egg:UpdatePhysicsModel()

                self.timeOfLastEgg = Shared.GetTime()

                return egg

            end

        end

    end

    return nil
end

function Shift:GenerateEggSpawns()

    self.eggSpawnPoints = { }

    local origin = self:GetModelOrigin()

    for _, eggSpawn in ipairs(Server.eggSpawnPoints) do
        if (eggSpawn - origin):GetLength() < kEggMaxRange then
            table.insert(self.eggSpawnPoints, eggSpawn)
        end
    end

    local minNeighbourDistance = 1.5
    local maxEggSpawns = 5
    local maxAttempts = maxEggSpawns * 10

    if #self.eggSpawnPoints >= maxEggSpawns then return end

    local extents = LookupTechData(kTechId.Egg, kTechDataMaxExtents, nil)
    local capsuleHeight, capsuleRadius = GetTraceCapsuleFromExtents(extents)

    -- pre-generate maxEggSpawns, trying at most maxAttempts times
    for index = 1, maxAttempts do
        local spawnPoint = GetRandomSpawnForCapsule(capsuleHeight, capsuleRadius, origin, kEggMinRange, kEggMaxRange, EntityFilterAll())

        if spawnPoint then
            -- Prevent an Egg from spawning on top of a Resource Point.
            local notNearResourcePoint = #GetEntitiesWithinRange("ResourcePoint", spawnPoint, 2) == 0

            if notNearResourcePoint then
                spawnPoint = GetGroundAtPosition(spawnPoint, nil, PhysicsMask.AllButPCs, extents)
            else
                spawnPoint = nil
            end
        end

        if spawnPoint ~= nil then

            local tooCloseToNeighbor = false
            for _, point in ipairs(self.eggSpawnPoints) do

                if (point - spawnPoint):GetLengthSquared() < (minNeighbourDistance * minNeighbourDistance) then

                    tooCloseToNeighbor = true
                    break

                end

            end

            if not tooCloseToNeighbor then

                table.insert(self.eggSpawnPoints, spawnPoint)
                if #self.eggSpawnPoints >= maxEggSpawns then
                    break
                end

            end

        end

    end
	
end

function Shift:GetNumEggsLocation() -- Unused for now... Keeping as reference. 

    local numEggs = 0
    local eggs = GetEntitiesForTeam("Egg", self:GetTeamNumber())
	local origin = self:GetModelOrigin()
    local location = GetLocationForPoint(origin)
    local locationName = location and location:GetName() or ""

    for index, egg in ipairs(eggs) do

        if egg:GetLocationName() == locationName and egg:GetIsAlive() and egg:GetIsFree() and not egg.manuallySpawned then
            numEggs = numEggs + 1
        end

    end

    return numEggs

end

class 'FortressShift' (Shift)
FortressShift.kMapName = "fortressShift"
Shared.LinkClassToMap("FortressShift", FortressShift.kMapName, {})

if Server then 
    
    function Shift:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeToFortressShift then
        
            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Shift)   -- get a progress bar at the Shift in the tech tree. TODO Does this affect spec, comm view?
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
            
        end

    end


    function Shift:OnResearchCancel(researchId)

        if researchId == kTechId.UpgradeToFortressShift then
        
            local team = self:GetTeam()
            
            if team then
            
                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.Shift)
                if researchNode then
                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
                end
            end  
        end
    end

    -- Called when research or upgrade complete
    function Shift:OnResearchComplete(researchId)

        if researchId == kTechId.UpgradeToFortressShift then
        
           -- self:SetTechId(kTechId.FortressShift)
            self:UpgradeToTechId(kTechId.FortressShift)

            self:MarkBlipDirty()
            
            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.Shift)
            
            if researchNode then     
    
                researchNode:SetResearchProgress(1)
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.FortressShift, self)
				
            end
			
			local team = self:GetTeam()
			local bioMassLevel = team and team.GetBioMassLevel and team:GetBioMassLevel() or 0
			self:UpdateHealthAmount(bioMassLevel)
        end
    end

end

if Client then

	function Shift:GetShowElectrifyEffect()
		return self.electrified
	end
    
    function Shift:OnUpdateRender()
    
		local model = self:GetRenderModel()
		local showStorm = not HasMixin(self, "Cloakable") or not self:GetIsCloaked() or not GetAreEnemies(self, Client.GetLocalPlayer())
	   
		if model and self.fortressShiftAbilityActive and showStorm then -- and self.stormCloudEndTime then
			if not self.stormedMaterial then
				self.stormedMaterial = AddMaterial(model, Alien.kStormedThirdpersonMaterialName)

				self.stormedMaterial:SetParameter("startTime", Shared.GetTime())
				self.stormedMaterial:SetParameter("offset", 2)
				self.stormedMaterial:SetParameter("intensity", 3)
			end
		else
			if model and RemoveMaterial(model, self.stormedMaterial) then
				self.stormedMaterial = nil
			end
		end
	   
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

		if not self.fortressShiftMaterial and self:GetTechId() == kTechId.FortressShift then

			--local model = self:GetRenderModel()

			if model and model:GetReadyForOverrideMaterials() then
			
				model:ClearOverrideMaterials()
				
				model:SetOverrideMaterial( 0, kFortressShiftMaterial )

				model:SetMaterialParameter("highlight", 0.91)

				self.fortressShiftMaterial = true
			end
		end
    end
end

function Shift:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if self:GetTechId() == kTechId.Shift then
        modelCoords.xAxis = modelCoords.xAxis * Shift.kModelScale
        modelCoords.yAxis = modelCoords.yAxis * Shift.kModelScale
        modelCoords.zAxis = modelCoords.zAxis * Shift.kModelScale
    end

    return modelCoords
end

function Shift:GetCanTeleportOverride()
    return not ( self:GetTechId() == kTechId.FortressShift )
end

function Shift:SetElectrified(time)

    if self.timeElectrifyEnds - Shared.GetTime() < time then

        self.timeElectrifyEnds = Shared.GetTime() + time
        self.electrified = true

    end

end

function Shift:GetElectrified()
    return self.electrified
end

