-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================



Shell.kRegenHealRate = 0.01


function Shell:OnUpdate(deltaTime)

    if Server then

        self.hasRegeneration = not self:GetIsInCombat() and self:GetIsBuilt()

        if self.hasRegeneration then

            if self:GetIsHealable() and ( not self.timeLastAlienAutoHeal or self.timeLastAlienAutoHeal + kAlienRegenerationTime <= Shared.GetTime() ) then

                self:AddHealth(self.kRegenHealRate * self:GetMaxHealth())
                self.timeLastAlienAutoHeal = Shared.GetTime()

            end

        end
    end

end

