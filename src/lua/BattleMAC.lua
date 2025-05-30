Script.Load("lua/MAC.lua")
Script.Load("lua/EnergyMixin.lua")


class 'BattleMAC' (MAC)

BattleMAC.kMapName = "battlemac"

BattleMAC.kHealingFieldEffect = PrecacheAsset("cinematics/healing_field/healing_field.cinematic")

BattleMAC.kHealingWaveDuration = kBattleMACkHealingWaveDuration
BattleMAC.kHealingAmount = kBattleMACHealingWaveAmount
BattleMAC.kAbilityRadius = kBattleMACAbilityRadius

BattleMAC.kNanoShieldDuration = kBattleMACkNanoShieldDuration
BattleMAC.kCatPackDuration = kBattleMACkCatPackDuration
BattleMAC.kSpeedBoostDuration  = kBattleMACkSpeedBoostDuration

BattleMAC.kMoveSpeed = kBattleMACMoveSpeed
BattleMAC.kHoverHeight = 0.4    -- MAC is 0.5

BattleMAC.kRolloutSpeed = 5
BattleMAC.kCapsuleHeight = 0.2
BattleMAC.kCapsuleRadius = 0.5 
BattleMAC.kTurnSpeed = 5 * math.pi -- MAC is 3 * math.pi
BattleMAC.kModelScale = 0.9 -- 1 normally

 -- Energy cost to activate
BattleMAC.kNanoShieldActivationCost = 70 
BattleMAC.kCatPackActivationCost = 30
BattleMAC.kHealingWaveActivationCost = 20
BattleMAC.kSpeedBoostActivationCost = 20

BattleMAC.kSpeedBoostMultiplier = 1.5

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
	speedBoostActive = "boolean",
}

AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(EnergyMixin, networkVars)

function BattleMAC:OnCreate()
    MAC.OnCreate(self)  
    InitMixin(self, EnergyMixin)
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
    
    if self.speedBoostActive then
        maxSpeedTable.maxSpeed = maxSpeedTable.maxSpeed * BattleMAC.kSpeedBoostMultiplier
    end
    
    self:ModifyMaxSpeed(maxSpeedTable)
        
    return maxSpeedTable.maxSpeed
end

function BattleMAC:PerformActivation(techId, position, normal, commander)
    
    if techId == kTechId.BattleMACNanoShield and self:HasEnoughEnergy(BattleMAC.kNanoShieldActivationCost)  then
        self:ActivateNanoField(position)
        
        -- Apply cooldown to commander if present
        local commander = GetCommanderForTeam(self:GetTeamNumber())
        if commander then
            commander:SetTechCooldown(techId, BattleMAC.kNanoShieldDuration, Shared.GetTime())
            local msg = BuildAbilityResultMessage(techId, true, Shared.GetTime())
            Server.SendNetworkMessage(commander, "AbilityResult", msg, false)
        end
        
        return true, true
        
    elseif techId == kTechId.BattleMACCatPack and self:HasEnoughEnergy(BattleMAC.kCatPackActivationCost)  then
        self:ActivateCatPack(position)
        
        -- Apply cooldown to commander if present
        local commander = GetCommanderForTeam(self:GetTeamNumber())
        if commander then
            commander:SetTechCooldown(techId, BattleMAC.kCatPackDuration, Shared.GetTime())
            local msg = BuildAbilityResultMessage(techId, true, Shared.GetTime())
            Server.SendNetworkMessage(commander, "AbilityResult", msg, false)
        end
        
        return true, true
        
    elseif techId == kTechId.BattleMACHealingWave and self:HasEnoughEnergy(BattleMAC.kHealingWaveActivationCost) then
        self:ActivateHealingWave(position)
        
        -- Apply cooldown to commander if present
        local commander = GetCommanderForTeam(self:GetTeamNumber())
        if commander then
            commander:SetTechCooldown(techId, BattleMAC.kHealingWaveDuration, Shared.GetTime())
            local msg = BuildAbilityResultMessage(techId, true, Shared.GetTime())
            Server.SendNetworkMessage(commander, "AbilityResult", msg, false)
        end
        
      elseif techId == kTechId.BattleMACSpeedBoost and self:HasEnoughEnergy(BattleMAC.kSpeedBoostActivationCost) then
        self:ActivateSpeedBoost(position)
        
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

