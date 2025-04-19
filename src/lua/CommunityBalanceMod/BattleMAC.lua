Script.Load("lua/CommunityBalanceMod/MAC.lua")

class 'BattleMAC' (MAC)

BattleMAC.kMapName = "battlemac"

BattleMAC.kHealingFieldEffect = PrecacheAsset("cinematics/healing_field/healing_field.cinematic")

BattleMAC.kHealingWaveDuration = kBattleMACkHealingWaveDuration
BattleMAC.kHealingAmount = kBattleMACHealingWaveAmount
BattleMAC.kAbilityRadius = kBattleMACAbilityRadius

BattleMAC.kNanoShieldDuration = kBattleMACkNanoShieldDuration
BattleMAC.kCatPackDuration = kBattleMACCatPackDuration

BattleMAC.kMoveSpeed = kBattleMACMoveSpeed
BattleMAC.kHoverHeight = 0.5    -- MAC is 0.5

BattleMAC.kRolloutSpeed = 5
BattleMAC.kCapsuleHeight = 0.2
BattleMAC.kCapsuleRadius = 0.5 
BattleMAC.kTurnSpeed = 5 * math.pi -- MAC is 3 * math.pi
BattleMAC.kModelScale = 0.75 -- 1 normally

BattleMAC.kHealth = kBattleMACHealth
BattleMAC.kArmor = kBattleMACArmor

BattleMAC.kModelName = PrecacheAsset("models/marine/mac/mac.model")
BattleMAC.kAnimationGraph = PrecacheAsset("models/marine/mac/mac.animation_graph")

local kBattleMACMaterial = PrecacheAsset("models/marine/mac/mac_adv.material")

local kJetsCinematic = PrecacheAsset("cinematics/marine/mac/jet.cinematic")
local kJetsSound = PrecacheAsset("sound/NS2.fev/marine/structures/mac/thrusters")

local kRightJetNode = "fxnode_jet1"
local kLeftJetNode = "fxnode_jet2"

local networkVars =
{
    nanoshieldActive = "boolean",
    catpackActive = "boolean",
    healingActive = "boolean",
}

AddMixinNetworkVars(NanoShieldMixin, networkVars)

function BattleMAC:OnCreate()
    MAC.OnCreate(self)  

    self.nanoshieldActive = false
    self.catpackActive = false
    self.healingActive = false
	self.BattleMACMaterial = false
 
end

function BattleMAC:OnInitialized()
    
    ScriptActor.OnInitialized(self)

    InitMixin(self, WeldableMixin)
    InitMixin(self, NanoShieldMixin)

    if Server then
    
        self:UpdateIncludeRelevancyMask()
        
        InitMixin(self, SleeperMixin)
        InitMixin(self, MobileTargetMixin)
        InitMixin(self, SupplyUserMixin)
        InitMixin(self, InfestationTrackerMixin)
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        self.jetsSound = Server.CreateEntity(SoundEffect.kMapName)
        self.jetsSound:SetAsset(kJetsSound)
        self.jetsSound:SetParent(self)

        self.leashedPosition = nil
        self.autoReturning = false
        
    elseif Client then
    
        InitMixin(self, UnitStatusMixin)     
        InitMixin(self, HiveVisionMixin) 

        -- Setup movement effects
        self.jetsCinematics = {}
        for index,attachPoint in ipairs({ kLeftJetNode, kRightJetNode }) do
            self.jetsCinematics[index] = Client.CreateCinematic(RenderScene.Zone_Default)
            self.jetsCinematics[index]:SetCinematic(kJetsCinematic)
            self.jetsCinematics[index]:SetRepeatStyle(Cinematic.Repeat_Endless)
            self.jetsCinematics[index]:SetParent(self)
            self.jetsCinematics[index]:SetCoords(Coords.GetIdentity())
            self.jetsCinematics[index]:SetAttachPoint(self:GetAttachPointIndex(attachPoint))
            self.jetsCinematics[index]:SetIsActive(false)
        end

    end
    
    if Client then
        self:CreateAbilityFieldEffect()
    end     
    
    self.timeOfLastGreeting = 0
    self.timeOfLastGreetingCheck = 0
    self.timeOfLastChatterSound = 0
    self.timeOfLastWeld = 0
    self.timeOfLastConstruct = 0
    self.moving = false
    
    self:SetModel(BattleMAC.kModelName, BattleMAC.kAnimationGraph)
    
    InitMixin(self, IdleMixin)
    
	if not Predict then
		self.macVariant = 1
	end

