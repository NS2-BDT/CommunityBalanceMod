-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Alien\BoneShield.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Puts the onos in a defensive, slow moving position where it uses energy to absorb damage.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Alien/Ability.lua")
Script.Load("lua/Weapons/Alien/StompMixin.lua")

if Client then
    Script.Load("lua/GUIBoneShieldDisplay.lua")
end

class 'BoneShield' (Ability)

BoneShield.kMapName = "boneshield"

local kAnimationGraph = PrecacheAsset("models/alien/onos/onos_view.animation_graph")
local kTimeSinceBlockedDamageForCombat = 3
local kMaxBoneshieldHitpoints = kBoneShieldHitpoints

local networkVars =
{
    hitPoints = "private float (0 to 1000 by 0.01)",
    lastTimeDeactivated = "private time",
    lastTimeBlockedDamage = "private time",
    hitPointsRechargeStartTime = "private time",
    holsterTime = "private time",
}

AddMixinNetworkVars(StompMixin, networkVars)

function BoneShield:OnCreate()

    Ability.OnCreate(self)
    
    InitMixin(self, StompMixin)

    -- netvars
    self.hitPoints = kMaxBoneshieldHitpoints
    self.lastTimeDeactivated = 0
    self.hitPointsRechargeStartTime = 0
    self.holsterTime = 0

    -- not netvars
    self.isBroken = false

    if Client then
        self.lastHitPoints = kMaxBoneshieldHitpoints
    end

end

if Client then

    local function UpdateBoneshieldUIActive(self)

        local player = self:GetParent()
        if player then

            local activeWeapon = player:GetActiveWeapon()
            if player:GetIsLocalPlayer() and
                    Client.GetIsControllingPlayer() and
                    activeWeapon and activeWeapon:isa("BoneShield") then
                self.active = true
                return
            end

        end

        self.active = false

    end

    function BoneShield:OnInitialized()

        local player = self:GetParent()
        if player then

            if player:GetIsLocalPlayer() and
                    Client.GetIsControllingPlayer() and
                    player:isa("Onos") then

                self.guiObj = CreateGUIObject("boneshield_ui", GUIBoneShieldDisplay)

            end
        end

        self.active = false
    end

	function BoneShield:OnUpdateRender()
		local localPlayer = Client.GetLocalPlayer()

		if self.guiObj then
			local now = Shared.GetTime()
			local shouldBeVisible = localPlayer and localPlayer:isa("Onos") and (self.active or now <= self.hitPointsRechargeStartTime) and not HelpScreen_GetHelpScreen():GetIsBeingDisplayed() and not GetMainMenu():GetVisible()

			self.guiObj:SetVisible(shouldBeVisible)

			if shouldBeVisible then
				self.guiObj:SetCurrentHP(self.hitPoints)
				if self.lastHitPoints - self.hitPoints > 1 then -- netvar jitter workaround
					self.guiObj:StartFlashing()
				end

				self.guiObj:SetBroken(self.hitPoints <= kEpsilon)

				self.lastHitPoints = self.hitPoints
			end
		end
	end
	
    function BoneShield:OnHolsterClient() -- Gets called in WeaponOwnerMixin when OnDestroy happens.
        Ability.OnHolsterClient(self)
        self.active = false
    end

    function BoneShield:OnKillClient()
        self.active = false
        if self.guiObj then
            self.guiObj:SetVisible(false)
        end
    end

    function BoneShield:OnDrawClient()
        Ability.OnDrawClient(self)
        UpdateBoneshieldUIActive(self)
    end

    function BoneShield:OnDestroy()
        Ability.OnDestroy(self)
        if self.guiObj then
            self.guiObj:Destroy()
        end
    end

end

---@param damage number Damage received
---@return number Leftover Damage BoneShield couldn't block
function BoneShield:TakeDamage(damage)

    local damageBlocked = Clamp(damage, 0, self.hitPoints)
    local damageLeft = damage - damageBlocked

    self.hitPoints = self.hitPoints - damageBlocked
    self.lastTimeBlockedDamage = Shared.GetTime()
    self:UpdateHitpointsRechargeStartTime()

    return damageLeft

end

function BoneShield:GetEnergyCost()
    return 0
end

function BoneShield:GetAnimationGraphName()
    return kAnimationGraph
end

function BoneShield:GetHUDSlot()
    return 2
end

function BoneShield:UpdateHitpointsRechargeStartTime()

    local now = Shared.GetTime()
    local cooldown = kBoneShieldHitpointsRegenIdleCooldown

    if self.hitPoints <= kEpsilon then
        cooldown = kBoneShieldHitpointsRegenBrokenCooldown
    elseif now - self.lastTimeBlockedDamage <= kTimeSinceBlockedDamageForCombat then
        cooldown = kBoneShieldHitpointsRegenCombatCooldown
    end

    self.hitPointsRechargeStartTime = now + cooldown

