Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/ModularExos/ExoWeapons/PierceProjectile.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")
--Script.Load("lua/PhaseGateUserMixin.lua")
--Script.Load("lua/ModularExos/ExoWeapons/MarineStructureAbility.lua")

Exo.kModelName = PrecacheAsset("models/marine/exosuit/exosuit_cm.model")
Exo.kAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_cm.animation_graph")

Exo.kClawRailgunModelName = PrecacheAsset("models/marine/exosuit/exosuit_cr.model")
Exo.kClawRailgunAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_cr.animation_graph")

Exo.kDualModelName = PrecacheAsset("models/marine/exosuit/exosuit_mm.model")
Exo.kDualAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_mm.animation_graph")

Exo.kDualRailgunModelName = PrecacheAsset("models/marine/exosuit/exosuit_rr.model")
Exo.kDualRailgunAnimationGraph = PrecacheAsset("models/marine/exosuit/exosuit_rr.animation_graph")

-- This value supercedes Balance.lua...
local kMaxSpeed = 7

--kExoThrusterMinFuel = 0.3
--kExoThrusterFuelUsageRate = 0.5
--kExoThrusterLateralAccel = 1
--kExoThrusterVerticleAccel = 1
--kExoThrusterMaxSpeed = 15
local kHorizontalThrusterAddSpeed = 2 -- 10
local kThrusterHorizontalAcceleration = 200
local kThrusterUpwardsAcceleration = 0

kMinigunFuelUsageScalar = 1
kRailgunFuelUsageScalar = 1

local kExoDeployDuration = 1.4

local networkVars = {
    --powerModuleType    = "enum kExoModuleTypes",
    rightArmModuleType = "enum kExoModuleTypes",
    leftArmModuleType  = "enum kExoModuleTypes",
    utilityModuleType  = "enum kExoModuleTypes",
    abilityModuleType  = "enum kExoModuleTypes",
    repairActive       = "boolean",
    nanoshieldActive       = "boolean",
    catpackActive      = "boolean",
    hasThrusters       = "boolean",
--    hasPhaseModule     = "boolean",
    hasNanoRepair      = "boolean",
    hasNanoShield      = "boolean",
    hasCatPack         = "boolean",
    armorBonus         = "float (0 to 2045 by 1)",
    inventoryWeight    = "float",
}

function Exo:InitExoModel(overrideAnimGraph)
    
    local leftArmType = (kExoModuleTypesData[self.leftArmModuleType] or {}).armType
    local rightArmType = (kExoModuleTypesData[self.rightArmModuleType] or {}).armType
    local modelData = (kExoWeaponRightLeftComboModels[rightArmType] or {})[leftArmType] or {}
    local modelName = modelData.worldModel or "models/marine/exosuit/exosuit_rr.model"
    local graphName = modelData.worldAnimGraph or "models/marine/exosuit/exosuit_rr.animation_graph"
    self:SetModel(modelName, overrideAnimGraph or graphName)
    self.viewModelName = modelData.viewModel or "models/marine/exosuit/exosuit_rr_view.model"
    self.viewModelGraphName = modelData.viewAnimGraph or "models/marine/exosuit/exosuit_rr_view.animation_graph"
end

local kDeploy2DSound = PrecacheAsset("sound/NS2.fev/marine/heavy/deploy_2D")
function Exo:InitWeapons()
    Player.InitWeapons(self)
    
    local weaponHolder = self:GetWeapon(ExoWeaponHolder.kMapName)
    if not weaponHolder then
        weaponHolder = self:GiveItem(ExoWeaponHolder.kMapName, false)
    end
    
    local leftArmModuleTypeData = kExoModuleTypesData[self.leftArmModuleType]
    local rightArmModuleTypeData = kExoModuleTypesData[self.rightArmModuleType]
    weaponHolder:SetWeapons(leftArmModuleTypeData.mapName, rightArmModuleTypeData.mapName)
    
    weaponHolder:TriggerEffects("exo_login")
    self.inventoryWeight = self:CalculateWeight()
    
    self:SetActiveWeapon(ExoWeaponHolder.kMapName)
    StartSoundEffectForPlayer(kDeploy2DSound, self)
end

--AddMixinNetworkVars(PhaseGateUserMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)

