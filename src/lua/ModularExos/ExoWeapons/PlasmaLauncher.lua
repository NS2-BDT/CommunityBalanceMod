Script.Load("lua/Weapons/BulletsMixin.lua")
Script.Load("lua/Weapons/Marine/ExoWeaponSlotMixin.lua")
Script.Load("lua/TechMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/PointGiverMixin.lua")
Script.Load("lua/AchievementGiverMixin.lua")
Script.Load("lua/EffectsMixin.lua")
Script.Load("lua/Weapons/ClientWeaponEffectsMixin.lua")

Script.Load("lua/ModularExos/ExoWeapons/PlasmaBallT1.lua")
Script.Load("lua/ModularExos/ExoWeapons/PlasmaBallT2.lua")
Script.Load("lua/ModularExos/ExoWeapons/PlasmaBallT3.lua")

Script.Load("lua/ModularExos/ExoWeapons/PierceProjectile.lua")

class 'PlasmaLauncher'(Entity)

PlasmaLauncher.kMapName = "PlasmaLauncher"

local kPlasmaRange = 400
local kPlasmaSpread = Math.Radians(3)

-- Time required to go from 0% to 100% charged...
local kChargeTime = 2.25

-- The PlasmaLauncher will automatically shoot if it is charged for too long...
local kChargeForceShootTime = 3.75

-- Cooldown between plasmalauncher shots...
local kPlasmaLauncherChargeTime = 1

local kChargeSound = PrecacheAsset("sound/NS2.fev/marine/heavy/railgun_charge")

local networkVars =
{
    timeChargeStarted = "time",
    plasmalauncherAttacking = "boolean",
    lockCharging = "boolean",
    timeOfLastShot = "time"
}

AddMixinNetworkVars(TechMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)
AddMixinNetworkVars(ExoWeaponSlotMixin, networkVars)

function PlasmaLauncher:OnCreate()

    Entity.OnCreate(self)
    
    InitMixin(self, TechMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, BulletsMixin)
    InitMixin(self, ExoWeaponSlotMixin)
    InitMixin(self, PointGiverMixin)
    InitMixin(self, AchievementGiverMixin)
    InitMixin(self, EffectsMixin)
		
    self.timeChargeStarted = 0
    self.plasmalauncherAttacking = false
    self.lockCharging = false
    self.timeOfLastShot = 0
    
    if Client then
    
        InitMixin(self, ClientWeaponEffectsMixin)
        self.chargeSound = Client.CreateSoundEffect(Shared.GetSoundIndex(kChargeSound))
        self.chargeSound:SetParent(self:GetId())
        
    end

end

function PlasmaLauncher:OnDestroy()

    Entity.OnDestroy(self)
    
    if self.chargeSound then
    
        Client.DestroySoundEffect(self.chargeSound)
        self.chargeSound = nil
        
    end
    
    if self.chargeDisplayUI then
    
        Client.DestroyGUIView(self.chargeDisplayUI)
        self.chargeDisplayUI = nil
        
    end
    
end

function PlasmaLauncher:GetIsThrusterAllowed()
    return true
end

function PlasmaLauncher:GetWeight()
    return kPlasmaWeight
end

function PlasmaLauncher:GetChargeAmount()
    return self.plasmalauncherAttacking and math.min(1, (Shared.GetTime() - self.timeChargeStarted) / kChargeTime) or 0
end

function PlasmaLauncher:ProcessMoveOnWeapon(player, input)

    if self.plasmalauncherAttacking then
    
        if (Shared.GetTime() - self.timeChargeStarted) >= kChargeForceShootTime then
            self.plasmalauncherAttacking = false
        end
        
    end
end

-- Allows railguns to fire simulataneously...
function PlasmaLauncher:OnPrimaryAttack(player)
    
    local exoWeaponHolder = player:GetActiveWeapon()
    local otherSlotWeapon = self:GetExoWeaponSlot() == ExoWeaponHolder.kSlotNames.Left and exoWeaponHolder:GetRightSlotWeapon() or exoWeaponHolder:GetLeftSlotWeapon() 
	if self.timeOfLastShot + kPlasmaLauncherChargeTime <= Shared.GetTime() then
    
        if not self.plasmalauncherAttacking then
            self.timeChargeStarted = Shared.GetTime()
        end
        self.plasmalauncherAttacking = true
		
    end
end

function PlasmaLauncher:OnPrimaryAttackEnd(player)
    self.plasmalauncherAttacking = false
end

local function TriggerSteamEffect(self, player)

    if self:GetIsLeftSlot() then
        player:TriggerEffects("railgun_steam_left")
    elseif self:GetIsRightSlot() then
        player:TriggerEffects("railgun_steam_right")
    end
    
end

function PlasmaLauncher:GetDeathIconIndex()
    return kDeathMessageIcon.Railgun
end

