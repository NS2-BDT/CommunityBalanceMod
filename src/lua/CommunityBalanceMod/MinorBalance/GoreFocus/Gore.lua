-- actual attack animation graph durations
local kAttackDurationGore = Shared.GetAnimationLength("models/alien/onos/onos_view.model", "gore_attack") / 1.2
local kAttackDurationSmash = Shared.GetAnimationLength("models/alien/onos/onos_view.model", "smash") --/ 1.35


function Gore:GetAttackAnimationDuration()
    local attackType = self.attackType

    if Server then
        attackType = self.lastAttackType
    end

    if attackType == Gore.kAttackType.Smash then
        return kAttackDurationSmash
    else
        return kAttackDurationGore
    end
end
