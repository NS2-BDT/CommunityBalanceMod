-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================




-- Players heal by base amount + percentage of max health
local kHealPlayerPercent = 3

local function HealEntity(_, player, targetEntity)
    
    -- Heal players by base amount plus a scaleable amount so it's effective vs. small and large targets.
    local health = kHealsprayDamage + targetEntity:GetMaxHealth() * kHealPlayerPercent / 100.0
    
    -- Heal structures by multiple of damage(so it doesn't take forever to heal hives, ala NS1)
    if GetReceivesStructuralDamage(targetEntity) then

        health = kStructureHealsprayMDS -- Balance Mod, changed from 60

    -- Don't heal self at full rate - don't want Gorges to be too powerful. Same as NS1.
    elseif targetEntity == player then
        health = health * 0.5
    end
    
    local amountHealed = targetEntity:AddHealth(health, true, false, false, player) --????Why was heal effect explicitly set to not show?!
    
    -- Do not count amount self healed.
    if targetEntity ~= player then
        player:AddContinuousScore("HealSpray", amountHealed, HealSprayMixin.kAmountHealedForPoints, HealSprayMixin.kHealScoreAdded)
    end
    
    if targetEntity.OnHealSpray then
        targetEntity:OnHealSpray(player)
    end
    
    -- Put out entities on fire sometimes.
    if HasMixin(targetEntity, "GameEffects") and math.random() < kSprayDouseOnFireChance then
        targetEntity:SetGameEffectMask(kGameEffect.OnFire, false)
    end
    
    -- If the entity has maturity, take off some of the remaining maturity time.
    local shouldAddMaturity = 
        Server and 
        HasMixin(targetEntity, "Maturity") and 
        HasMixin(targetEntity, "Live") and 
        targetEntity:GetIsAlive() and 
        HasMixin(targetEntity, "Construct") and 
        targetEntity:GetIsBuilt()
        
    if shouldAddMaturity then
        targetEntity:AddMaturity(HealSprayMixin.kMaturityTimeSkipped)
    end
    
    if Server and targetEntity:isa("Embryo") then
        targetEntity:AddEvolutionTime(HealSprayMixin.kEvolutionTimeAdded)
    end
    
end

local GetHealOrigin = debug.getupvaluex(HealSprayMixin.OnTag, "GetHealOrigin")

local PerformHealSpray = debug.getupvaluex(HealSprayMixin.OnTag, "PerformHealSpray")
debug.setupvaluex(PerformHealSpray, "HealEntity", HealEntity)


