
local function PickupWeapon(self, weapon, wasAutoPickup)
    
    -- some weapons completely replace other weapons (welder > axe).
    local replacement = weapon.GetReplacementWeaponMapName and weapon:GetReplacementWeaponMapName()
    local obsoleteWep = replacement and self:GetWeapon(replacement) -- Player walked over weapon with higher priority. Handled by weapon pickupable getter func.
    local obsoleteSlot
    local activeWeapon = self:GetActiveWeapon()
    local activeSlot = activeWeapon and activeWeapon:GetHUDSlot()
    local delayPassed = (Shared.GetTime() - self.timeOfLastPickUpWeapon > Marine.kMarineBuyAutopickupDelayTime)



    -- find the weapon that is about to be dropped to make room for this one
    local slot = weapon:GetHUDSlot()
    local oldWep = self:GetWeaponInHUDSlot(slot)


    -- Balance mod
    local WelderAutopickupDelayTime = 1
    local delayPassedWelder = (Shared.GetTime() - self.timeOfLastPickUpWeapon > WelderAutopickupDelayTime )
    if weapon and weapon:isa("Welder") then 
        delayPassed = delayPassedWelder
    end


    -- Delay autopickup if we're replacing/upgrading a weapon (Autopickup Better Weapon).
    -- This way it won't immediately pick up your old weapon when you buy a lower priority one. (Having a shotgun then buying a grenade launcher, for example)
    if wasAutoPickup and oldWep and not delayPassed then
        return
    end


    if obsoleteWep then
        
        -- If we are "using", and the weapon we will switch back to when we're done "using"
        -- is the weapon we're replacing, make sure we also replace this reference.
        local obsoleteWepId = obsoleteWep:GetId()
        if obsoleteWepId == self.weaponBeforeUseId then
            self.weaponBeforeUseId = weapon:GetId()
        end
        
        obsoleteSlot = obsoleteWep:GetHUDSlot()
        self:RemoveWeapon(obsoleteWep)
        DestroyEntity(obsoleteWep)
    end
    
    -- perform the actual weapon pickup (also drops weapon in the slot)
    self:AddWeapon(weapon, not wasAutoPickup or slot == 1)

    self:TriggerEffects("marine_weapon_pickup", { effecthostcoords = self:GetCoords() })
    
    -- switch to the picked up weapon if the player deliberately (non-automatically) picked up the weapon,
    -- or if the weapon they were picking up automatically replaced a weapon they already had, and they
    -- currently have no weapons (this avoids the ghost-axe problem).
    if not wasAutoPickup or
        (replacement and (self:GetActiveWeapon() == nil or obsoleteSlot == activeSlot)) then
        self:SetHUDSlotActive(weapon:GetHUDSlot())
    end

    if HasMixin(weapon, "Live") then
        weapon:SetHealth(weapon:GetMaxHealth())
    end
    
    self.timeOfLastPickUpWeapon = Shared.GetTime()
    if oldWep then -- Ensure the last weapon in that slot actually existed and was dropped so you don't override a valid last weapon
        self.lastDroppedWeapon = oldWep
    end
    
end



debug.setupvaluex(Marine.HandleButtons, "PickupWeapon", PickupWeapon)