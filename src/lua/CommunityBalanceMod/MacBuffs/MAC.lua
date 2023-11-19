
MAC.kMoveSpeed = 7 --6 (drifters are 11-13)

function MAC:OverrideVisionRadius()
    return 10
end


function MAC:GetCanBeWeldedOverride()
    return true -- self.lastTakenDamageTime + 1 < Shared.GetTime()
end