end

function BoneShield:GetCooldownFraction()
    local now = Shared.GetTime()
    local timeSince = now - self.lastTimeDeactivated
    return 1 - Clamp(timeSince / kBoneShieldActivationCooldown, 0, 1)
end

function BoneShield:IsRechargeOnCooldown()
    local now = Shared.GetTime()
    local result = (now - self.lastTimeDeactivated) <= self:GetCooldown()
    return result
end

-- NOTE(Salads): BoneShield now only has a energy recharge cooldown.
function BoneShield:GetCanUseBoneShield(player)
    local now = Shared.GetTime()
    return
    (now - self.lastTimeDeactivated) > kBoneShieldActivationCooldown
            and self.hitPoints > (kMaxBoneshieldHitpoints * kBoneShieldMinimumStartHitpointsFactor)
            and player:GetIsOnGround()
            and not self.secondaryAttacking
            and not player.charging
            and not (player.GetIsStomping and player:GetIsStomping())
end

function BoneShield:OnPrimaryAttack(player)
    if not self.primaryAttacking and self:GetCanUseBoneShield(player) then
        self.primaryAttacking = true

        if Server then
            player:TriggerEffects("onos_shield_start")
        end
    end
end

function BoneShield:OnPrimaryAttackEnd()
    self.primaryAttacking = false
    self.lastTimeDeactivated = Shared.GetTime()
    self:UpdateHitpointsRechargeStartTime()
end

--Note: POSE 3P params are controlled in Onos.lua
function BoneShield:OnUpdateAnimationInput(modelMixin)

    local activityString = "none"
    local abilityString = "boneshield"
    
    if self.primaryAttacking then
        activityString = "primary"
    end
    
    modelMixin:SetAnimationInput("ability", abilityString)
    modelMixin:SetAnimationInput("activity", activityString)
    
end


function BoneShield:OnHolster(player)
    Ability.OnHolster(self, player)
    self.secondaryAttacking = false
    self:OnPrimaryAttackEnd(player)
    self.holsterTime = Shared.GetTime()
end

function BoneShield:OnBroken()
    self.hitPoints = 0
    --self.primaryAttacking = false
    --self.lastTimeDeactivated = Shared.GetTime()
    --self:UpdateHitpointsRechargeStartTime()
    self:OnPrimaryAttackEnd()
    self:GetParent():TriggerEffects("onos_shield_break")
    self.isBroken = true
end

function BoneShield:ProcessMoveOnWeapon(player, input)

    local now = Shared.GetTime()

    if not self.isBroken and (now < self.hitPointsRechargeStartTime) and self.hitPoints <= kEpsilon or not player:GetIsAlive() then
        self:OnBroken()

    elseif now > self.hitPointsRechargeStartTime then
        local hitpointsToRecover = 0

        -- ProcessMoveOnWeapon only gets called on active weapon, but we want boneshield fuel to regen while "holstered"
        -- This will have the fuel "catch up" to where it should be when/if this func gets called again
        if self.holsterTime > 0 then
            local pastTime = math.max(self.holsterTime, self.hitPointsRechargeStartTime)
            hitpointsToRecover = (now - pastTime) * kBoneShieldHitpointsRegenRate
        else
            hitpointsToRecover = kBoneShieldHitpointsRegenRate * input.time
        end

        self.hitPoints = Clamp(self.hitPoints + hitpointsToRecover, 0, kMaxBoneshieldHitpoints)
        self.isBroken = false
    end

    self.holsterTime = 0

end

if Server then

    local kValidCooldownTypes = set
    {
        'idle',
        'combat',
        'broken'
    }

    Event.Hook("Console_bs_hp", function(client, damage, cooldownType)

        if not Shared.GetCheatsEnabled() then
            Log("Cheats must be enabled!")
            return false
        end

        cooldownType = not kValidCooldownTypes[cooldownType] and 'idle' or cooldownType

        local boneshieldWeapon = client:GetControllingPlayer():GetWeapon(BoneShield.kMapName)
        if boneshieldWeapon then
            Log("$ Damaging boneshield with %s damage in situation %s", damage, cooldownType)
            local now = Shared.GetTime()
            boneshieldWeapon:TakeDamage(damage)

            if cooldownType == 'combat' then
                boneshieldWeapon.hitPointsRechargeStartTime = now + kBoneShieldHitpointsRegenCombatCooldown
            elseif cooldownType == 'broken' then
                boneshieldWeapon:OnBroken()
            end

        end
    end)
end


Shared.LinkClassToMap("BoneShield", BoneShield.kMapName, networkVars)