function BattleMAC:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    
    if techId == kTechId.BattleMACNanoShield and self:HasEnoughEnergy(BattleMAC.kNanoShieldActivationCost)  then
		return allowed, canAfford
    elseif techId == kTechId.BattleMACCatPack and self:HasEnoughEnergy(BattleMAC.kCatPackActivationCost)  then
        return allowed, canAfford
    elseif techId == kTechId.BattleMACHealingWave and self:HasEnoughEnergy(BattleMAC.kHealingWaveActivationCost) then
		return allowed, canAfford
    elseif techId == kTechId.BattleMACSpeedBoost and self:HasEnoughEnergy(BattleMAC.kSpeedBoostActivationCost) then
        return allowed, canAfford
	else
		allowed = false
		return allowed, canAfford
    end

end

function BattleMAC:GetTechButtons(techId)
    return { kTechId.Move, kTechId.Stop, kTechId.Welding, kTechId.BattleMACSpeedBoost,
             kTechId.BattleMACHealingWave, kTechId.BattleMACNanoShield, kTechId.BattleMACCatPack, kTechId.Recycle }
end

function BattleMAC:ActivateNanoField(position)
    if not self.nanoshieldActive  then
        self.nanoshieldActive = true
        self:SetEnergy(self:GetEnergy() - BattleMAC.kNanoShieldActivationCost)
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
        self:SetEnergy(self:GetEnergy() - BattleMAC.kCatPackActivationCost)
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
        self:SetEnergy(self:GetEnergy() - BattleMAC.kHealingWaveActivationCost) 
        self:TriggerEffects("battlemac_healing")
        self:AddTimedCallback(self.DeactivateHealingWave, BattleMAC.kHealingWaveDuration)
    end
end

function BattleMAC:DeactivateHealingWave()
    self.healingActive = false
end

function BattleMAC:ActivateSpeedBoost(position)
    if not self.speedBoostActive then
        self.speedBoostActive = true
        self:SetEnergy(self:GetEnergy() - BattleMAC.kSpeedBoostActivationCost) 
        self:TriggerEffects("catpack_pickup")
        self:AddTimedCallback(self.DeactivateSpeedBoost, BattleMAC.kSpeedBoostDuration)
    end
end

function BattleMAC:DeactivateSpeedBoost()
	self.speedBoostActive = false
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

    if HasMixin(player, "Team") and player:GetTeamType() ~= kMarineTeamType then
        return false
    end

    if player:isa("Commander") then
        return true
    end

    return self.healingActive or self.catpackActive or self.nanoshieldActive
end

-- function BattleMAC:RechargeEnergy(deltaTime)
    -- if self.energy < BattleMAC.kEnergyMax then
        -- self:SetEnergy(self.energy + (BattleMAC.kEnergyRechargeRate * deltaTime))
    -- end
-- end

-- function BattleMAC:GetEnergy()
    -- return self.energy
-- end

-- function BattleMAC:SetEnergy(value)
    -- self.energy = math.max(0, math.min(BattleMAC.kEnergyMax, value))
-- end

function BattleMAC:HasEnoughEnergy(requiredEnergy)
    return self:GetEnergy() >= requiredEnergy
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
				self:SetHighlightNeedsUpdate()
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
            if HasMixin(player, "Team") and player:GetTeamType() == kMarineTeamType then
			
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
        if HasMixin(entity, "Live") and entity:GetIsAlive() and entity:GetHealth() < entity:GetMaxHealth() and entity:isa("Player") then
            entity:AddHealth(BattleMAC.kHealingAmount * 0.1, false, false, nil, nil) -- Apply healing (scaled for the update interval)
            entity:TriggerEffects("marine_medpack", { effecthostcoords = entity:GetCoords() })
        end
    end
end

