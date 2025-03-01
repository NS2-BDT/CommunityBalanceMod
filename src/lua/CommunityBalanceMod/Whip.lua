-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Whip.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- Alien structure that provides attacks nearby players with area of effect ballistic attack.
-- Also gives attack/hurt capabilities to the commander. Range should be just shorter than
-- marine sentries.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/AlienStructure.lua")

-- Have idle animations
Script.Load("lua/IdleMixin.lua")
-- can be ordered to move along paths and uses reposition when too close to other AI units
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/PathingMixin.lua")
Script.Load("lua/RepositioningMixin.lua")
-- ragdolls on death
Script.Load("lua/RagdollMixin.lua")
-- counts against the supply limit
Script.Load("lua/SupplyUserMixin.lua")
-- is responsible for an alien upgrade tech
Script.Load("lua/UpgradableMixin.lua")

-- can open doors
Script.Load("lua/DoorMixin.lua")
-- have targetSelectors that needs cleanup
Script.Load("lua/TargetCacheMixin.lua")
-- Can do damage
Script.Load("lua/DamageMixin.lua")
-- Handle movement
Script.Load("lua/AlienStructureMoveMixin.lua")
Script.Load("lua/ConsumeMixin.lua")
Script.Load("lua/RailgunTargetMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/BiomassHealthMixin.lua")

class 'Whip' (AlienStructure)

Whip.kMapName = "whip"

Whip.kModelName = PrecacheAsset("models/alien/whip/whip.model")
local kWhipAnimationGraph = PrecacheAsset("models/alien/whip/whip_1.animation_graph") -- new

local kWhipUnrootSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/unroot")
local kWhipRootedSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/root")
local kWhipWalkingSound = PrecacheAsset("sound/NS2.fev/alien/structures/whip/walk")

local kWhipFortressWhipMaterial = PrecacheAsset("models/alien/Whip/whip_adv.material")
local kWhipEnzymedMaterialName = "cinematics/vfx_materials/whip_enzyme.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/whip_enzyme.surface_shader")

local precached = PrecacheAsset("models/alien/whip/ball.surface_shader")

local kWhipFov = 360
local kWhipWhipBallParam = "ball"

local kWhipMoveSpeed = 2.9
local kWhipMaxMoveSpeedParam = 7.25
local kWhipMaxInfestationCharge = 10

local kWhipModelScale = 0.8

local kDefaultAttackSpeed = 1.5 -- cooldown remains the same, but faster animation faster response when frenzy activates

-- slap data - ROF controlled by animation graph, about-ish 1 second per attack
Whip.kRange = 7

-- bombard data - ROF controlled by animation graph, about 4 seconds per attack
local kWhipBombardRange = 20
local kWhipBombSpeed = 20

local networkVars =
    {
        attackYaw = "interpolated integer (0 to 360)",
        
        slapping = "boolean", -- true if we have started a slap attack
        bombarding = "boolean", -- true if we have started a bombard attack
        lastAttackStart = "compensated time", -- Time of the last attack start
        
        rooted = "boolean",
        move_speed = "float", -- used for animation speed
        
        -- used for rooting/unrooting
        unblockTime = "time",
		
		frenzy = "boolean",
        enervating = "boolean",
		
		infestationSpeedCharge = "float",
    }

AddMixinNetworkVars(UpgradableMixin, networkVars)
AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(IdleMixin, networkVars)
AddMixinNetworkVars(DoorMixin, networkVars)
AddMixinNetworkVars(DamageMixin, networkVars)
AddMixinNetworkVars(AlienStructureMoveMixin, networkVars)
AddMixinNetworkVars(ConsumeMixin, networkVars)

if Server then

    Script.Load("lua/Whip_Server.lua")
    
end