local orig_Exo_OnCreate = Exo.OnCreate
function Exo:OnCreate()
    orig_Exo_OnCreate(self)
    self.inventoryWeight = 0
    
    --InitMixin(self, PhaseGateUserMixin)
    InitMixin(self, JumpMoveMixin)
	InitMixin(self, PierceProjectileShooterMixin)
	InitMixin(self, PredictedProjectileShooterMixin)
end

local orig_Exo_OnInitialized = Exo.OnInitialized
function Exo:OnInitialized()
    -- self.powerModuleType = self.powerModuleType or kExoModuleTypes.Power1
    if kExoModuleTypesData[self.leftArmModuleType] == nil then
        if self.layout == "MinigunMinigun" then
            self.leftArmModuleType = kExoModuleTypes.Minigun
        elseif self.layout == "RailgunRailgun" then
            self.leftArmModuleType = kExoModuleTypes.Railgun
        else
            self.leftArmModuleType = kExoModuleTypes.Claw
        end
    else
        self.leftArmModuleType = self.leftArmModuleType
    end
    if kExoModuleTypesData[self.rightArmModuleType] == nil then
        if self.layout == "MinigunMinigun" then
            self.rightArmModuleType = kExoModuleTypes.Minigun
        elseif self.layout == "RailgunRailgun" then
            self.rightArmModuleType = kExoModuleTypes.Railgun
        else
            self.rightArmModuleType = kExoModuleTypes.Minigun
        end
    else
        self.rightArmModuleType = self.rightArmModuleType
    end
    
    if kExoModuleTypesData[self.utilityModuleType] == nil then
        self.utilityModuleType = kExoModuleTypes.None
    else
        self.utilityModuleType = self.utilityModuleType
    end
    if kExoModuleTypesData[self.abilityModuleType] == nil then
        self.abilityModuleType = kExoModuleTypes.None
    else
        self.abilityModuleType = self.abilityModuleType
    end
    
    --local armorModuleData = kExoModuleTypesData[self.utilityModuleType]
    self.armorBonus = self:CalculateArmor()
    --   self.armorBonus = armorModuleData and armorModuleData.armorBonus or 0
    -- self.hasPhaseModule = (self.utilityModuleType == kExoModuleTypes.PhaseModule)
    self.hasThrusters = (self.utilityModuleType == kExoModuleTypes.Thrusters)
    self.hasNanoRepair = (self.utilityModuleType == kExoModuleTypes.NanoRepair)
    self.hasNanoShield = (self.abilityModuleType == kExoModuleTypes.NanoShield)
    self.hasCatPack = (self.abilityModuleType == kExoModuleTypes.CatPack)
    
    orig_Exo_OnInitialized(self)
    
    self.nanoshieldActive = false
    self.repairActive = false
    self.catpackActive = false
    self.timeAutoRepairHealed = 0
    self.lastActivatedRepair = 0
    self.lastActivatedNanoShield = 0
    self.lastActivatedCatPack = 0
    
    if Server then
        -- Prevent people from ejecting to get fuel back instantly
        self:SetFuel(0.2)
    end
end

function Exo:GetHasThrusters()
    return self.hasThrusters and Exo.GetHasThrusters
end

function Exo:GetHasNanoShield()
    return self.hasNanoShield
end

function Exo:GetHasRepair()
    return self.hasNanoRepair
end

function Exo:GetHasCatPack()
    return self.hasCatPack
end

--function Exo:GetCanPhase()
--    return self.hasPhaseModule and PhaseGateUserMixin.GetCanPhase(self)
--end
--
function Exo:GetIsBeaconable(obsEnt, toOrigin)
    return false
--    return self.hasPhaseModule
end

function Exo:GetInventorySpeedScalar(player)
    return 1 - self.inventoryWeight
end

function Exo:GetCanJump()
    return not self:GetIsWebbed() and self:GetIsOnGround()
end

debug.setupvaluex(Exo.GetMaxSpeed, "kMaxSpeed", kMaxSpeed)

local orig_Exo_GetIsThrusterAllowed = Exo.GetIsThrusterAllowed
function Exo:GetIsThrusterAllowed()
    return (not self.nanoshieldActive or not self.repairActive or not self.catpackActive) and (self.hasThrusters and orig_Exo_GetIsThrusterAllowed(self))
