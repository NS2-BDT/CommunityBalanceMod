Log("Loading new DoomMixin.lua for NS2 Balance Beta mod.")

-- ======= Copyright (c) 2003-2020, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\DoomMixin.lua
--
--    Created by:   Darrell Gentry (darrell@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

DoomMixin = CreateMixin( DoomMixin )
DoomMixin.type = "DoomAble"

DoomMixin.expectedMixins =
{
    Live = "DoomMixin makes only sense if this entity can take damage (has LiveMixin).",
}

DoomMixin.optionalCallbacks =
{
    GetCanBeDoomedOverride = "Return true or false if the entity has some specific conditions under which the doom effect is allowed."
}

DoomMixin.networkVars =
{
    doomed = "boolean",
    timeDoomed = "time",
    doomDuration = "private float (0 to 62 by 0.1)"
}

function DoomMixin:__initmixin()

    PROFILE("DoomMixin:__initmixin")

    self.timeDoomed = 0
    self.doomDuration = 0
    self.doomed = false

end

function DoomMixin:GetDoomPercentageRemaining()

    local percentLeft = 0

    if self.doomed and self.doomDuration > 0 then
        percentLeft = Clamp( math.abs( (self.timeDoomed + self.doomDuration) - Shared.GetTime() ) / self.doomDuration, 0.0, 1.0 )
    end

    return percentLeft

end

function DoomMixin:SetDoomed( duration )

    if Server then

        if not self.GetCanBeDoomedOverride or self:GetCanBeDoomedOverride() then

            if duration == nil or type(duration) ~= "number" then
                error("duration is required and needs to be a number!")
                return
            end

            local doomTimeChanged = false

            if self.doomed and self.timeDoomed + duration >= self.timeDoomed + self.doomDuration then

                self.doomDuration = duration
                doomTimeChanged = true

            elseif not self.doomed then

                self.doomDuration = duration

                if self.OnDoomed then
                    self:OnDoomed()
                end

                doomTimeChanged = true
            end

            if doomTimeChanged then
                self.timeDoomed = Shared.GetTime()
                self.doomed = true
            end

        end

    end

end

function DoomMixin:TransferDoom(from)

    self.doomDuration = from.doomDuration
    self.timeDoomed = from.timeDoomed
    self.doomed = from.doomed

    if self.OnDoomed and not self.doomed then
        self:OnDoomed()
    end

end

if Server then

    function DoomMixin:OnKill()
        self:RemoveDoom()
    end

end

function DoomMixin:GetIsDoomed()
    return self.doomed
end

function DoomMixin:RemoveDoom()
    self.doomed = false
    self.doomDuration = 0
end

local function SharedUpdate(self)

    if Server then

        if not self.doomed then
            return
        end

        -- See if doomed time is over
        if self.doomDuration > 0 and self.timeDoomed + self.doomDuration <= Shared.GetTime() then

            self:RemoveDoom()

            if self.OnDoomRemoved then
                self:OnDoomRemoved()
            end

        end

    end

end

function DoomMixin:OnUpdate(_)
    SharedUpdate(self)
end

function DoomMixin:OnProcessMove(_)
    SharedUpdate(self)
end
