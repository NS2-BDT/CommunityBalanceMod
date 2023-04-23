if Server then
    oldSetOnFire = UmbraMixin.SetOnFire
    function UmbraMixin:SetOnFire()
        -- CommunityBalanceMod
        -- Don't delete umbra on players when they're set on fire if we have Resilience at any shell level
        if self:isa("Player") and self:GetHasUpgrade(kTechId.Resilience) and self:GetShellLevel() > 0 then
            return
        end

        oldSetOnFire(self)
    end
end