local function UpdateOrders(self, deltaTime)

    local currentOrder = self:GetCurrentOrder()
    if currentOrder ~= nil then
    
        local orderStatus = kOrderStatus.None        
        local orderTarget = Shared.GetEntity(currentOrder:GetParam())
        local orderLocation = currentOrder:GetLocation()
    
        if currentOrder:GetType() == kTechId.FollowAndWeld then
            orderStatus = self:ProcessFollowAndWeldOrder(deltaTime, orderTarget, orderLocation)    
        elseif currentOrder:GetType() == kTechId.Move then
            local closeEnough = 2.5
            orderStatus = self:ProcessMove(deltaTime, orderTarget, orderLocation, closeEnough)
            self:UpdateGreetings()

        elseif currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.AutoWeld then
            orderStatus = self:ProcessWeldOrder(deltaTime, orderTarget, orderLocation, currentOrder:GetType() == kTechId.AutoWeld)
        elseif currentOrder:GetType() == kTechId.Build or currentOrder:GetType() == kTechId.Construct then
            orderStatus = self:ProcessConstruct(deltaTime, orderTarget, orderLocation)
        end
        
        if orderStatus == kOrderStatus.Cancelled then
            self:ClearCurrentOrder()
        elseif orderStatus == kOrderStatus.Completed then
            self:CompletedCurrentOrder()
        end
        
    end
    
end

local function GetIsWeldedByOtherMAC(self, target)

    if target then
    
        for _, mac in ipairs(GetEntitiesForTeam("MAC", self:GetTeamNumber())) do
        
            if self ~= mac then
            
                if mac.secondaryTargetId ~= nil and Shared.GetEntity(mac.secondaryTargetId) == target then
                    return true
                end
                
                local currentOrder = mac:GetCurrentOrder()
                local orderTarget
                if currentOrder and currentOrder:GetParam() ~= nil then
                    orderTarget = Shared.GetEntity(currentOrder:GetParam())
                end
                
                if currentOrder and orderTarget == target and (currentOrder:GetType() == kTechId.FollowAndWeld or currentOrder:GetType() == kTechId.Weld or currentOrder:GetType() == kTechId.AutoWeld) then
                    return true
                end
                
            end
            
        end
        
    end
    
    return false
    
end

local function GetAutomaticOrder(self)

    local target
    local orderType
	local abilityUsed = self.nanoshieldActive or self.catpackActive or self.healingActive

    if (self.timeOfLastFindSomethingTime == nil or Shared.GetTime() > self.timeOfLastFindSomethingTime + 1) and not abilityUsed then

        local currentOrder = self:GetCurrentOrder()
        local primaryTarget
        if currentOrder and currentOrder:GetType() == kTechId.FollowAndWeld then
            primaryTarget = Shared.GetEntity(currentOrder:GetParam())
        end

        if primaryTarget and (HasMixin(primaryTarget, "Weldable") and primaryTarget:GetWeldPercentage() < 1) and not primaryTarget:isa("MAC") then
            
            target = primaryTarget
            orderType = kTechId.AutoWeld
                    
        else

            -- If there's a friendly entity nearby that needs constructing, constuct it.
            local constructables = GetEntitiesWithMixinForTeamWithinRange("Construct", self:GetTeamNumber(), self:GetOrigin(), MAC.kOrderScanRadius)
            for c = 1, #constructables do
            
                local constructable = constructables[c]
                if constructable:GetCanConstruct(self) then
                
                    target = constructable
                    orderType = kTechId.Construct
                    break
                    
                end
                
            end
            
            if not target then
            
                -- Look for entities to heal with weld.
                local weldables = GetEntitiesWithMixinForTeamWithinRange("Weldable", self:GetTeamNumber(), self:GetOrigin(), MAC.kOrderScanRadius)
                for w = 1, #weldables do
                
                    local weldable = weldables[w]
                    -- There are cases where the weldable's weld percentage is very close to
                    -- 100% but not exactly 100%. This second check prevents the MAC from being so pedantic.
                    if weldable:GetCanBeWelded(self) and weldable:GetWeldPercentage() < 1 and not GetIsWeldedByOtherMAC(self, weldable) and not weldable:isa("MAC") then
                    
                        target = weldable
                        orderType = kTechId.AutoWeld
                        break

                    end
                    
                end
            
            end
        
        end

        self.timeOfLastFindSomethingTime = Shared.GetTime()

    end
    
    return target, orderType

end