local function PlasmaBallProjectile(self, player)

	if not Predict then
		
		local viewAngles = player:GetViewAngles()
		local shootCoords = viewAngles:GetCoords()

		local eyePos = player:GetEyePos()
		local viewCoords = player:GetViewCoords()

		local startPoint

		if self:GetIsLeftSlot() then
			startPoint = eyePos + viewCoords.zAxis * 1.75 + viewCoords.xAxis * 0.65 + viewCoords.yAxis * -0.19
		else
			startPoint = eyePos + viewCoords.zAxis * 1.75 + viewCoords.xAxis * -0.65 + viewCoords.yAxis * -0.19
		end

		local spreadDirection = CalculateSpread(shootCoords, kPlasmaSpread, NetworkRandom)

		local endPoint = eyePos + spreadDirection * kPlasmaRange		
		local trace = Shared.TraceRay(eyePos, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))
		local direction = (trace.endPoint - startPoint):GetUnit()
				
		local ChargePercent = math.min(1, (Shared.GetTime() - self.timeChargeStarted) / kChargeTime)
		local shotAmount = math.floor(ChargePercent/0.2)

		local exoWeaponHolder = player:GetActiveWeapon()
		local LeftWeapon = exoWeaponHolder:GetLeftSlotWeapon()
		local RightWeapon = exoWeaponHolder:GetRightSlotWeapon()
		
		if ChargePercent < 0.95 then		
			player:CreatePierceProjectile("PlasmaT2", startPoint, direction * kPlasmaSpeedMax, 0, 0, 0, nil, kPlasmaMinDirectDamage, 0, kPlasmaHitBoxRadiusMedian, kPlasmaDamageRadius/2.0, ChargePercent, player)
			
			local shotDelay
			for i = 1, shotAmount do
				shotDelay = i*0.2
				self:ShotSequence(player,shotDelay)
			end
		else
			player:CreatePierceProjectile("PlasmaT3", startPoint, direction * kPlasmaSpeedMin, 0, 0, 9.81, nil, kPlasmaMaxDirectDamage, kPlasmaDOTDamageMax, kPlasmaHitBoxRadiusMax, kPlasmaDamageRadius, ChargePercent, player)
		end	
    end
end

function PlasmaLauncher:PlasmaBallProjectileMini()

	local player = self:GetParent()
	if not Predict then
		
		local viewAngles = player:GetViewAngles()
		local shootCoords = viewAngles:GetCoords()

		local eyePos = player:GetEyePos()
		local viewCoords = player:GetViewCoords()

		local startPoint

		if self:GetIsLeftSlot() then
			startPoint = eyePos + viewCoords.zAxis * 1.75 + viewCoords.xAxis * 0.65 + viewCoords.yAxis * -0.19
		else
			startPoint = eyePos + viewCoords.zAxis * 1.75 + viewCoords.xAxis * -0.65 + viewCoords.yAxis * -0.19
		end

		local spreadDirection = CalculateSpread(shootCoords, kPlasmaSpread, NetworkRandom)

		local endPoint = eyePos + spreadDirection * kPlasmaRange		
		local trace = Shared.TraceRay(eyePos, endPoint, CollisionRep.Damage, PhysicsMask.Bullets, EntityFilterAllButIsa("Tunnel"))
		local direction = (trace.endPoint - startPoint):GetUnit()
				
		player:CreatePierceProjectile("PlasmaT2", startPoint, direction * kPlasmaSpeedMax, 0, 0, 0, nil, 15, 0, kPlasmaHitBoxRadiusMedian, kPlasmaDamageRadius/2.0, ChargePercent, player)
	end
end

function PlasmaLauncher:LockGun()
    self.timeOfLastShot = Shared.GetTime()
end

function PlasmaLauncher:ShotSequence(player,shotDelay)
    self:AddTimedCallback(self.PlasmaBallProjectileMini, shotDelay)
end

local function Shoot(self, leftSide)

    local player = self:GetParent()
	
    -- We can get a shoot tag even when the clip is empty if the frame rate is low
    -- and the animation loops before we have time to change the state.
    if player then
    	
        player:TriggerEffects("railgun_attack")

		if Server or (Client and Client.GetIsControllingPlayer()) then
            PlasmaBallProjectile(self, player)
        end
		
        if Client then
            TriggerSteamEffect(self, player)
        end
        		
        self:LockGun()
        self.lockCharging = true
        
    end
    
end

