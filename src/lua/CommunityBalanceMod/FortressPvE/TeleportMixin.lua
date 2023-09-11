

function TeleportMixin:GetCanTeleport()

    local canTeleport = true
    if self.GetCanTeleportOverride then
        canTeleport = self:GetCanTeleportOverride()
    end

    --new
    if self:GetTechId() == kTechId.FortressShift 
        or self:GetTechId() == kTechId.FortressShade
        or self:GetTechId() == kTechId.FortressWhip
        or self:GetTechId() == kTechId.FortressCrag
    then 
        canTeleport = false 
    end
    
    return canTeleport and not self.isTeleporting
    
end