function Whip:OnCreate()

    AlienStructure.OnCreate(self, kMatureWhipHealth, kMatureWhipArmor, kWhipMaturationTime, kWhipBiomass)

    InitMixin(self, UpgradableMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, PathingMixin)
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kAIMoveOrderCompleteDistance })
    InitMixin(self, DamageMixin)
    InitMixin(self, AlienStructureMoveMixin, { kAlienStructureMoveSound = kWhipWalkingSound })
    InitMixin(self, ConsumeMixin)
    InitMixin(self, BiomassHealthMixin)
	
    self.attackYaw = 0
    
    self.slapping = false
    self.bombarding = false
    self.lastAttackStart = 0

    self.rooted = true
    self.moving = false
    self.move_speed = 0
    self.unblockTime = 0

    -- to prevent collision with whip bombs
    self:SetPhysicsGroup(PhysicsGroup.WhipGroup)
    self:SetUpdates(true, kRealTimeUpdateRate)
    
    if Server then

        self.targetId = Entity.invalidId
        self.nextAttackTime = 0
		
        self.timeFrenzyEnd = 0
        self.timeEnervateEnd = 0
		
		self.infestationSpeedCharge = 0
		       
    end

    if Client then
        InitMixin(self, RailgunTargetMixin)
    end

	self.timeOfLastFortressWhipAbility = 0
    self.frenzy = false
    self.enervating = false
    self.attackSpeed = kDefaultAttackSpeed

    self.fortressWhipMaterial = false
end

function Whip:OnInitialized()

    AlienStructure.OnInitialized(self, Whip.kModelName, kWhipAnimationGraph)
    
    if Server then
        
        InitMixin(self, RepositioningMixin)
        InitMixin(self, SupplyUserMixin)
        InitMixin(self, TargetCacheMixin)
        
        local targetTypes = { kAlienStaticTargets, kAlienMobileTargets }
        self.slapTargetSelector = TargetSelector():Init(self, Whip.kRange, true, targetTypes)
        self.bombardTargetSelector = TargetSelector():Init(self, kWhipBombardRange, true, targetTypes)
        
		if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end 
		
    end
    
    InitMixin(self, DoorMixin)
    InitMixin(self, IdleMixin)

    self.nextSlapStartTime    = 0
    self.nextBombardStartTime = 0

end


function Whip:OnDestroy()

    AlienStructure.OnDestroy(self)
    
    if Server then
        self.movingSound = nil
    end
    
end 

-- AlienStructureMove
-- no moving while blocked (rooting/unrooting)
function Whip:GetStructureMoveable()
    return self:GetIsUnblocked()
end

function Whip:GetMaxSpeed()
    -- regular Whip
    if self:GetTechId() ~= kTechId.FortressWhip then            
        return  kWhipMoveSpeed * 1.25
    end
    
    -- fortress whip movement
    if self.frenzy then
        return  kWhipMoveSpeed * (0.75 + 1.0 * self.infestationSpeedCharge/kWhipMaxInfestationCharge)
    end
    	
    return kWhipMoveSpeed * (0.75 + 0.5 * self.infestationSpeedCharge/kWhipMaxInfestationCharge)
	--return self:GetGameEffectMask(kGameEffect.OnInfestation) and kWhipMoveSpeed * 0.7 or kWhipMoveSpeed * 0.5

end

-- ---  RepositionMixin
function Whip:GetCanReposition()
    return self:GetIsBuilt()
end

function Whip:OverrideRepositioningSpeed()
    return kWhipMoveSpeed
end

-- --- SleeperMixin
function Whip:GetCanSleep()
    return not self.moving
end

function Whip:GetMinimumAwakeTime()
    return 10
end
-- ---

-- CQ: Is this needed? Used for LOS, but with 360 degree FOV...
function Whip:GetFov()
    return kWhipFov
end

-- --- DamageMixin
function Whip:GetShowHitIndicator()
    return false
end

-- CQ: This should be something that everyone that can damage anything must implement, DamageMixin?
function Whip:GetDeathIconIndex()
    return kDeathMessageIcon.Whip
end

-- --- UnitStatusMixin
function Whip:OverrideHintString(hintString)

    if self:GetHasUpgrade(kTechId.WhipBombard) then
        return "WHIP_BOMBARD_HINT"
    end
    
    return hintString
    
end

-- --- LOSMixin
function Whip:OverrideVisionRadius()
    -- a whip sees as far as a player
    return kPlayerLOSDistance
end