function PlasmaLauncher:OnUpdateRender()

    PROFILE("PlasmaLauncher:OnUpdateRender")
    
	local parent = self:GetParent()
	local chargeAmount
	
	local exoWeaponHolder = parent:GetActiveWeapon()
	local LeftWeapon = exoWeaponHolder:GetLeftSlotWeapon()
	local RightWeapon = exoWeaponHolder:GetRightSlotWeapon()
	local otherSlotWeapon = self:GetExoWeaponSlot() == ExoWeaponHolder.kSlotNames.Left and exoWeaponHolder:GetRightSlotWeapon() or exoWeaponHolder:GetLeftSlotWeapon()

	chargeAmount = self:GetChargeAmount()
	UIchargeAmount = self:GetChargeAmount()
	
    if parent and parent:GetIsLocalPlayer() then
    
        local viewModel = parent:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
        
            viewModel:InstanceMaterials()
            local renderModel = viewModel:GetRenderModel()
            renderModel:SetMaterialParameter("chargeAmount" .. self:GetExoWeaponSlotName(), chargeAmount)
            renderModel:SetMaterialParameter("timeSinceLastShot" .. self:GetExoWeaponSlotName(), Shared.GetTime() - self.timeOfLastShot)
            
        end
        
        local chargeDisplayUI = self.chargeDisplayUI
        if not chargeDisplayUI then
        
            chargeDisplayUI = Client.CreateGUIView(246, 256)
            chargeDisplayUI:Load("lua/ModularExos/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "PlasmaDisplay.lua")
            chargeDisplayUI:SetTargetTexture("*exo_railgun_" .. self:GetExoWeaponSlotName())
            self.chargeDisplayUI = chargeDisplayUI
			
			Log("%s","lua/ModularExos/GUI" .. self:GetExoWeaponSlotName():gsub("^%l", string.upper) .. "PlasmaDisplay.lua")
            
        end
        
        chargeDisplayUI:SetGlobal("chargeAmount" .. self:GetExoWeaponSlotName(), UIchargeAmount)
        chargeDisplayUI:SetGlobal("timeSinceLastShot" .. self:GetExoWeaponSlotName(), Shared.GetTime() - self.timeOfLastShot)
        		
    else
    
        if self.chargeDisplayUI then
        
            Client.DestroyGUIView(self.chargeDisplayUI)
            self.chargeDisplayUI = nil
            
        end
        
    end
    	
    if self.chargeSound then
    
        local playing = self.chargeSound:GetIsPlaying()
        if not playing and UIchargeAmount > 0 then
            self.chargeSound:Start()
        elseif playing and UIchargeAmount <= 0 then
            self.chargeSound:Stop()
        end
        
        self.chargeSound:SetParameter("charge", UIchargeAmount, 1)
        
    end
    
end

function PlasmaLauncher:OnTag(tagName)

    PROFILE("PlasmaLauncher:OnTag")
    	
    if self:GetIsLeftSlot() then
    	
        if tagName == "l_shoot" then
            Shoot(self, true)

        elseif tagName == "l_shoot_end" then
            self.lockCharging = false
        end
        
    elseif not self:GetIsLeftSlot() then
    
        if tagName == "r_shoot" then
            Shoot(self, false)
        elseif tagName == "r_shoot_end" then
            self.lockCharging = false
        end
        
    end
    
end

function PlasmaLauncher:OnUpdateAnimationInput(modelMixin)

    local activity = "none"
    if self.plasmalauncherAttacking then
        activity = "primary"
    end
    
	modelMixin:SetAnimationInput("activity_" .. self:GetExoWeaponSlotName(), activity)

end

function PlasmaLauncher:UpdateViewModelPoseParameters(viewModel)

    local chargeParam = "charge_" .. (self:GetIsLeftSlot() and "l" or "r")
    local chargeAmount = self:GetChargeAmount()
    viewModel:SetPoseParam(chargeParam, chargeAmount)
    
end

if Client then

    -- NOTE(Salads): The railgun exo has different attach point names for both viewmodel and the regular model. FIXME
    local kFirstPersonAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "fxnode_l_railgun_muzzle", [ExoWeaponHolder.kSlotNames.Right] = "fxnode_r_railgun_muzzle" }
    local kThirdPersonAttachPoints = { [ExoWeaponHolder.kSlotNames.Left] = "fxnode_lrailgunmuzzle", [ExoWeaponHolder.kSlotNames.Right] = "fxnode_rrailgunmuzzle" }
    local kMuzzleEffectName = PrecacheAsset("cinematics/marine/railgun/muzzle_flash.cinematic")

    function PlasmaLauncher:OnClientPrimaryAttackEnd()
    
        local parent = self:GetParent()
        
        if parent then

            local attachPoint
            if parent:GetIsLocalPlayer() and not parent:GetIsThirdPerson() then
                attachPoint = kFirstPersonAttachPoints[self:GetExoWeaponSlot()]
            else
                attachPoint = kThirdPersonAttachPoints[self:GetExoWeaponSlot()]
            end

            CreateMuzzleCinematic(self, kMuzzleEffectName, kMuzzleEffectName, attachPoint, parent, nil, true)
        end
        
    end
    
    function PlasmaLauncher:GetSecondaryAttacking()
        return false
    end
    
    function PlasmaLauncher:GetIsActive()
        return true
    end    
    
    function PlasmaLauncher:GetPrimaryAttacking()
        return self.plasmalauncherAttacking
    end

end

if Server then

    function PlasmaLauncher:OnParentKilled(attacker, doer, point, direction)
    end
    
    -- 
    -- The Railgun explodes players. We must bypass the ragdoll here.
    -- 
    function PlasmaLauncher:OnDamageDone(doer, target)
    
        if doer == self then
        
            if HasMixin(target, "Ragdoll") and target:isa("Player") and not target:GetIsAlive() then
                target:SetBypassRagdoll(true)
            end
            
        end
        
    end
    
end

Shared.LinkClassToMap("PlasmaLauncher", PlasmaLauncher.kMapName, networkVars)