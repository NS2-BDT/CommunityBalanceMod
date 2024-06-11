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

local kChargeSound = PrecacheAsset("sound/NS2.fev/marine/heavy/railgun_charge")

local networkVars =
{
    timeChargeStarted = "time",
    plasmalauncherAttacking = "boolean",
    timeOfLastShot = "time",
	energyWAmount = "float (0 to 1 by 0.01)",
	energyAnimation = "float (0 to 1 by 0.01)",
	fireMode = "string (11)",
	ReloadLastFrame = "boolean",
	energyCost = "float (0 to 1 by 0.01)"
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
    self.timeOfLastShot = 0
	self.energyWAmount = 0
	self.energyAnimation = 0
	self.fireMode = "MultiShot"
	ReloadLastFrame = false
	self.energyCost = kPlasmaMultiEnergyCost
    
    if Client then
    
        InitMixin(self, ClientWeaponEffectsMixin)
        self.chargeSound = Client.CreateSoundEffect(Shared.GetSoundIndex(kChargeSound))
        self.chargeSound:SetParent(self:GetId())
		self:GUIInitialize()
        
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
	
	if self.fireModeGUI then
		self.fireModeGUI:SetText("")
	end
	
	if self.fireModeGUIBg then
		self.fireModeGUIBg:SetText("")
	end
		
end

function PlasmaLauncher:GetIsThrusterAllowed()
    return true
end

function PlasmaLauncher:GetWeight()
    return kPlasmaWeight
end

function PlasmaLauncher:GetChargeAmount()
    return self.energyWAmount
end

function PlasmaLauncher:GetMode()
	return self.fireMode
end

function PlasmaLauncher:AddEnergyW(amount)
    self.energyWAmount = self.energyWAmount + amount
end

function PlasmaLauncher:ProcessMoveOnWeapon(player, input)

	local dt = input.time
    local addAmount = dt * kPlasmaLauncherEnergyUpRate
    self.energyWAmount = math.min(1, math.max(0, self.energyWAmount + addAmount))
	
	local reloadPressed = bit.band(input.commands, Move.Reload) ~= 0
	if not self.ReloadLastFrame and reloadPressed then
		if self.fireMode == "MultiShot" then
			self.fireMode = "Bomb"
			self.energyCost = kPlasmaBombEnergyCost
		elseif self.fireMode == "Bomb" then
			self.fireMode = "MultiShot"
			self.energyCost = kPlasmaMultiEnergyCost
		end
	end
	self.ReloadLastFrame = reloadPressed
	
	if bit.band(input.commands, Move.Weapon1) ~= 0 then
		self.fireMode = "MultiShot"
		self.energyCost = kPlasmaMultiEnergyCost
	elseif bit.band(input.commands, Move.Weapon2) ~= 0 then
		self.fireMode = "Bomb"
		self.energyCost = kPlasmaBombEnergyCost
	end
	
	
end

function PlasmaLauncher:OnPrimaryAttack(player)
	self.plasmalauncherAttacking = true
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
				
		local exoWeaponHolder = player:GetActiveWeapon()
		local LeftWeapon = exoWeaponHolder:GetLeftSlotWeapon()
		local RightWeapon = exoWeaponHolder:GetRightSlotWeapon()
		
		if self.fireMode == "MultiShot" then		
			player:CreatePierceProjectile("PlasmaT2", startPoint, direction * kPlasmaMultiSpeed, 0, 0, 0, nil, kPlasmaMultiDamage, 0, kPlasmaHitBoxRadiusT2, kPlasmaMultiDamageRadius, nil, player)
			
			local shotDelay
			for i = 1, 2 do
				shotDelay = i*0.1
				self:ShotSequence(player,shotDelay)
			end
		elseif self.fireMode == "Bomb" then		
			player:CreatePierceProjectile("PlasmaT3", startPoint, direction * kPlasmaBombSpeed, 0, 0, 9.81, nil, kPlasmaBombDamage, kPlasmaBombDOTDamage, kPlasmaHitBoxRadiusT3, kPlasmaBombDamageRadius, nil, player)
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
				
		player:CreatePierceProjectile("PlasmaT2", startPoint, direction * kPlasmaMultiSpeed, 0, 0, 0, nil, kPlasmaMultiDamage, 0, kPlasmaHitBoxRadiusT2, kPlasmaMultiDamageRadius, nil, player)
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
    	
		
        --player:TriggerEffects("railgun_attack")
			
		if Server or (Client and Client.GetIsControllingPlayer()) then
			PlasmaBallProjectile(self, player)
		end
		
		--if Client then
		--	TriggerSteamEffect(self, player)
		--end
				
		--self:LockGun()
		--self.lockCharging = true
        
    end
    
end

function PlasmaLauncher:OnUpdateRender()

    PROFILE("PlasmaLauncher:OnUpdateRender")
    
	if self.fireMode == "MultiShot" then
		self.fireModeGUI:SetText("Mode #1: Multi-Shot")
		self.fireModeGUI:SetColor(Color(0.25, 1, 1, 1))
	elseif self.fireMode == "Bomb" then
		self.fireModeGUI:SetText(("Mode #2: Plasma-Bomb"))
		self.fireModeGUI:SetColor(Color(1, 0.25, 1, 1))
	end	
	
	self.fireModeGUI:SetPosition(GUIScale(Vector(0, -156, 0)))
	self.fireModeGUIBg:SetPosition(GUIScale(Vector(0, -156, 0)))
	self.fireModeGUI:SetScale(GUIScale(Vector(0.4, 0.4, 0)))
	self.fireModeGUIBg:SetScale(GUIScale(Vector(0.4, 0.4, 0)))
	
	local parent = self:GetParent()
	local chargeAmount, Mode, minEnergy
	
	local exoWeaponHolder = parent:GetActiveWeapon()
	local LeftWeapon = exoWeaponHolder:GetLeftSlotWeapon()
	local RightWeapon = exoWeaponHolder:GetRightSlotWeapon()
	local otherSlotWeapon = self:GetExoWeaponSlot() == ExoWeaponHolder.kSlotNames.Left and exoWeaponHolder:GetRightSlotWeapon() or exoWeaponHolder:GetLeftSlotWeapon()

	chargeAmount = self.energyWAmount --self:GetChargeAmount()
	UIchargeAmount = self.energyWAmount --self:GetChargeAmount()
	Mode = self.fireMode
	minEnergy = self.energyCost
	
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
			
        end
        
        chargeDisplayUI:SetGlobal("chargeAmount" .. self:GetExoWeaponSlotName(), UIchargeAmount)
        chargeDisplayUI:SetGlobal("Mode" .. self:GetExoWeaponSlotName(), Mode)
		chargeDisplayUI:SetGlobal("minEnergy" .. self:GetExoWeaponSlotName(), minEnergy)
        		
    else
    
        if self.chargeDisplayUI then
        
            Client.DestroyGUIView(self.chargeDisplayUI)
            self.chargeDisplayUI = nil
            
        end
        
    end
    	
    --[[if self.chargeSound then
    
        local playing = self.chargeSound:GetIsPlaying()
        if not playing and UIchargeAmount > 0 then
            self.chargeSound:Start()
        elseif playing and UIchargeAmount <= 0 then
            self.chargeSound:Stop()
        end
        
        self.chargeSound:SetParameter("charge", UIchargeAmount, 1)
        
    end]]
    
end

function PlasmaLauncher:OnTag(tagName)

    PROFILE("PlasmaLauncher:OnTag")
	
    if self:GetIsLeftSlot() then
    	self.energyAnimation = self.energyWAmount	
        if tagName == "l_shoot" and self.energyWAmount > self.energyCost then
            Shoot(self, true)
			if Server then	
				self.energyWAmount = math.max(0,self.energyWAmount - self.energyCost)
			end
        end
        
    elseif not self:GetIsLeftSlot() then
		self.energyAnimation = self.energyWAmount
        if tagName == "r_shoot" and self.energyWAmount > self.energyCost then
			Shoot(self, false)
			if Server then
				self.energyWAmount = math.max(0,self.energyWAmount - self.energyCost)
			end
        end
    end
end

function PlasmaLauncher:OnResolutionChanged()
    self:UpdateItemsGUIScale()
end

function PlasmaLauncher:GUIInitialize()	
	self.fireModeGUI, self.fireModeGUIBg = self:CreateItem(0,-156)
	
	if self.fireMode == "MultiShot" then
		self.fireModeGUI:SetText("Mode #1: Multi-Shot")
		self.fireModeGUI:SetColor(Color(0.25, 1, 1, 1))
	elseif self.fireMode == "Bomb" then
		self.fireModeGUI:SetText(("Mode #2: Plasma-Bomb"))
		self.fireModeGUI:SetColor(Color(1, 0.25, 1, 1))
	end	

	self.fireModeGUI:SetScale(GUIScale(Vector(0.5, 0.5, 0)))
	self.fireModeGUIBg:SetScale(GUIScale(Vector(0.5, 0.5, 0)))
end

function PlasmaLauncher:CreateItem(x, y)

    local textBg = GUIManager:CreateTextItem()
    textBg:SetFontName(Fonts.kMicrogrammaDMedExt_Medium)
	textBg:SetAnchor(GUIItem.Middle, GUIItem.Bottom)   
    textBg:SetTextAlignmentX(GUIItem.Align_Center)
    textBg:SetTextAlignmentY(GUIItem.Align_Center)
    textBg:SetPosition(GUIScale(Vector(x, y, 0)))
	textBg:SetColor(Color(1, 1, 1, 1))

    -- Text displaying the amount of reserve ammo
    local text = GUIManager:CreateTextItem()
    text:SetFontName(Fonts.kMicrogrammaDMedExt_Medium)
	text:SetAnchor(GUIItem.Middle, GUIItem.Bottom)  
    text:SetTextAlignmentX(GUIItem.Align_Center)
    text:SetTextAlignmentY(GUIItem.Align_Center)
    text:SetPosition(GUIScale(Vector(x, y, 0)))
    
    return text, textBg
end

function PlasmaLauncher:OnUpdateAnimationInput(modelMixin)

    local activity = "none"
    
	if self.plasmalauncherAttacking and self.energyWAmount > self.energyCost then
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
    local kMuzzleEffectName = PrecacheAsset("models/plasma/muzzle_flash_plasma.cinematic")

    function PlasmaLauncher:OnClientPrimaryAttacking()
    
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