local function FindSomethingToDo(self)
    
    local target, orderType = GetAutomaticOrder(self)
	
    if target and orderType then
        if self.leashedPosition then
            local tooFarFromLeash = Vector(self.leashedPosition - target:GetOrigin()):GetLength() > 15
            if tooFarFromLeash then
                --DebugPrint("Strayed too far!")
                return false
            end
        else
            self.leashedPosition = GetHoverAt(self, self:GetOrigin())
            --DebugPrint("return position set "..ToString(self.leashedPosition))
        end
        self.autoReturning = false
        self.selfGivenAutomaticOrder = true
        return self:GiveOrder(orderType, target:GetId(), target:GetOrigin(), nil, true, true) ~= kTechId.None  
    elseif self.leashedPosition and not self.autoReturning then
        self.autoReturning = true
        self.selfGivenAutomaticOrder = true
        self:GiveOrder(kTechId.Move, nil, self.leashedPosition, nil, true, true)
        --DebugPrint("returning to "..ToString(self.leashedPosition))
    end
    
    return false
    
end

local function GetBackPosition(self, target)

    if not target:isa("Player") then
        return None
    end
    
    local coords = target:GetViewAngles():GetCoords()
    local targetViewAxis = coords.zAxis
    targetViewAxis.y = 0 -- keep it 2D
    targetViewAxis:Normalize()
    local fromTarget = self:GetOrigin() - target:GetOrigin()
    local targetDist = fromTarget:GetLengthXZ()
    fromTarget.y = 0
    fromTarget:Normalize()

    local weldPos = None    
    local dot = targetViewAxis:DotProduct(fromTarget)    
    -- if we are in front or not sufficiently away from the target, we calculate a new weldPos
    if dot > 0.866 or targetDist < MAC.kWeldDistance - 0.5 then
        -- we are in front, find out back positon
        local obstacleSize = 0
        if HasMixin(target, "Extents") then
            obstacleSize = target:GetExtents():GetLengthXZ()
        end
        -- we do not want to go straight through the player, instead we move behind and to the
        -- left or right
        local targetPos = target:GetOrigin()
        local toMidPos = targetViewAxis * (obstacleSize + MAC.kWeldDistance - 0.1)
        local midWeldPos = targetPos - targetViewAxis * (obstacleSize + MAC.kWeldDistance - 0.4)
        local leftV = Vector(-targetViewAxis.z, targetViewAxis.y, targetViewAxis.x)
        local rightV = Vector(targetViewAxis.z, targetViewAxis.y, -targetViewAxis.x)
        local leftWeldPos = midWeldPos + leftV * 2
        local rightWeldPos = midWeldPos + rightV * 2
        --[[
        DebugBox(leftWeldPos+Vector(0,1,0),leftWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 0, 0, 1)
        DebugBox(rightWeldPos+Vector(0,1,0),rightWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 1, 0, 1)
        DebugBox(midWeldPos+Vector(0,1,0),midWeldPos+Vector(0,1,0),Vector(0.1,0.1,0.1), 5, 1, 1, 1, 1)       
        --]]
        -- take the shortest route
        local origin = self:GetOrigin()
        if (origin - leftWeldPos):GetLengthSquared() < (origin - rightWeldPos):GetLengthSquared() then
            weldPos = leftWeldPos
        else
            weldPos = rightWeldPos
        end
    end
    
    return weldPos
        
end

local function CheckBehindBackPosition(self, orderTarget)
                    
    if not self.timeOfLastBackPositionCheck or Shared.GetTime() > self.timeOfLastBackPositionCheck + MAC.kWeldPositionCheckInterval then
 
        self.timeOfLastBackPositionCheck = Shared.GetTime()
        self.backPosition = GetBackPosition(self, orderTarget)

    end

    return self.backPosition    
end