end

function Exo:GetSlowOnLand()
    return true
end

function Exo:GetWebSlowdownScalar()
    return 0.6
end

function Exo:GetJumpHeight()
    return Player.kJumpHeight - Player.kJumpHeight * self.slowAmount * 0.5
end

function Exo:GetArmorAmount(armorLevels)
    
    if not armorLevels then
        
        armorLevels = 0
        
        if GetHasTech(self, kTechId.Armor3, true) then
            armorLevels = 3
        elseif GetHasTech(self, kTechId.Armor2, true) then
            armorLevels = 2
        elseif GetHasTech(self, kTechId.Armor1, true) then
            armorLevels = 1
        end
    
    end
    
    return kBaseExoArmor + self.armorBonus + armorLevels * Exo.kExosuitArmorPerUpgradeLevel
end

function Exo:ProcessExoModularBuyAction(message)
    ModularExo_HandleExoModularBuy(self, message)
end

--function Exo:GetCanSelfWeld()
--    return false
--end

if Server then
    --local orig_Exo_PerformEject = Exo.PerformEject
    function Exo:PerformEject()
        if self:GetIsAlive() then
            -- pickupable version
            local exosuit = CreateEntity(Exosuit.kMapName, self:GetOrigin(), self:GetTeamNumber(), {
                -- powerModuleType    = self.powerModuleType   ,
                rightArmModuleType = self.rightArmModuleType,
                leftArmModuleType  = self.leftArmModuleType,
                utilityModuleType  = self.utilityModuleType,
                abilityModuleType  = self.abilityModuleType,
            })
            exosuit:SetCoords(self:GetCoords())
            exosuit:SetMaxArmor(self:GetMaxArmor())
            exosuit:SetArmor(self:GetArmor())
            exosuit:SetExoVariant(self:GetExoVariant())
            exosuit:SetFlashlightOn(self:GetFlashlightOn())
            exosuit:TransferParasite(self)
            
            -- Set the auto-weld cooldown of the dropped exo to match the cooldown if we weren't
            -- ejecting just now.
            local combatTimeEnd = math.max(self:GetTimeLastDamageDealt(), self:GetTimeLastDamageTaken()) + kCombatTimeOut
            local cooldownEnd = math.max(self.timeNextWeld, combatTimeEnd)
            local now = Shared.GetTime()
            local combatTimeRemaining = math.max(0, cooldownEnd - now)
            exosuit.timeNextWeld = now + combatTimeRemaining
            
            local reuseWeapons = self.storedWeaponsIds ~= nil
            
            local marine = self:Replace(self.prevPlayerMapName or Marine.kMapName, self:GetTeamNumber(), false, self:GetOrigin() + Vector(0, 0.2, 0), { preventWeapons = reuseWeapons })
            marine:SetHealth(self.prevPlayerHealth or kMarineHealth)
            marine:SetMaxArmor(self.prevPlayerMaxArmor or kMarineArmor)
            marine:SetArmor(self.prevPlayerArmor or kMarineArmor)
            
			if marine:isa("JetpackMarine") and marine.SetModule then
				marine:SetModule(self.getModule)
			end
			
			
            exosuit:SetOwner(marine)
            
            marine.onGround = false
            local initialVelocity = self:GetViewCoords().zAxis
            initialVelocity:Scale(4)
            initialVelocity.y = math.max(0,initialVelocity.y) + 9
            marine:SetVelocity(initialVelocity)
            
            if reuseWeapons then
                for _, weaponId in ipairs(self.storedWeaponsIds) do
                    local weapon = Shared.GetEntity(weaponId)
                    if weapon then
                        marine:AddWeapon(weapon)
                    end
                end
            end
            marine:SetHUDSlotActive(1)
            if marine:isa("JetpackMarine") then
                marine:SetFuel(0.25)
            end
        end
        return false
    end
end

if Client then
    function Exo:BuyMenu(structure)
        if self:GetTeamNumber() ~= 0 and Client.GetLocalPlayer() == self then
            if not self.buyMenu then
                self.buyMenu = GetGUIManager():CreateGUIScript("GUIMarineBuyMenu")
                MarineUI_SetHostStructure(structure)
                if structure then
                    self.buyMenu:SetHostStructure(structure)
                end
                self:TriggerEffects("marine_buy_menu_open")
            
            end
        end
    end
