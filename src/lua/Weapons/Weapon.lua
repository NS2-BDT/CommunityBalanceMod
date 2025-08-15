-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Weapon.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/ScriptActor.lua")
Script.Load("lua/Mixins/ModelMixin.lua")
Script.Load("lua/TeamMixin.lua")
Script.Load("lua/DamageMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/Weapons/WeaponDisplayManager.lua")

class 'Weapon' (ScriptActor)

Weapon.kMapName = "weapon"

-- Attach point for marine weapons
Weapon.kHumanAttachPoint = "RHand_Weapon"
-- Super important constant that defines how often a bite or other melee attack will hit
Weapon.kMeleeBaseWidth = .5
Weapon.kMeleeBaseHeight = .8

Weapon.kLowAmmoWarningEnabled = true

if Server then
    Script.Load("lua/Weapons/Weapon_Server.lua")
elseif Client then
    Script.Load("lua/Weapons/Weapon_Client.lua")
end

local networkVars =
{
    isHolstered = "boolean",
    primaryAttacking = "compensated boolean",
    secondaryAttacking = "compensated boolean",
    weaponWorldState = "boolean",
    expireTime = "time (by 0.1)"
}

AddMixinNetworkVars(BaseModelMixin, networkVars)
AddMixinNetworkVars(ModelMixin, networkVars)
AddMixinNetworkVars(TeamMixin, networkVars)

function Weapon:OnCreate()

    ScriptActor.OnCreate(self)
    
    InitMixin(self, BaseModelMixin)
    InitMixin(self, ModelMixin)
    InitMixin(self, TeamMixin)
    InitMixin(self, DamageMixin)
    InitMixin(self, UnitStatusMixin)
    
    self:SetPhysicsGroup(PhysicsGroup.WeaponGroup)

    --Only droppable weapons use OnUpdate
    self:SetUpdates(self:GetIsDroppable())
    
    self.reverseX = false
    self.isHolstered = true
    self.primaryAttacking = false
    self.secondaryAttacking = false
    
    -- This value is used a lot in this class, cache it off.
    self.mapName = self:GetMapName()

    self.weaponWorldState = false
    
    if Client then
        self.activeSince = 0
        self:AddFieldWatcher("weaponWorldState", self.OnWorldStateChange)
        Weapon.kLowAmmoWarningEnabled = GetAdvancedOption("lowammowarning")
    end
    
end

function Weapon:OnDestroy()
    
    -- Force end events just in case the weapon goes out of relevancy on the client for example.
    self:TriggerEffects(self:GetPrimaryAttackPrefix() .. "_attack_end")
    self:TriggerEffects(self:GetSecondaryAttackPrefix() .. "_alt_attack_end")
    
    ScriptActor.OnDestroy(self)
    
end

function Weapon:GetAnimationGraphName()
    return nil
end

function Weapon:GetBarrelPoint()

    local player = self:GetParent()
    return player and player:GetEyePos()

end

function Weapon:GetCanBeUsed(_, useSuccessTable)
    useSuccessTable.useSuccess = false    
end

function Weapon:OnParentChanged(oldParent, newParent)
    
    ScriptActor.OnParentChanged(self, oldParent, newParent)
    
    if oldParent then
    
        self:OnPrimaryAttackEnd(oldParent)
        self:OnSecondaryAttackEnd(oldParent)
        
    end

end

function Weapon:OnUpdateWeapon()
end

function Weapon:UpdateWeaponSkins(client)
end

function Weapon:GetViewModelName()
    return ""
end

function Weapon:GetRange()
    return 100
end

function Weapon:GetHasSecondary(player)
    return false
end

-- Return 0-1 scalar approximation for weight. Owner of weapon will determine
-- what this means and how to use it.
function Weapon:GetWeight()
    return 0
end

function Weapon:SetCameraShake(amount, speed, time)
    local parent = self:GetParent()
    if(parent ~= nil and Client) then
        parent:SetCameraShake(amount, speed, time)
    end
end

function Weapon:GetIsDroppable()
    return false
end

function Weapon:GetSprintAllowed()
    return true
end

function Weapon:GetTryingToFire(input)
    return (bit.band(input.commands, Move.PrimaryAttack) ~= 0) or ((bit.band(input.commands, Move.SecondaryAttack) ~= 0) and self:GetHasSecondary(self:GetParent()))
end

function Weapon:GetPrimaryAttackRequiresPress()
    return false
end

function Weapon:GetSecondaryAttackRequiresPress()
    return false
end

-- So child classes can override names of event names that are triggered (for grenade launcher to use rifle effects block)
function Weapon:GetPrimaryAttackPrefix()
    return self.mapName
end

function Weapon:GetSecondaryAttackPrefix()
    return self.mapName
end

function Weapon:OnPrimaryAttack(player)
end

function Weapon:OnPrimaryAttackEnd(player)
end

function Weapon:OnSecondaryAttack(player)
end

function Weapon:OnSecondaryAttackEnd(player)
end

function Weapon:OnReload(player)
end

function Weapon:GetIsHolstered()
    return self.isHolstered
end

function Weapon:GetCanSkipPhysics()
    return self:GetParent() and self.isHolstered
end

function Weapon:GetIsAffectedByWeaponUpgrades()
    return true
end    

function Weapon:OnHolster(player)

    self:OnPrimaryAttackEnd(player)
    
    self.isHolstered = true
    self:SetIsVisible(false)
    self.primaryAttacking = false
    self.secondaryAttacking = false
    