-- --- ModelMixin
function Whip:OnUpdatePoseParameters()

    local yaw = self.attackYaw
    if yaw >= 135 and yaw <= 225 then
        -- we will be using the bombard_back animation which rotates through
        -- 135 to 225 degrees using 225 to 315. Yea, screwed up.
        yaw = 90 + yaw
    end
    
    self:SetPoseParam("attack_yaw", yaw)
    self:SetPoseParam("move_speed", self.move_speed)
    
    if self:GetHasUpgrade(kTechId.WhipBombard) then
        self:SetPoseParam(kWhipWhipBallParam, 1.0)
    else
        self:SetPoseParam(kWhipWhipBallParam, 0)
    end
    
end

function Whip:OnUpdateAnimationInput(modelMixin)

    PROFILE("Whip:OnUpdateAnimationInput")  
    
    local activity = "none"
    local timeFromLastAttack = 0
    local outSyncedBy = Server and 0 or (Shared.GetTime() - self.lastAttackStart)

    -- 0.10s is a good value, you have to set net_lag=700 and net_loss=40 to start seeing
    -- the animation not playing, and even then only once in a while. It's still a permissive.
    -- However, when it plays, it is sync with the hit of the tentacle.
    if outSyncedBy <= 0.10 then
        if self.slapping then
            activity = "primary"
        elseif self.bombarding then
            activity = "secondary"        
        end
    end
    
    if self.enervating then
        activity = "enervate"
    end
        
    -- use the back attack animation (both slap and bombard) for this range of yaw
    local useBack = self.attackYaw > 135 and self.attackYaw < 225

    modelMixin:SetAnimationInput("attack_speed", self.attackSpeed)
    modelMixin:SetAnimationInput("use_back", useBack)    
    modelMixin:SetAnimationInput("activity", activity)
    modelMixin:SetAnimationInput("rooted", self.rooted)
    modelMixin:SetAnimationInput("move", self.moving and "run" or "idle")

end
-- --- end ModelMixin

-- --- LiveMixin
function Whip:GetCanGiveDamageOverride()
    -- whips can hurt you
    return true
end


-- --- DoorMixin
function Whip:OnOverrideDoorInteraction(inEntity)
    -- Do not open doors when rooted.
    if (self:GetIsRooted()) then
        return false, 0
    end
    return true, 4
end

function Whip:OnConsumeTriggered()
    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
        self:CompletedCurrentOrder()
        self:ClearOrders()
    end
end

function Whip:OnOrderGiven(order)
    --This will cancel Consume if it is running.
    if self:GetIsConsuming() then
        self:CancelResearch()
    end
end

-- CQ: EyePos seems to be somewhat hackish; used in several places but not owned anywhere... predates Mixins
function Whip:GetEyePos()
    return self:GetOrigin() + Vector(0, 1.8, 0) -- self:GetCoords().yAxis * 1.8
end

