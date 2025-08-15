-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Weapon_Server.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

local kPerformExpirationCheckAfterDelay = 1.00

function Weapon:OnInitialized()

    ScriptActor.OnInitialized(self)
    
    self:SetWeaponWorldState(true, true)
    self:SetRelevancy()
    self.timerActive = false
    
end

function Weapon:GetPrimaryAttackPlaysClientSound()
    return false
end

function Weapon:GetSecondaryAttackPlaysClientSound()
    return false
end

function Weapon:MaybeRevealParentToEnemyBots()
    if not Server then return end

    local parent = self:GetParent()
    if HasMixin(parent, "Team") and HasMixin(parent, "MapBlip") then
        local enemyTeamNumber = GetEnemyTeamNumber(parent:GetTeamNumber())
        if enemyTeamNumber and enemyTeamNumber ~= kTeamInvalid then -- GetTeamBrain asserts

            local teamBrain = GetTeamBrain(enemyTeamNumber)
            if teamBrain then
                local isClientSoundAudible = teamBrain:GetIsClientSoundAudible(parent:GetOrigin())
                if isClientSoundAudible then
                    teamBrain:UpdateMemoryOfEntity(parent, true)
                end
            end
        end
    end
end

function Weapon:Dropped(prevOwner)

    self.prevOwnerId = prevOwner:GetId()
    self:SetWeaponWorldState(true)

    --McG: FIXME If previous owner isn't accessible (for whatever reason), below will fail. If !owner, just fall
    if self.physicsModel then
        local viewCoords = prevOwner:GetViewCoords()
        self.physicsModel:AddImpulse(self:GetOrigin(), (viewCoords.zAxis * kMarineWeaponTossImpulse))
        self.physicsModel:SetAngularVelocity(Vector(4,1,1)) --McG: This could be a function of viewer-angles
    end
    
    self.weaponExpirationCheckTime = Shared.GetTime() + kPerformExpirationCheckAfterDelay

end

-- Set to true for being a world weapon, false for when it's carried by a player
function Weapon:SetWeaponWorldState(state, preventExpiration)

    if state ~= self.weaponWorldState then
    
        self.weaponExpirationCheckTime = nil -- Cancel any expiration timer set during a drop
        
        if state then
            
            --FIXME Doesn't consistently affect all model variants (more debugging needed), but this will be resolved when material-swapping is added
            self:SetModelMass( kDefaultMarineWeaponMass )

            -- when dropped weapons always need a physic model
            if not self.physicsModel then
                self.physicsModel = Shared.CreatePhysicsModel(self.physicsModelIndex, true, self:GetCoords(), self)
            end
            
            self:SetPhysicsType(PhysicsType.DynamicServer)
            
            -- So it doesn't affect player movement and so collide callback is called
            self:SetPhysicsGroup(PhysicsGroup.DroppedWeaponGroup)
            self:SetPhysicsGroupFilterMask(PhysicsMask.DroppedWeaponFilter)
            
            if self.physicsModel then
                self.physicsModel:SetCCDEnabled(true)
            end
            
            if not preventExpiration then
                self:StartExpiration()
            else
                self:PreventExpiration()
            end
            
            self:SetIsVisible(true)

            self:SetUpdateRate(kRealTimeUpdateRate)
            
        else
        
            self:SetPhysicsType(PhysicsType.None)
            self:SetPhysicsGroup(PhysicsGroup.WeaponGroup)
            self:SetPhysicsGroupFilterMask(PhysicsMask.None)
            
            if self.physicsModel then
                self.physicsModel:SetCCDEnabled(false)
            end

            self:SetUpdateRate(kDefaultUpdateRate)
            
        end
        
        self.hitGround = false
        
        self.weaponWorldState = state
        
    end
    
end

function Weapon:PreventExpiration()

    self.expireTime = nil
    self.weaponWorldStateTime = nil
    self.weaponExpirationCheckTime = nil
    self.timerActive = false

end

local ignoredWeapons = set { "Pistol", "Rifle" }

-- The return value for this function tells the TimedCallback engine whether or not to repeat the timer. True means repeat.
function Weapon:CheckExpireTime()
    PROFILE("Weapon:CheckExpireTime")

    if self:GetExpireTime() == 0 then
        self.timerActive = false
        return false
    end

    if not self.weaponWorldState then
        self.timerActive = false
        return false
    end

    if #GetEntitiesForTeamWithinRange("Marine", self:GetTeamNumber(), self:GetOrigin(), 1.5) > 0 then
        self.weaponWorldStateTime = Shared.GetTime()
        self.expireTime = Shared.GetTime() + kWeaponStayTime
        return true
    end

    -- don't check if there are nearby armories for weapons that should decay at armory
    if ignoredWeapons[self:GetClassName()] then
        return true
    end

    local armories = GetEntitiesForTeamWithinRange("Armory", self:GetTeamNumber(), self:GetOrigin(), kArmoryDroppedWeaponAttachRange)
    local nearbyArmory = false
    for _, armory in ipairs(armories) do
        if GetIsUnitActive(armory) then
            nearbyArmory = true
            break
        end
    end


    if nearbyArmory then
        self:PreventExpiration()
        return false
    end

    return true
end

function Weapon:StartExpiration()

    self.weaponWorldStateTime = Shared.GetTime()
    self.expireTime = Shared.GetTime() + kWeaponStayTime

    if not self.timerActive then
        self.timerActive = true
        self:AddTimedCallback(self.CheckExpireTime, 0.5)
    end

end

function Weapon:DestroyWeaponPhysics()

    if self.physicsModel then
        Shared.DestroyCollisionObject(self.physicsModel)
        self.physicsModel = nil
    end    

end

function Weapon:OnCapsuleTraceHit(entity)

    PROFILE("Weapon:OnCapsuleTraceHit")

    if self.OnCollision then
        self:OnCollision(entity)
    end
    
end

-- Should only be called when dropped
function Weapon:OnCollision(targetHit)

    if not targetHit then
    
        -- Play weapon drop sound
        if not self.hitGround then
            --McG: Could potentially check self velocity and ground to play sliding sound
            -- above could also be used to trigger multiple drop events (per hit/touch)
            self:TriggerEffects("weapon_dropped")
            self.hitGround = true
            
        end
        
    end
    
end

function Weapon:OnEntityChange(oldId, newId)
    if self.prevOwnerId == oldId then
        self.prevOwnerId = newId or Entity.invalidId
    end
end

Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, 0)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, PhysicsGroup.DefaultGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, PhysicsGroup.CommanderPropsGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, PhysicsGroup.AttachClassGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, PhysicsGroup.CommanderUnitGroup)
Shared.SetPhysicsCollisionCallbackEnabled(PhysicsGroup.DroppedWeaponGroup, PhysicsGroup.CollisionGeometryGroup)

-- %%% New CBM Functions %%% --
local damageDeductionRate = 9 / 400
function Weapon:OnTakeDamage(damage, attacker, doer, point)

    -- Max Weapon Decay = 16 seconds
    -- Max Weapon HP = 400

    -- for balance we use /400 * 9 instead of /400 *16
    -- 2 biles deal close to 400 damage and should shorten lifespan by 9 seconds
    -- higher values can cause weapons to decay too fast resulting in reduced reward points for gorge biling
    
    local deductTime =  damage * damageDeductionRate

    if self.expireTime and self.expireTime > 0.1 then 

        self.expireTime = self.expireTime - deductTime
        if self.expireTime <= 0.1 then 
            self.expireTime = 0.1
        end
    end
end
