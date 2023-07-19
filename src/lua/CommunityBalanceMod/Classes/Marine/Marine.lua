local oldGetCanJump = Marine.GetCanJump
function Marine:GetCanJump()
    if HasMixin(self, "Webable") and self:GetIsWebbed() then
        return false
    end

    return oldGetCanJump(self)
end