-- CQ: Predates Mixins, somewhat hackish
function Whip:GetCanBeUsed(player, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

-- --- Commander interface

function Whip:GetTechButtons(techId)

    local techButtons = { kTechId.None, kTechId.Move, kTechId.Slap, kTechId.None,
                    kTechId.FortressWhipCragPassive, kTechId.FortressWhipShiftPassive, kTechId.FortressWhipShadePassive, kTechId.Consume }
    
    if self:GetIsMature() then
        techButtons[4] = kTechId.WhipBombard
    end
	
	if self:GetTechId() == kTechId.FortressWhip then
        techButtons[1] = kTechId.FortressWhipAbility
    end	
    
    if self.moving then
        techButtons[2] = kTechId.Stop
    end
    
	if self:GetTechId() == kTechId.Whip and GetHasTech(self, kTechId.FortressWhip) then
        techButtons[5] = kTechId.None
		techButtons[6] = kTechId.None
		techButtons[7] = kTechId.None
    end
        
    if self:GetTechId() == kTechId.Whip and self:GetResearchingId() ~= kTechId.UpgradeToFortressWhip then
        techButtons[1] = kTechId.UpgradeToFortressWhip
    end

      -- remove fortress ability button for normal Whip if there is a fortress Whip somewhere
    --[[if not ( self:GetTechId() == kTechId.Whip and GetHasTech(self, kTechId.FortressWhip) ) then 
        techButtons[1] = kTechId.FortressWhipAbility
    end]]   

    return techButtons
    
end

function Whip:GetTechAllowed(techId, techNode, player)

   
    local allowed, canAfford = AlienStructure.GetTechAllowed(self, techId, techNode, player)
    allowed = allowed and not self:GetIsOnFire()


     -- dont allow upgrading while moving or if something else researches upgrade or another fortress Whip exists.
    if techId == kTechId.UpgradeToFortressWhip then
        allowed = allowed and not self.moving

        allowed = allowed and not GetHasTech(self, kTechId.FortressWhip) and not  GetIsTechResearching(self, techId)
    end

    -- dont allow normal Whip to use the new fortress ability
    if techId == kTechId.FortressWhipAbility then
        allowed = allowed and self:GetTechId() == kTechId.FortressWhip
    end

    
    if techId == kTechId.Stop then
        allowed = allowed and self:GetCurrentOrder() ~= nil
    end
    
    if techId == kTechId.Attack then
        allowed = allowed and self:GetIsBuilt() and self.rooted == true
    end

    return allowed and self:GetIsUnblocked(), canAfford


end

function Whip:GetVisualRadius()

    local slapRange = LookupTechData(self:GetTechId(), kVisualRange, nil)
    if self:GetHasUpgrade(kTechId.WhipBombard) then
        return { slapRange, kWhipBombardRange }
    end
    
    return slapRange
    
end

-- --- end CommanderInterface

-- --- Whip specific
function Whip:GetIsRooted()
    return self.rooted
end

function Whip:GetIsUnblocked()
    return self.unblockTime == 0 or (Shared.GetTime() > self.unblockTime)
end

function Whip:OnUpdate(deltaTime)

    PROFILE("Whip:OnUpdate")
    AlienStructure.OnUpdate(self, deltaTime)
    
    if Server then 
        
        self:UpdateRootState()           
        self:UpdateOrders(deltaTime)
		
		if GetHasTech(self, kTechId.ShadeHive) and self:GetTechId() == kTechId.FortressWhip then
			self.camouflaged = not self:GetIsInCombat()
		end
        
        -- CQ: move_speed is used to animate the whip speed.
        -- As GetMaxSpeed is constant, this just toggles between 0 and fixed value depending on moving
        -- Doing it right should probably involve saving the previous origin and calculate the speed
        -- depending on how fast we move
		
		if self:GetGameEffectMask(kGameEffect.OnInfestation) then
			self.timeOfLastInfestion = Shared.GetTime()
			self.infestationSpeedCharge = math.max(0, math.min(kWhipMaxInfestationCharge, self.infestationSpeedCharge + 2.0*deltaTime))
		else
			self.infestationSpeedCharge = math.max(0, math.min(kWhipMaxInfestationCharge, self.infestationSpeedCharge - deltaTime))
		end
		
        self.move_speed = self.moving and ( self:GetMaxSpeed() / kWhipMaxMoveSpeedParam ) or 0
        self.frenzy = Shared.GetTime() < self.timeFrenzyEnd
        self.enervating = Shared.GetTime() < self.timeEnervateEnd
    end
    --self.attackSpeed = self.frenzy and kWhipFrenzyAttackSpeed or kDefaultAttackSpeed
    
end


-- syncronize the whip_attack_start effect from the animation graph
if Client then

    function Whip:OnTag(tagName)

        PROFILE("ARC:OnTag")
        
        if tagName == "attack_start" then
            self:TriggerEffects("whip_attack_start")        
        end
        
    end

end

Shared.LinkClassToMap("Whip", Whip.kMapName, networkVars, true)

-- %%% New CBM Functions %%% --
function Whip:GetShouldRepositionDuringMove()
    return false
end

function Whip:OverrideRepositioningDistance()
    return 0.6
end 

function Whip:GetHealthPerBioMass()
    if self:GetTechId() == kTechId.FortressWhip then
        return kFortressWhipHealthPerBioMass
    end

    return 0
end

function Whip:GetMatureMaxHealth()

    if self:GetTechId() == kTechId.FortressWhip then
        return kFortressMatureWhipHealth
    end

    return kMatureWhipHealth
end

function Whip:GetMatureMaxArmor()

    if self:GetTechId() == kTechId.FortressWhip then
        return kFortressMatureWhipArmor
    end

    return kMatureWhipArmor
end

function Whip:TriggerFortressWhipAbility(commander)

    self:TriggerEffects("whip_trigger_fury")

    if Server then
        self:StartFrenzy()  -- on Whip_Server.lua
		self:Enervate()
    end
    return true
end

function Whip:TriggerWhipAbility(commander)
    if Server then
        self:Enervate()  -- on Whip_Server.lua
    end
    return true
end

function Whip:PerformActivation(techId, position, normal, commander)

    local success = false
    if techId == kTechId.WhipAbility then
        success = self:TriggerWhipAbility(commander)
    end

    if techId == kTechId.FortressWhipAbility then
        success = self:TriggerFortressWhipAbility(commander)
    end

    return success, true
    
end

function Whip:GetIsCamouflaged()
    return self.camouflaged and self:GetIsBuilt() and GetHasTech(self, kTechId.ShadeHive)
end

if Server then 
    
    function Whip:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeToFortressWhip then
        
            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Whip) 
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
            
        end

    end


    function Whip:OnResearchCancel(researchId)

        if researchId == kTechId.UpgradeToFortressWhip then
        
            local team = self:GetTeam()
            
            if team then
            
                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.Whip)
                if researchNode then
                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
                end
            end  
        end
    end

    -- Called when research or upgrade complete
    function Whip:OnResearchComplete(researchId)

        if researchId == kTechId.UpgradeToFortressWhip then
        
            --self:SetTechId(kTechId.FortressWhip)
            self:UpgradeToTechId(kTechId.FortressWhip)

            self:MarkBlipDirty()
            
            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.Whip)
            
            if researchNode then     
    
                researchNode:SetResearchProgress(1)
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.FortressWhip, self)

            end
            
			local team = self:GetTeam()
			local bioMassLevel = team and team.GetBioMassLevel and team:GetBioMassLevel() or 0
			self:UpdateHealthAmount(bioMassLevel)
        end
    end

