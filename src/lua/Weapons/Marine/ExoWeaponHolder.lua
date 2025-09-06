-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =====
--
-- lua\Weapons\Marine\ExoWeaponHolder.lua
--
--    Created by:   Brian Cronin (brianc@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Weapon.lua")

class 'ExoWeaponHolder' (Weapon)

ExoWeaponHolder.kMapName = "exo_weapon_holder"

ExoWeaponHolder.kSlotNames = enum({ 'Left', 'Right' })

local networkVars =
{
    leftWeaponId = "entityid",
    rightWeaponId = "entityid",
	weaponMapNameLeft = "string (15)",
	weaponMapNameRight = "string (15)",
	dualrailfiring = "boolean",
	dualminifiring = "boolean",
	dualBTfiring = "boolean",
	dualPLfiring = "boolean",
}

local kViewModelNames = 
{
    ["minigun+minigun"] = PrecacheAsset("models/marine/exosuit/exosuit_mm_view.model"),
    ["railgun+railgun"] = PrecacheAsset("models/marine/exosuit/exosuit_rr_view.model") 
}
local kAnimationGraphs = 
{
    ["minigun+minigun"] = PrecacheAsset("models/marine/exosuit/exosuit_mm_view.animation_graph"),
    ["railgun+railgun"] = PrecacheAsset("models/marine/exosuit/exosuit_rr_view.animation_graph") 
}

local kDeploy2DSoundEffect = PrecacheAsset("sound/NS2.fev/marine/heavy/deploy_2D")
local kDeploy3DSoundEffect = PrecacheAsset("sound/NS2.fev/marine/heavy/deploy_3D")

local kScreenDissolveSpeed = 1
local kCloseSpeed = 1.116

function ExoWeaponHolder:OnCreate()

    Weapon.OnCreate(self)
    
    self.leftWeaponId = Entity.invalidId
    self.rightWeaponId = Entity.invalidId
	self.weaponMapNameLeft = "minigun"
	self.weaponMapNameRight = "minigun"
	self.dualrailfiring = false
	self.dualminifiring = false
	self.dualBTfiring = false
	self.dualPLfiring = false

    self.closeStart = Shared.GetTime()
    
end

function ExoWeaponHolder:SetDualRailLock(dualfiring)
	self.dualrailfiring = dualfiring
end

function ExoWeaponHolder:SetDualMiniLock(dualfiring)
	self.dualminifiring = dualfiring
end

function ExoWeaponHolder:SetDualBTLock(dualfiring)
	self.dualBTfiring = dualfiring
end

function ExoWeaponHolder:SetDualPLLock(dualfiring)
	self.dualPLfiring = dualfiring
end

if Client then
    function ExoWeaponHolder:OnInitialized()
        Weapon.OnInitialized(self)
        self:SetDualRailLock(Client.GetOptionBoolean("ExoA_duallock_rail_enabled", true))
        Client.SendNetworkMessage("SetDualRailLock", { dualrailfiring = self.dualrailfiring })
		
		self:SetDualMiniLock(Client.GetOptionBoolean("ExoA_duallock_mini_enabled", true))
        Client.SendNetworkMessage("SetDualMiniLock", { dualminifiring = self.dualminifiring })
		
		self:SetDualBTLock(Client.GetOptionBoolean("ExoA_duallock_BT_enabled", true))
        Client.SendNetworkMessage("SetDualBTLock", { dualBTfiring = self.dualBTfiring })
		
		self:SetDualPLLock(Client.GetOptionBoolean("ExoA_duallock_PL_enabled", true))
        Client.SendNetworkMessage("SetDualPLLock", { dualPLfiring = self.dualPLfiring })
    end
end

if Server then

    function ExoWeaponHolder:SetWeapons(weaponMapNameLeft, weaponMapNameRight)
    
        assert(weaponMapNameLeft)
        assert(weaponMapNameRight)
        
		self.weaponMapNameLeft = weaponMapNameLeft
		self.weaponMapNameRight = weaponMapNameRight
		
        if self.leftWeaponId ~= Entity.invalidId then
            DestroyEntity(Shared.GetEntity(self.leftWeaponId))
        end
        local leftWeapon = CreateEntity(weaponMapNameLeft, Vector(), self:GetTeamNumber())
        leftWeapon:SetParent(self:GetParent())
        leftWeapon:SetExoWeaponSlot(ExoWeaponHolder.kSlotNames.Left)
        self.leftWeaponId = leftWeapon:GetId()
        
        if self.rightWeaponId ~= Entity.invalidId then
            DestroyEntity(Shared.GetEntity(self.rightWeaponId))
        end
        local rightWeapon = CreateEntity(weaponMapNameRight, Vector(), self:GetTeamNumber())
        rightWeapon:SetParent(self:GetParent())
        rightWeapon:SetExoWeaponSlot(ExoWeaponHolder.kSlotNames.Right)
        self.rightWeaponId = rightWeapon:GetId()
        
        self.weaponSetupName = weaponMapNameLeft .. "+" .. weaponMapNameRight
        
        if self:GetIsActive() then
            local player = self:GetParent()
            player:SetViewModel(self:GetViewModelName(), self)
        end

    end
    
	function ExoWeaponHolder:GetViewModelName()
		local player = self:GetParent()
		return player.viewModelName
	end

	function ExoWeaponHolder:GetAnimationGraphName()
		local player = self:GetParent()
		return player.viewModelGraphName
	end
    
    function ExoWeaponHolder:OnParentKilled(attacker, doer, point, direction)
    
        local leftWeapon = Shared.GetEntity(self.leftWeaponId)
        if leftWeapon and leftWeapon.OnParentKilled then
            leftWeapon:OnParentKilled(attacker, doer, point, direction)
        end
        
        local rightWeapon = Shared.GetEntity(self.rightWeaponId)
        if rightWeapon and rightWeapon.OnParentKilled then
            rightWeapon:OnParentKilled(attacker, doer, point, direction)
        end
        
    end
    
end

function ExoWeaponHolder:GetHUDSlot()
    return kPrimaryWeaponSlot
end

function ExoWeaponHolder:GetHasSecondary(player)
    return true
end

function ExoWeaponHolder:CheckDualFiring()
	
	if self.weaponMapNameLeft == self.weaponMapNameRight then
		if self.dualrailfiring and self.weaponMapNameLeft == "railgun" then
			return true
		elseif self.dualminifiring and self.weaponMapNameLeft == "minigun" then
			return true
		elseif self.dualBTfiring and self.weaponMapNameLeft == "exoflamer" then
			return true
		elseif self.dualPLfiring and self.weaponMapNameLeft == "PlasmaLauncher" then
			return true
		else
			return false
		end
	end
end

function ExoWeaponHolder:OnPrimaryAttack(player)

    Weapon.OnPrimaryAttack(self, player)

	if self:CheckDualFiring() then
		self:OnSecondaryAttack(player)
	end
	
    Shared.GetEntity(self.leftWeaponId):OnPrimaryAttack(player)
    
end

function ExoWeaponHolder:OnPrimaryAttackEnd(player)
		
    Weapon.OnPrimaryAttackEnd(self, player)
	
	if self:CheckDualFiring() then
		self:OnSecondaryAttackEnd(player)
	end
	
    Shared.GetEntity(self.leftWeaponId):OnPrimaryAttackEnd(player)
    
end

function ExoWeaponHolder:OnSecondaryAttack(player)

    Weapon.OnSecondaryAttack(self, player)
    
    -- Calling OnPrimaryAttack here is intentional.
    Shared.GetEntity(self.rightWeaponId):OnPrimaryAttack(player)
    
end

function ExoWeaponHolder:GetInventoryWeight(player)

    local leftWeapon = Shared.GetEntity(self.leftWeaponId)
    local rightWeapon = Shared.GetEntity(self.rightWeaponId)
    local leftWeaponWeight = leftWeapon.GetWeight and leftWeapon:GetWeight() or 0
    local rightWeaponWeight = rightWeapon.GetWeight and rightWeapon:GetWeight() or 0    

    return leftWeaponWeight + rightWeaponWeight

end

function ExoWeaponHolder:OnSecondaryAttackEnd(player)

    Weapon.OnSecondaryAttackEnd(self, player)
    
    -- Calling OnPrimaryAttackEnd here is intentional.
    Shared.GetEntity(self.rightWeaponId):OnPrimaryAttackEnd(player)
    
end

function ExoWeaponHolder:ProcessMoveOnWeapon(player, input)

    Weapon.ProcessMoveOnWeapon(self, player, input)
    
    Shared.GetEntity(self.leftWeaponId):ProcessMoveOnWeapon(player, input)
    Shared.GetEntity(self.rightWeaponId):ProcessMoveOnWeapon(player, input)
    
end

local function SetViewModelParameter(self, paramName, paramValue)

    local parent = self:GetParent()
    if parent and parent == Client.GetLocalPlayer() then
    
        local viewModel = parent:GetViewModelEntity()
        if viewModel and viewModel:GetRenderModel() then
        
            viewModel:InstanceMaterials()
            viewModel:GetRenderModel():SetMaterialParameter(paramName, paramValue)
            
        end
        
    end
    
end

function ExoWeaponHolder:UpdateViewModelPoseParameters(viewModel)

    local leftWeapon = Shared.GetEntity(self.leftWeaponId)
    if leftWeapon.UpdateViewModelPoseParameters then
        leftWeapon:UpdateViewModelPoseParameters(viewModel)
    end
    local rightWeapon = Shared.GetEntity(self.rightWeaponId)
    if rightWeapon.UpdateViewModelPoseParameters then
        rightWeapon:UpdateViewModelPoseParameters(viewModel)
    end
    
end

function ExoWeaponHolder:OnUpdateRender()

    PROFILE("ExoWeaponHolder:OnUpdateRender")

    SetViewModelParameter(self, "scanlinesMap",
            ConditionalValue(Client.GetHudDetail() == kHUDMode.Minimal, "ui/transparent.dds", "ui/exosuit_scanlines.dds"))

    if not Client.GetIsControllingPlayer() then
        SetViewModelParameter(self, "dissolveAmount", 1)
    else
    
        if self.screenDissolveStart then
        
            local dissolveAmount = math.min(1, (Shared.GetTime() - self.screenDissolveStart) / kScreenDissolveSpeed)
            SetViewModelParameter(self, "dissolveAmount", dissolveAmount)
            
        else
            SetViewModelParameter(self, "dissolveAmount", 0)
        end
        
        if self.closeStart then

            local closeAmount = math.min(1, (Shared.GetTime() - self.closeStart) / kCloseSpeed)
            SetViewModelParameter(self, "closeAmount", closeAmount)
            
            if closeAmount >= 1 then
                self.closeStart = nil
            end
            
        else
            SetViewModelParameter(self, "closeAmount", 1)
        end
        
    end
    
end

local function TriggerScreenDissolveEffect(self)

    if Client and not Shared.GetIsRunningPrediction() then
        self.screenDissolveStart = Shared.GetTime()
    end
    
end

function ExoWeaponHolder:GetLeftSlotWeapon()
    return Shared.GetEntity(self.leftWeaponId)
end

function ExoWeaponHolder:GetRightSlotWeapon()
    return Shared.GetEntity(self.rightWeaponId)
end

function ExoWeaponHolder:OnTag(tagName)

    PROFILE("ExoWeaponHolder:OnTag")

    if tagName == "deploy_start" then
    
        if Server then        
            StartSoundEffectAtOrigin(kDeploy3DSoundEffect, self:GetOrigin())
        end
        
    elseif tagName == "deploy_end" then
        TriggerScreenDissolveEffect(self)
    elseif Client and tagName == "view_step" then
    
        -- This is the local player.
        local player = self:GetParent()
        if player then
        
            local velocity = GetNormalizedVector(player:GetVelocity())
            local viewVec = player:GetViewAngles():GetCoords().zAxis
            local forward = velocity:DotProduct(viewVec) > -0.1
            local crouch = HasMixin(player, "CrouchMove") and player:GetCrouching()
            player:TriggerEffects("footstep", {surface = player:GetMaterialBelowPlayer(), left = false, sprinting = false, forward = forward, crouch = crouch, enemy = false})
            
        end
        
    end
    
    Shared.GetEntity(self.leftWeaponId):OnTag(tagName)
    Shared.GetEntity(self.rightWeaponId):OnTag(tagName)
    
end

function ExoWeaponHolder:OnUpdateAnimationInput(modelMixin)

    Shared.GetEntity(self.leftWeaponId):OnUpdateAnimationInput(modelMixin)
    Shared.GetEntity(self.rightWeaponId):OnUpdateAnimationInput(modelMixin)
    
end

Shared.LinkClassToMap("ExoWeaponHolder", ExoWeaponHolder.kMapName, networkVars)