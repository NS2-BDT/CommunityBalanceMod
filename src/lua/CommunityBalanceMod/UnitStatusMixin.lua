-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\UnitStatusMixin.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

kUnitStatus = enum({
    'None',
    'Inactive',
    'Unpowered',
    'Dying',
    'Unbuilt',
    'Damaged',
    'Researching',
    'Unrepaired'
})

UnitStatusMixin = CreateMixin(UnitStatusMixin)
UnitStatusMixin.type = "UnitStatus"

function UnitStatusMixin:__initmixin()
    
    PROFILE("UnitStatusMixin:__initmixin")
    
    self.unitStatus = kUnitStatus.None
    self.unitStates = {}
end

function UnitStatusMixin:GetShowUnitStatusFor(forEntity)

    if self.GetShowUnitStatusForOverride then
        return self:GetShowUnitStatusForOverride(forEntity)
    end
    
    if HasMixin(self, "Live") then
        return self:GetIsAlive()
    end
    
    return true
    
end

function UnitStatusMixin:GetUnitStatus(forEntity)

    local unitStatus = kUnitStatus.None

    -- don't show status of opposing team
    if GetAreFriends(forEntity, self) then

        if not GetIsUnitActive(self) then
        
            if HasMixin(self, "Construct") and not self:GetIsBuilt() and (forEntity:isa("Gorge") or forEntity.GetCanSeeConstructIcon and forEntity:GetCanSeeConstructIcon(self) ) then
                unitStatus = kUnitStatus.Unbuilt 

            elseif HasMixin(self, "PowerConsumer") and self:GetRequiresPower() and not self:GetIsPowered() then
                unitStatus = kUnitStatus.Unpowered         
            end
        
        else
        
            if GetIsAlienUnit(self) and LookupTechData(self:GetTechId(), kTechDataRequiresInfestation, false) and (HasMixin(self, "GameEffects") and not self:GetGameEffectMask(kGameEffect.OnInfestation)) then
                unitStatus = kUnitStatus.Dying
                
            elseif HasMixin(self, "Research") and self:GetIsResearching() then
                unitStatus = kUnitStatus.Researching
            
            elseif HasMixin(self, "Live") and self:GetHealthScalar() < 1 and self:GetIsAlive() and (not forEntity.GetCanSeeDamagedIcon or forEntity:GetCanSeeDamagedIcon(self)) then

                local forEntityIsMarine = forEntity:isa("Marine")
				local forEntityIsBlowtorch
				if forEntity:isa("Exo") then
					forEntityIsBlowtorch = forEntity.rightArmModuleType == 6 or forEntity.leftArmModuleType == 6
				end	
				
                if forEntityIsMarine or forEntityIsBlowtorch then
                    if self:isa("Marine") then
                        if self:GetArmor() < self:GetMaxArmor() then -- only mark Marines as damaged when they can be weld
                            unitStatus = kUnitStatus.Damaged
                        end
                    elseif not self:isa("Powerpoint") or self:GetIsBuilt() then -- only mark powerpoints as damaged after they have been built
                        unitStatus = kUnitStatus.Damaged
                    end
                elseif forEntity:isa("Gorge") then
                    unitStatus = kUnitStatus.Damaged
                end
                
                if unitStatus == kUnitStatus.Damaged and (forEntityIsMarine or forEntityIsBlowtorch) and not forEntity:GetWeapon(Welder.kMapName) then
                    unitStatus = kUnitStatus.Unrepaired
                end
                    
            end
        
        end
    
    end

    return unitStatus

end

function UnitStatusMixin:GetUnitState(forEntity)
    --use cached state
    if self.unitStates[forEntity] then
        if self.unitStates[forEntity].updateTime > Shared.GetTime() then
            return self.unitStates[forEntity].state
        end
    end
end

local stateCacheTime = 0.2 -- cache data lifetime
function UnitStatusMixin:SetUnitState(forEntity, state)
    self.unitStates[forEntity] = {
        state = state,
        updateTime = Shared.GetTime() + stateCacheTime
    }
end

function UnitStatusMixin:GetUnitStatusFraction(forEntity)

    if GetAreFriends(forEntity, self) and forEntity:isa("Gorge") and HasMixin(self, "Construct") and not self:GetIsBuilt() then
        return self:GetBuiltFraction()
    end
    
    if GetAreFriends(forEntity, self) and HasMixin(self, "Research") and self:GetIsResearching() then
        return self:GetResearchProgress()   
    end
    
    return 0

end

function UnitStatusMixin:GetUnitHint2(forEntity)

    if HasMixin(self, "Tech") then
    
        local hintString = LookupTechData(self:GetTechId(), kTechDataHint, "")

        if self.OverrideHintString then
            hintString = self:OverrideHintString(hintString, forEntity)
        end
        
        if hintString ~= "" then            
            return Locale.ResolveString(hintString)
        end
        
    end
    
    return ""

end

function UnitStatusMixin:GetUnitName(forEntity)
    
    if HasMixin(self, "Tech") then
    
        if self.GetUnitNameOverride then
            return self:GetUnitNameOverride(forEntity)
        end
    
        if not self:isa("Player") then
        
            local description = GetDisplayName(self)
            if HasMixin(self, "Construct") and not self:GetIsBuilt() then
                description = string.format(Locale.ResolveString("UNBUILT_STRUCTURE"), description)
            end
        
            return description
            
        else            
            return self:GetName(forEntity)            
        end
    
    end

    return ""

end

function UnitStatusMixin:GetActionName(forEntity)

    if GetAreFriends(forEntity, self) and HasMixin(self, "Research") and self:GetIsResearching() then
    
        local researchingId = self:GetResearchingId()
        local displayName = LookupTechData(researchingId, kTechDataDisplayName, "")
        
        return Locale.ResolveString(displayName)
        
    end
    
    return ""

end

function UnitStatusMixin:GetHasWelder(forEntity)

    return not GetAreEnemies(forEntity, self) and HasMixin(self, "WeaponOwner") and self:GetWeapon(Welder.kMapName) ~= nil

end

function UnitStatusMixin:GetAbilityFraction(forEntity)

    if HasMixin(self, "WeaponOwner") then

        if GetAreEnemies(forEntity, self) then
            return 0
        end

        local primaryWeapon = self:GetWeaponInHUDSlot(1)
        if primaryWeapon and primaryWeapon:isa("ClipWeapon") then
            -- always show at least 1% so commander would see a black bar
            return math.max(0.01, primaryWeapon:GetAmmoFraction())
        elseif self:isa("Player") and self:isa("Alien") and not self:isa("Hallucination") and not self:isa("Embryo") then
            return math.max(0.01, self:GetEnergy() / self:GetMaxEnergy())
        end
        
    end

    return 0    

end