function BattleMAC:OnUpdate(deltaTime)
    ScriptActor.OnUpdate(self, deltaTime)
    
    -- if Server and self:GetIsAlive() then
        -- if not self.lastEnergyPrintTime or Shared.GetTime() > self.lastEnergyPrintTime + 1 then
            -- Print("BattleMAC Energy: " .. tostring(math.floor(self.energy)) .. " / " .. tostring(BattleMAC.kEnergyMax))
            -- self.lastEnergyPrintTime = Shared.GetTime()
        -- end
    -- end
    
    if Server and self:GetIsAlive() then

        -- assume we're not moving initially
        self.moving = false
    
        if not self:GetHasOrder() then
            FindSomethingToDo(self)
        else
            UpdateOrders(self, deltaTime)
        end
        
        self.constructing = Shared.GetTime() - self.timeOfLastConstruct < 0.5
        self.welding = Shared.GetTime() - self.timeOfLastWeld < 0.5

        if self.moving and not self.jetsSound:GetIsPlaying() then
            self.jetsSound:Start()
        elseif not self.moving and self.jetsSound:GetIsPlaying() then
            self.jetsSound:Stop()
        end
        
    -- client side build / weld effects
    elseif Client and self:GetIsAlive() then
    
        if self.constructing then
        
            if not self.timeLastConstructEffect or self.timeLastConstructEffect + MAC.kConstructRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_construct")
                self.timeLastConstructEffect = Shared.GetTime()
                
            end
            
        end
        
        if self.welding then
        
            if not self.timeLastWeldEffect or self.timeLastWeldEffect + MAC.kWeldRate < Shared.GetTime()  then
            
                self:TriggerEffects("mac_weld")
                self.timeLastWeldEffect = Shared.GetTime()
                
            end
            
        end
        
        if self:GetHasOrder() ~= self.clientHasOrder then
        
            self.clientHasOrder = self:GetHasOrder()
            
            if self.clientHasOrder then
                self:TriggerEffects("mac_set_order")
            end
            
        end

        if self.jetsCinematics then

            for id,cinematic in ipairs(self.jetsCinematics) do
                self.jetsCinematics[id]:SetIsActive(self.moving and self:GetIsVisible())
            end

        end

    end

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

function BattleMAC:GetCanUpdateEnergy()
    return true --not self.nanoshieldActive and not self.catpackActive and not self.healingActive and not self.speedBoostActive
end

function MAC:ProcessFollowAndWeldOrder(deltaTime, orderTarget, targetPosition)

    local currentOrder = self:GetCurrentOrder()
    local orderStatus = kOrderStatus.InProgress
    
    if orderTarget and orderTarget:GetIsAlive() then
        
        local target, orderType = GetAutomaticOrder(self)
        
        if target and orderType then
        
            self.secondaryOrderType = orderType
            self.secondaryTargetId = target:GetId()
            
        end
        
        target = target ~= nil and target or ( self.secondaryTargetId ~= nil and Shared.GetEntity(self.secondaryTargetId) )
        orderType = orderType ~= nil and orderType or self.secondaryOrderType
        
        local forceMove = false
        if not orderType then
            -- if we don't have a secondary order, we make sure we move to the back of the player
            local backPosition = CheckBehindBackPosition(self, orderTarget)
            if backPosition then
                forceMove = true
                targetPosition = backPosition
            end
        end

        local distance = (self:GetOrigin() - targetPosition):GetLengthXZ()
        
        -- stop moving to primary if we find something to do and we are not too far from our primary
        if orderType and self.moveToPrimary and distance < 10 then
            self.moveToPrimary = false
        end
        
        local triggerMoveDistance = (self.welding or self.constructing or orderType) and 15 or 6
        
        if distance > triggerMoveDistance or self.moveToPrimary or forceMove then
            
            local closeEnough = forceMove and 0.1 or 2.5
            if self:ProcessMove(deltaTime, target, targetPosition, closeEnough) == kOrderStatus.InProgress then
                self.moveToPrimary = true
                self.secondaryTargetId = nil
                self.secondaryOrderType = nil
            else
                self.moveToPrimary = false
            end
            
        else
            self.moving = false
        end
        
        -- when we attempt to follow the primary target, dont interrupt with auto orders
        if not self.moveToPrimary then
        
            if target and orderType then
            
                local secondaryOrderStatus

                if orderType == kTechId.AutoWeld then            
                    secondaryOrderStatus = self:ProcessWeldOrder(deltaTime, target, target:GetOrigin(), true)        
                elseif orderType == kTechId.Construct then
                    secondaryOrderStatus = self:ProcessConstruct(deltaTime, target, target:GetOrigin())
                end
                
                if secondaryOrderStatus == kOrderStatus.Completed or secondaryOrderStatus == kOrderStatus.Cancelled then
                
                    self.secondaryTargetId = nil
                    self.secondaryOrderType = nil
                    
                end
            
            end
        
        end
        
    else
        self.moveToPrimary = false
        orderStatus = kOrderStatus.Cancelled
    end
    
    return orderStatus

end

function BattleMAC:OverrideGetEnergyUpdateRate()
	return kBattleMACEnergyRate
end

Shared.LinkClassToMap("BattleMAC", BattleMAC.kMapName, networkVars)