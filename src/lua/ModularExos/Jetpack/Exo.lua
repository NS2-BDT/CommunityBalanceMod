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