end

function BattleMAC:CreateAbilityFieldEffect()
   
   if Client then
        self:DestroyAbilityFieldEffect()
      
        self.abilityFieldEffect = Client.CreateCinematic(RenderScene.Zone_Default)
        self.abilityFieldEffect:SetCinematic(BattleMAC.kHealingFieldEffect)
        self.abilityFieldEffect:SetRepeatStyle(Cinematic.Repeat_Endless)
        self.abilityFieldEffect:SetParent(self)
        self.abilityFieldEffect:SetCoords(self:GetCoords())
        
    end
end


function BattleMAC:DestroyAbilityFieldEffect()
    if Client and self.abilityFieldEffect then
        Client.DestroyCinematic(self.abilityFieldEffect)
        self.abilityFieldEffect = nil
    end
end


function BattleMAC:GetTurnSpeedOverride()
    return BattleMAC.kTurnSpeed
end

function BattleMAC:GetHoverHeight()
    if self.rolloutSourceFactory then
        -- keep it low until it leaves the factory, then go back to normal hover height
        local h = BattleMAC.kHoverHeight * (1.1 - self.cursor:GetRemainingDistance()) / 1.1
        return math.max(0, h)
    end
    return BattleMAC.kHoverHeight
end

function BattleMAC:OnAdjustModelCoords(modelCoords)

	modelCoords.xAxis = modelCoords.xAxis * BattleMAC.kModelScale
	modelCoords.yAxis = modelCoords.yAxis * BattleMAC.kModelScale
	modelCoords.zAxis = modelCoords.zAxis * BattleMAC.kModelScale

    return modelCoords
    
end

function BattleMAC:GetMoveSpeed()
    
    local maxSpeedTable = { maxSpeed = BattleMAC.kMoveSpeed }
    if self.rolloutSourceFactory then
        maxSpeedTable.maxSpeed = BattleMAC.kRolloutSpeed
    end
    self:ModifyMaxSpeed(maxSpeedTable)
        
    return maxSpeedTable.maxSpeed
end

function BattleMAC:PerformActivation(techId, position, normal, commander)
    
    if techId == kTechId.BattleMACNanoShield  then
        self:ActivateNanoField(position)
        
        -- Apply cooldown to commander if present
        local commander = GetCommanderForTeam(self:GetTeamNumber())
        if commander then
            commander:SetTechCooldown(techId, BattleMAC.kNanoShieldDuration, Shared.GetTime())
            local msg = BuildAbilityResultMessage(techId, true, Shared.GetTime())
            Server.SendNetworkMessage(commander, "AbilityResult", msg, false)
        end
        
        return true, true
        
    elseif techId == kTechId.BattleMACCatPack  then
        self:ActivateCatPack(position)
        
        -- Apply cooldown to commander if present
        local commander = GetCommanderForTeam(self:GetTeamNumber())
        if commander then
            commander:SetTechCooldown(techId, BattleMAC.kCatPackDuration, Shared.GetTime())
            local msg = BuildAbilityResultMessage(techId, true, Shared.GetTime())
            Server.SendNetworkMessage(commander, "AbilityResult", msg, false)
        end
        
        return true, true
        
    elseif techId == kTechId.BattleMACHealingWave then
        self:ActivateHealingWave(position)
        
        -- Apply cooldown to commander if present
        local commander = GetCommanderForTeam(self:GetTeamNumber())
        if commander then
            commander:SetTechCooldown(techId, BattleMAC.kHealingWaveDuration, Shared.GetTime())
            local msg = BuildAbilityResultMessage(techId, true, Shared.GetTime())
            Server.SendNetworkMessage(commander, "AbilityResult", msg, false)
        end
        
        return true, true
    end
    
    return false, false
end