end

-- New Exo energy system.
function Exo:ConsumingFuel()
    return self.thrustersActive or self.nanoshieldActive or self.repairActive or self.catpackActive
end

function Exo:GetFuel()
    if self:ConsumingFuel() then
        return Clamp(self.fuelAtChange - (Shared.GetTime() - self.timeFuelChanged) / self:GetFuelUsageRate(), 0, 1)
    else
        return Clamp(self.fuelAtChange + (Shared.GetTime() - self.timeFuelChanged) / self:GetFuelRechargeRate(), 0, 1)
    end
end

function Exo:GetFuelRechargeRate()
    return kExoFuelRechargeRate
end

function Exo:GetFuelUsageRate()
    --local usageScalar = self:GetHasMinigun() and kMinigunFuelUsageScalar or kRailgunFuelUsageScalar
    if self.thrustersActive then
        return kExoThrusterFuelUsageRate --* usageScalar
    elseif self.repairActive then
        return kExoRepairFuelUsageRate --* usageScalar
    elseif self.nanoshieldActive then
        return kExoNanoShieldFuelUsageRate --* usageScalarelse
    elseif self.catpackActive then
        return kExoCatPackFuelUsageRate --* usageScalar
    else
        return 1
    end
end

function Exo:GetCatPackAllowed()
    return self.hasCatPack and not (self.thrustersActive or self.repairActive or self.nanoshieldActive)
end

function Exo:GetNanoShieldAllowed()
    return self.hasNanoShield and not (self.thrustersActive or self.repairActive or self.catpackActive)
end

function Exo:GetRepairAllowed()
    return self.hasNanoRepair and not (self.thrustersActive or self.nanoshieldActive or self.catpackActive)
end

function Exo:TriggerNanoShield()
    
    local entities = GetEntitiesWithMixinForTeamWithinRange("NanoShieldAble", self:GetTeamNumber(), self:GetOrigin(), 6)
    Shared.PlayPrivateSound(self, MarineCommander.kTriggerNanoShieldSound, nil, 1.0, self:GetOrigin())
    for _, entity in ipairs(entities) do
        
        if not entity:isa("Exo") then
            entity:ActivateNanoShield()
        end
    end

end

function Exo:StopNanoShield()
    
    local entities = GetEntitiesWithMixinForTeamWithinRange("NanoShieldAble", self:GetTeamNumber(), self:GetOrigin(), 6)
    Shared.PlayPrivateSound(self, MarineCommander.kTriggerNanoShieldSound, nil, 1.0, self:GetOrigin())
    for _, entity in ipairs(entities) do
        
        if entity:GetIsNanoShielded() then
            entity:DeactivateNanoShield()
        end
    end

end

function Exo:TriggerCatPack()
    
    local entities = GetEntitiesWithMixinForTeamWithinRange("CatPack", self:GetTeamNumber(), self:GetOrigin(), 6)
    for _, entity in ipairs(entities) do
        
        if HasMixin(entity, "CatPack") then
            entity:ApplyCatPack()
            entity:TriggerEffects("catpack_pickup", { effecthostcoords = entity:GetCoords() })
        
        end
    end

end

function Exo:UpdateNanoShields(input)

    local buttonPressed = bit.band(input.commands, Move.Reload) ~= 0
    if buttonPressed and self:GetNanoShieldAllowed() then
        -- todo shield
        if self:GetFuel() >= kExoNanoShieldMinFuel and not self.nanoshieldActive and self.lastActivatedNanoShield + 1 < Shared.GetTime() then
            self:SetFuel(self:GetFuel())
            self.nanoshieldActive = true
            self.lastActivatedNanoShield = Shared.GetTime()
            self:TriggerNanoShield()

        end
    end

    if self.nanoshieldActive and (self:GetFuel() == 0 or not buttonPressed) then
        self:SetFuel(self:GetFuel())
        self:StopNanoShield()
        self.nanoshieldActive = false
    end

end

