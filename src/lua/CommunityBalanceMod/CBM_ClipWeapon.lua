local networkVars =
{
    deployed = "compensated boolean",
    
    clip = "compensated integer (0 to 200)",
    
    timeAttackEnded = "compensated time",
    
    lastTimeSprinted = "compensated time",
    
}

function ClipWeapon:GetIsPrimaryAttackAllowed(player)

    if not player then
        return false
    end    

    local sprintedRecently = (Shared.GetTime() - self.lastTimeSprinted) < kMaxTimeToSprintAfterAttack
    local attackAllowed = (not self:GetPrimaryAttackRequiresPress() or not player:GetPrimaryAttackLastFrame())
    attackAllowed = attackAllowed and (not self:GetIsReloading() or self:GetPrimaryCanInterruptReload())
    
    -- Note: the minimum fire delay is the time from when the weapon fired until it can start to attack again.
    -- For weapons that fire immediately upon press, this is the same as ROF. For weapons with a delay from start
    -- of attack until actual attack ... it is not.
    if attackAllowed and self.GetPrimaryMinFireDelay then
        attackAllowed = (Shared.GetTime() - self.timeAttackFired) >= self:GetPrimaryMinFireDelay()
        
        if not attackAllowed and self.OnMaxFireRateExceeded then
            self:OnMaxFireRateExceeded()
        end
        
    end
    
    return self:GetIsDeployed() and not sprintedRecently and attackAllowed

end

Shared.LinkClassToMap("ClipWeapon", ClipWeapon.kMapName, networkVars, true)