function BattleMAC:GetTechButtons(techId)
    return { kTechId.Move, kTechId.Stop, kTechId.Welding, kTechId.None,
             kTechId.BattleMACHealingWave, kTechId.BattleMACNanoShield, kTechId.BattleMACCatPack, kTechId.Recycle }
end

function BattleMAC:ActivateNanoField(position)
    if not self.nanoshieldActive  then
        self.nanoshieldActive = true
        self:TriggerEffects("battlemac_nanoshield")
        self:AddTimedCallback(self.DeactivateNanoField, BattleMAC.kNanoShieldDuration)
    end
end

function BattleMAC:DeactivateNanoField()
    self.nanoshieldActive = false
end

function BattleMAC:ActivateCatPack(position)
    if not self.catpackActive  then
        self.catpackActive = true
        self:TriggerEffects("battlemac_catpack")
        self:AddTimedCallback(self.DeactivateCatPack, BattleMAC.kCatPackDuration)
    end
end

function BattleMAC:DeactivateCatPack()
    self.catpackActive = false
end

function BattleMAC:ActivateHealingWave(position)
    if not self.healingActive then
        self.healingActive = true
        self:TriggerEffects("battlemac_healing")
        self:AddTimedCallback(self.DeactivateHealingWave, BattleMAC.kHealingWaveDuration)
    end
end

function BattleMAC:DeactivateHealingWave()
    self.healingActive = false
end


function BattleMAC:DrawSinglePulsatingWave(groundPos, color, time, offset)
    local steps = 64  -- Steps for smooth circle
    local angleStep = math.pi * 2 / steps
    local pulseFrequency = 3.0  -- Time in seconds for a complete pulse cycle
    local pulsePhase = ((time + offset) % pulseFrequency) / pulseFrequency
    
    -- Only draw pulse wave during its active phase
    if pulsePhase < 0.8 then  -- Active for 80% of cycle
        local pulseRadius = BattleMAC.kAbilityRadius * pulsePhase
        local pulseAlpha = 0.7 * (1 - pulsePhase / 0.8)  -- Fade out as it expands
        
        for i = 0, steps - 1 do
            local angle = i * angleStep
            local pos = Vector(
                groundPos.x + pulseRadius * math.cos(angle),
                groundPos.y,
                groundPos.z + pulseRadius * math.sin(angle)
            )
            
            local nextAngle = (i + 1) * angleStep
            local nextPos = Vector(
                groundPos.x + pulseRadius * math.cos(nextAngle),
                groundPos.y,
                groundPos.z + pulseRadius * math.sin(nextAngle)
            )
            
            DebugLine(pos, nextPos, 0.15, color.r, color.g, color.b, pulseAlpha, true)
        end
    end
end

function BattleMAC:ShouldShowAbilityFieldEffect()
    local player = Client.GetLocalPlayer()
    if not player then return false end

    if player:isa("Commander") then
        return true
    end

    return self.healingActive or self.catpackActive or self.nanoshieldActive
end