function Exo:UpdateCatPack(input)
    
    local buttonPressed = bit.band(input.commands, Move.Reload) ~= 0
    if buttonPressed and self:GetCatPackAllowed() then
        
        if self:GetFuel() >= kExoCatPackMinFuel and not self.catpackActive and self.lastActivatedCatPack + 1 < Shared.GetTime() then
            self:SetFuel(self:GetFuel())
            self.catpackActive = true
            self.lastActivatedCatPack = Shared.GetTime()
            self:TriggerCatPack()
        
        end
    end
    
    if self.catpackActive and (self:GetFuel() == 0 or not buttonPressed) then
        self:SetFuel(self:GetFuel())
        self.catpackActive = false
        self.catpackboost = false
        self:ClearCatPackMixin()
    end

end

function Exo:UpdateRepairs(input)
    
    local buttonPressed = bit.band(input.commands, Move.MovementModifier) ~= 0
    local repairDesired = self:GetArmor() < self:GetMaxArmor()
    if buttonPressed and self:GetRepairAllowed() and repairDesired then
        
        if self:GetFuel() >= kExoRepairMinFuel and not self.repairActive and self.lastActivatedRepair + 1 < Shared.GetTime() then
            self:SetFuel(self:GetFuel())
            self.lastActivatedRepair = Shared.GetTime()
            self.repairActive = true
        end
    end
    
    if self.repairActive and (self:GetFuel() == 0 or not buttonPressed or not repairDesired) then
        self:SetFuel(self:GetFuel())
        self.repairActive = false
    end
    
    if self.repairActive and self.timeAutoRepairHealed + kExoRepairInterval < Shared.GetTime() then
        self:SetArmor(self:GetArmor() + kExoRepairInterval * kExoRepairPerSecond, false)
        self.timeAutoRepairHealed = Shared.GetTime()
    end

end

function Exo:HandleButtons(input)
    
    if self.ejecting or self.creationTime + kExoDeployDuration > Shared.GetTime() then
        
        input.commands = bit.band(input.commands, bit.bnot(bit.bor(Move.Use, Move.Buy, Move.Jump,
                                                                   Move.PrimaryAttack, Move.SecondaryAttack,
                                                                   Move.SelectNextWeapon, Move.SelectPrevWeapon, Move.Reload,
                                                                   Move.Taunt, Move.Weapon1, Move.Weapon2,
                                                                   Move.Weapon3, Move.Weapon4, Move.Weapon5, Move.Crouch, Move.MovementModifier)))
        
        input.move:Scale(0)
    
    end
    
    Player.HandleButtons(self, input)
    
    self:UpdateThrusters(input)
    self:UpdateRepairs(input)
    self:UpdateNanoShields(input)
    self:UpdateCatPack(input)
    
    if bit.band(input.commands, Move.Drop) ~= 0 then
        self:EjectExo()
    end

end

function Exo:CalculateWeight()
    return ModularExo_GetConfigWeight(ModularExo_ConvertNetMessageToConfig(self))
end

function Exo:CalculateArmor()
    return ModularExo_GetConfigArmor(ModularExo_ConvertNetMessageToConfig(self))
end

local kMinFuelForThrusterActivation = 0.1
--local kThrusterDuration = 0.1
local kMinTimeBetweenThrusterActivations = 0.5

function Exo:UpdateThrusters(input)
    
    local lastThrustersActive = self.thrustersActive
    local jumpPressed = bit.band(input.commands, Move.Jump) ~= 0
    local movementSpecialPressed = bit.band(input.commands, Move.MovementModifier) ~= 0
    local thrusterDesired = (movementSpecialPressed) and self:GetIsThrusterAllowed()
    
    if thrusterDesired ~= lastThrustersActive then
        
        if thrusterDesired then
            
            local desiredMode = jumpPressed and kExoThrusterMode.Vertical
                    or input.move.x < 0 and kExoThrusterMode.StrafeLeft
                    or input.move.x > 0 and kExoThrusterMode.StrafeRight
                    or input.move.z < 0 and kExoThrusterMode.DodgeBack
                    or input.move.z > 0 and kExoThrusterMode.Horizontal
                    or nil
            
            local now = Shared.GetTime()
            if desiredMode and self:GetFuel() >= kMinFuelForThrusterActivation and
                    now >= self.timeThrustersEnded + kMinTimeBetweenThrusterActivations then
                
                self:HandleThrusterStart(desiredMode)
            end
        
        else
            self:HandleThrusterEnd()
        end
    
    end
    
    if self.thrustersActive and self:GetFuel() == 0 then
        self:HandleThrusterEnd()
    end