end

function Weapon:GetResetViewModelOnDraw()
    return true
end

function Weapon:UpdateViewModel(player)
    if HasMixin(player, "MarineVariant") then
        player:SetViewModel(self:GetViewModelName(player:GetMarineTypeString(), player:GetVariant()), self)
    else
        player:SetViewModel(self:GetViewModelName(), self)
    end
end

function Weapon:OnDraw(player, previousWeaponMapName)

    self.isHolstered = false
    self:SetIsVisible(true)
    
    if self:GetResetViewModelOnDraw() then
        player:SetViewModel(nil, nil)
    end
    
    -- set view model based on selected skin.
    self:UpdateViewModel(player)
    
    self:TriggerEffects("draw")
    
end

--
-- The melee base is the width and height of the surface that defines the melee volume.
-- This box needs to be wide enough so that if a target is mostly on screen, the bite will hit
-- Because of perspective, this means that the farther away a target gets, the more accurate
-- we'll need to be (the closer to the center of the screen)
--
function Weapon:GetMeleeBase()
    -- Width of box, height of box
    return Weapon.kMeleeBaseWidth, Weapon.kMeleeBaseHeight
end

--
-- Extra offset from viewpoint to make sure you don't hit anything to your rear.
--
function Weapon:GetMeleeOffset()
    return 0.0
end

function Weapon:ConstrainMoveVelocity(moveVelocity)
end

function Weapon:OnUpdate(deltaTime)
    ScriptActor.OnUpdate(self, deltaTime)

    if Server then
        local now = Shared.GetTime()
        if self.weaponWorldState and self.weaponWorldStateTime and self.expireTime < now then
            --DestroyEntity(self)
            self:Kill()
        end
    end

end

function Weapon:ProcessMoveOnWeapon(player, input)
end

function Weapon:GetUIDisplaySettings()
    return nil
end

function Weapon:OnUpdateRender()

    local parent = self:GetParent()
    local settings = self:GetUIDisplaySettings()
    if parent and parent:GetIsLocalPlayer() and settings then

        local isActive = self:GetIsActive()
        local mapName = settings.textureNameOverride or self:GetMapName()
        local ammoDisplayUI = GetWeaponDisplayManager():GetWeaponDisplayScript(settings, mapName)
        self.ammoDisplayUI = ammoDisplayUI
        
        ammoDisplayUI:SetGlobal("weaponClip", parent:GetWeaponClip())
        ammoDisplayUI:SetGlobal("weaponAmmo", parent:GetWeaponAmmo())
        ammoDisplayUI:SetGlobal("weaponAuxClip", parent:GetAuxWeaponClip())

        if settings.variant and isActive then
            --[[
                Only update variant if we are the active weapon, since some
                of these GUIViews are re-used. For example, the Builder and Welder GUIViews are one
                and the same, which could cause (randomly, depending on the order of execution) the builder
                to override the variant of the welder due to this method being called for both weapons, and the
                builder's UpdateRender function being called _after_ the welder's.
            --]]
            ammoDisplayUI:SetGlobal("weaponVariant", settings.variant)
        end
        self.ammoDisplayUI:SetGlobal("globalTime", Shared.GetTime())
        -- For some reason I couldn't pass a bool here so... this is for modding anyways!
        -- If you pass anything that's not "true" it will disable the low ammo warning
        self.ammoDisplayUI:SetGlobal("lowAmmoWarning", tostring(Weapon.kLowAmmoWarningEnabled))
        
        -- Render this frame, if the weapon is active.  This is called every frame, so we're just
        -- saying "render one frame" every frame it's equipped.  Easier than keeping track of
        -- when the weapon is holstered vs equipped, and this call is super cheap.
        if isActive then
            self.ammoDisplayUI:SetRenderCondition(GUIView.RenderOnce)
        end
        
    end
    
end

function Weapon:GetIsActive()
    local parent = self:GetParent()
    return (parent ~= nil and (parent.GetActiveWeapon) and (parent:GetActiveWeapon() == self))
end

-- Max degrees that weapon can swing left or right
function Weapon:GetSwingAmount()
    return 40
end

function Weapon:GetSwingSensitivity()
    return .5
end

function Weapon:SetRelevancy()

    local mask = bit.bor(kRelevantToTeam1Unit, kRelevantToTeam2Unit, kRelevantToReadyRoom)
    mask = bit.bor(mask, kRelevantToTeam1Commander, kRelevantToTeam2Commander)
    
    self:SetExcludeRelevancyMask(mask)
    
end

-- this would cause the use button to appear on the hud, there is a separate functionality for picking up weapons
function Weapon:GetCanBeUsed(_, useSuccessTable)
    useSuccessTable.useSuccess = false
end

function Weapon:OnCreateCollisionModel()
    
    -- Remove any "move" collision representation for the weapon
    -- so that it doesn't interfere with movement.
    local collisionModel = self:GetCollisionModel()
    collisionModel:RemoveCollisionRep(CollisionRep.Move)
    
end

function Weapon:GetExpireTimeFraction()
    if self.expireTime then
        return Clamp((self.expireTime - Shared.GetTime()) / kWeaponStayTime, 0, 1)
    else
        return 0
    end
end

function Weapon:GetExpireTime()
    return self.expireTime or 0
end

function Weapon:GetWeaponWorldState()
    return self.weaponWorldState
end

Shared.LinkClassToMap("Weapon", Weapon.kMapName, networkVars)
