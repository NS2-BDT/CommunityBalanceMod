Log("Loading new BlightMixin.lua for NS2 Balance Beta mod.")

-- ======= Copyright (c) 2003-2020, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\BlightMixin.lua
--
--    Created by:   Darrell Gentry (darrell@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

BlightMixin = CreateMixin( BlightMixin )
BlightMixin.type = "BlightAble"

BlightMixin.expectedMixins =
{
    Live = "BlightMixin makes only sense if this entity can take damage (has LiveMixin).",
}

BlightMixin.optionalCallbacks =
{
    GetCanBeBlightedOverride = "Return true or false if the entity has some specific conditions under which the blight effect is allowed."
}

BlightMixin.networkVars =
{
    blighted = "boolean",
    timeBlighted = "time",
    blightDuration = "private float (0 to 45 by 0.1)"
}

function BlightMixin:__initmixin()

    PROFILE("BlightMixin:__initmixin")

    self.timeBlighted = 0
    self.blightDuration = 0
    self.blighted = false

end

function BlightMixin:GetBlightPercentageRemaining()

    local percentLeft = 0

    if self.blighted and self.blightDuration > 0 then
        percentLeft = Clamp( math.abs( (self.timeBlighted + self.blightDuration) - Shared.GetTime() ) / self.blightDuration, 0.0, 1.0 )
    end

    return percentLeft

end

function BlightMixin:SetBlighted( duration )

    if Server then

        if not self.GetCanBeBlightedOverride or self:GetCanBeBlightedOverride() then

            if duration == nil or type(duration) ~= "number" then
                error("duration is required and needs to be a number!")
                return
            end

            local blightTimeChanged = false

            if self.blighted and self.timeBlighted + duration >= self.timeBlighted + self.blightDuration then

                self.blightDuration = duration
                blightTimeChanged = true

            elseif not self.blighted then

                self.blightDuration = duration

                if self.OnBlighted then
                    self:OnBlighted()
                end

                blightTimeChanged = true
            end

            if blightTimeChanged then
                self.timeBlighted = Shared.GetTime()
                self.blighted = true
            end

        end

    end

end

function BlightMixin:TransferBlight(from)

    self.blightDuration = from.blightDuration
    self.timeBlighted = from.timeBlighted
    self.blighted = from.blighted

    if self.OnBlighted and not self.blighted then
        self:OnBlighted()
    end

end

if Server then

    function BlightMixin:OnKill()
        self:RemoveBlight()
    end

end

function BlightMixin:GetIsBlighted()
    return self.blighted
end

function BlightMixin:RemoveBlight()
    self.blighted = false
    self.blightDuration = 0
end

local function SharedUpdate(self)

    if Server then

        if not self.blighted then
            return
        end

        -- See if blighted time is over
        if self.blightDuration > 0 and self.timeBlighted + self.blightDuration <= Shared.GetTime() then

            self:RemoveBlight()

            if self.OnBlightRemoved then
                self:OnBlightRemoved()
            end

        end

    end

end

function BlightMixin:OnUpdate(_)
    SharedUpdate(self)
end

function BlightMixin:OnProcessMove(_)
    SharedUpdate(self)
end