end

local kUpVector = Vector(0, 1, 0)
function Exo:ModifyVelocity(input, velocity, deltaTime)
    
    if self.thrustersActive then
        
        if self.thrusterMode == kExoThrusterMode.Vertical then
            
            velocity:Add(kUpVector * kThrusterUpwardsAcceleration * deltaTime)
            velocity.y = math.min(1.5, velocity.y)
        
        elseif self:GetIsOnGround() then
            
            input.move.y = 0
            
            local maxSpeed, wishDir
            maxSpeed = self:GetMaxSpeed() + kHorizontalThrusterAddSpeed + self:GetInventorySpeedScalar()
            
            if self.thrusterMode == kExoThrusterMode.StrafeLeft then
                input.move.x = -1
            elseif self.thrusterMode == kExoThrusterMode.StrafeRight then
                input.move.x = 1
            elseif self.thrusterMode == kExoThrusterMode.DodgeBack then
                -- strafe buttons should have less effect when going forwards/backwards, should be more based on your look direction
                input.move.z = -2
            else
                -- strafe buttons should have less effect when going forwards/backwards, should be more based on your look direction
                input.move.z = 2
            end
            
            wishDir = self:GetViewCoords():TransformVector(input.move)
            wishDir.y = 0
            wishDir:Normalize()
            
            wishDir = wishDir * maxSpeed
            
            -- force should help correct velocity towards wishDir, this makes turning more responsive
            local forceDir = wishDir - velocity
            local forceLength = forceDir:GetLengthXZ()
            forceDir:Normalize()
            
            local accelSpeed = kThrusterHorizontalAcceleration * deltaTime
            accelSpeed = math.min(forceLength, accelSpeed)
            velocity:Add(forceDir * accelSpeed)
        
        
        end
    
    end

end

if Client then
    
    function Exo:UpdateGhostModel()
        
        self.currentTechId = nil
        self.ghostStructureCoords = nil
        self.ghostStructureValid = false
        self.showGhostModel = false
        
        --local weapon = self:GetActiveWeapon()
        --
        --if weapon then
        --    if weapon:isa("MarineStructureAbility") then
        --
        --        self.currentTechId = weapon:GetGhostModelTechId()
        --        self.ghostStructureCoords = weapon:GetGhostModelCoords()
        --        self.ghostStructureValid = weapon:GetIsPlacementValid()
        --        self.showGhostModel = weapon:GetShowGhostModel()
        --
        --        return weapon:GetShowGhostModel()
        --
        --
        --    end
        --end
    end
    
    function Exo:GetShowGhostModel()
        return self.showGhostModel
    end
    
    function Exo:GetGhostModelTechId()
        return self.currentTechId
    end
    
    function Exo:GetGhostModelCoords()
        return self.ghostStructureCoords
    end
    
    function Exo:GetIsPlacementValid()
        return self.ghostStructureValid
    end

end

--function Exo:OverrideInput(input)
--
--    -- Always let the MarineStructureAbility override input, since it handles client-side-only build menu
--    local buildAbility = self:GetWeapon(MarineStructureAbility.kMapName)
--
--    if buildAbility then
--        input = buildAbility:OverrideInput(input)
--    end
--
--    return Player.OverrideInput(self, input)
--
--end
--ReplaceLocals(Exo.UpdateThrusters, { kThrusterMinimumFuel = kExoThrusterMinFuel })
--ReplaceLocals(Exo.ModifyVelocity, { kHorizontalThrusterAddSpeed = kExoThrusterMaxSpeed })
--ReplaceLocals(Exo.ModifyVelocity, { kThrusterHorizontalAcceleration = kExoThrusterLateralAccel })
--ReplaceLocals(Exo.ModifyVelocity, { kThrusterUpwardsAcceleration = kExoThrusterVerticleAccel })

Shared.LinkClassToMap("Exo", Exo.kMapName, networkVars, true)