end

if Client then
    
    function Whip:OnUpdateRender()
    
           local model = self:GetRenderModel()
           if not self.fortressWhipMaterial and self:GetTechId() == kTechId.FortressWhip then

                if model and model:GetReadyForOverrideMaterials() then
                
                    model:ClearOverrideMaterials()

                    model:SetOverrideMaterial( 0, kWhipFortressWhipMaterial )

                    model:SetMaterialParameter("highlight", 0.91)

                    self.fortressWhipMaterial = true
                end
                
           end
                     
           
           if model then
                local localPlayer = Client.GetLocalPlayer()
                local isVisible = not (HasMixin(self, "Cloakable") and self:GetIsCloaked() and GetAreEnemies(self, localPlayer))
                
                if self.frenzy and isVisible then
                    if not self.enzymedMaterial then
                        self.enzymedMaterial = AddMaterial(model, kWhipEnzymedMaterialName)
                    end
                else
                    if RemoveMaterial(model, self.enzymedMaterial) then
                        self.enzymedMaterial = nil
                    end
                end
                
           end
           
    end
end


function Whip:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if self:GetTechId() == kTechId.Whip then

        modelCoords.xAxis = modelCoords.xAxis * kWhipModelScale 
        modelCoords.yAxis = modelCoords.yAxis * kWhipModelScale 
        modelCoords.zAxis = modelCoords.zAxis * kWhipModelScale 
    end

    return modelCoords
end

function Whip:GetCanTeleportOverride()
    return not ( self:GetTechId() == kTechId.FortressWhip )
end

function Whip:OnDamageDone(doer, target)
    self.timeLastDamageDealt = Shared.GetTime()
end

class 'FortressWhip' (Whip)
FortressWhip.kMapName = "fortressWhip"

Shared.LinkClassToMap("FortressWhip", FortressWhip.kMapName, {})