function BattleMAC:OnUpdateRender()
    
    
    
    if Client then

        local shouldShow = self:ShouldShowAbilityFieldEffect()

        if shouldShow and not self.abilityFieldEffect then
            self:CreateAbilityFieldEffect()
        elseif not shouldShow and self.abilityFieldEffect then
            self:DestroyAbilityFieldEffect()
        end
        
        local player = Client.GetLocalPlayer()
        if not player then return end
        
        local playerPos = player:GetOrigin()
        local macPos = self:GetOrigin()
        
		local model = self:GetRenderModel()

		if not self.BattleMACMaterial then

			if model and model:GetReadyForOverrideMaterials() then
			
				model:ClearOverrideMaterials()
				local material = kBattleMACMaterial
				assert(material)
				model:SetOverrideMaterial( 0, material )

				model:SetMaterialParameter("highlight", 0.91)
				
				self.BattleMACMaterial = true
			end
		end
		
        -- Only draw when within 15 meters
        if (playerPos - macPos):GetLength() <= 15 then
            local time = Shared.GetTime()
            
            -- Cast a ray downward to find the ground
            local trace = Shared.TraceRay(macPos, macPos - Vector(0, 5, 0), CollisionRep.Default, PhysicsMask.All, EntityFilterAll())
            local groundPos = trace.endPoint or Vector(macPos.x, macPos.y - 0.4, macPos.z)
            groundPos.y = groundPos.y + 0.05  -- Slightly above ground
            
            -- Determine if any abilities are active and draw their effects
            local hasActiveAbility = false
            
            -- NanoShield effect - Blue
            if self.nanoshieldActive then
                local nanoShieldColor = Color(0, 0.5, 1, 0.7) -- Blue for nanoshield
                self:DrawSinglePulsatingWave(groundPos, nanoShieldColor, time, 0.0) -- No offset for first ability
                hasActiveAbility = true
            end
            
            -- CatPack effect - Red
            if self.catpackActive then
                local catPackColor = Color(1, 0, 0, 0.7) -- Red for catpack
                self:DrawSinglePulsatingWave(groundPos, catPackColor, time, 1.0) -- Offset by 1.0 seconds
                hasActiveAbility = true
            end
            
            -- Healing effect - Green
            if self.healingActive then
                local healingColor = Color(0, 0.8, 0, 0.7) -- Green for healing
                self:DrawSinglePulsatingWave(groundPos, healingColor, time, 2.0) -- Offset by 2.0 seconds
                hasActiveAbility = true
            end
            

        end
    end
end

function BattleMAC:OnUpdate(deltaTime)
    MAC.OnUpdate(self, deltaTime)

    if Server and self:GetIsAlive() then

        -- NanoShield drain
        if self.nanoshieldActive then
			self:ApplyNanoShieldToNearbyEntities()
        end
        
        -- CatPack drain
        if self.catpackActive then
			self:ApplyCatPackToNearbyEntities()
        end
        
        -- Healing wave drain
        if self.healingActive then
			self:ApplyHealingToNearbyEntities()
        end
        
    end
	
	if Client and self.abilityFieldEffect then
        self.abilityFieldEffect:SetCoords(self:GetCoords())
    end
	
end

function BattleMAC:OnDestroy()
   
   if Client then
        if self.abilityFieldEffect then
            Client.DestroyCinematic(self.abilityFieldEffect)
            self.abilityFieldEffect = nil
        end
    end
    
    
    if MAC.OnDestroy then
        MAC.OnDestroy(self)
    end
end


function BattleMAC:ApplyCatPackToNearbyEntities()
    local entities = GetEntitiesWithMixinForTeamWithinRange("CatPack", self:GetTeamNumber(), self:GetOrigin(), BattleMAC.kAbilityRadius)

    for _, entity in ipairs(entities) do
        if not entity:GetHasCatPackBoost() then
            entity:ApplyCatPack(BattleMAC.kCatPackDuration)
			entity:TriggerEffects("catpack_pickup", { effecthostcoords = entity:GetCoords() })
        end
    end
end

function BattleMAC:ApplyNanoShieldToNearbyEntities()
    local entities = GetEntitiesWithMixinForTeamWithinRange("NanoShieldAble", self:GetTeamNumber(), self:GetOrigin(), BattleMAC.kAbilityRadius)
    Shared.PlayPrivateSound(self, MarineCommander.kTriggerNanoShieldSound, nil, 1.0, self:GetOrigin())

    for _, entity in ipairs(entities) do
        if entity:isa("Player") then
            entity:ActivateNanoShield(BattleMAC.kNanoShieldDuration)
        end
    end
end

function BattleMAC:ApplyHealingToNearbyEntities()
    local entities = GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), BattleMAC.kAbilityRadius)
    
    for _, entity in ipairs(entities) do
        if HasMixin(entity, "Live") and entity:GetIsAlive() and entity:GetHealth() < entity:GetMaxHealth() then
            entity:AddHealth(BattleMAC.kHealingAmount * 0.1, false, false, nil, nil) -- Apply healing (scaled for the update interval)
            entity:TriggerEffects("marine_medpack", { effecthostcoords = entity:GetCoords() })
        end
    end
end

Shared.LinkClassToMap("BattleMAC", BattleMAC.kMapName, networkVars)