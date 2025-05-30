-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\CatPackMixin.lua
--
--    Created by:   Brian Arneson (samusdroid@gmail.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

CatPackMixin = CreateMixin( CatPackMixin )
CatPackMixin.type = "CatPack"

CatPackMixin.networkVars =
{
    catpackboost = "boolean",
    timeCatpackboost = "private compensated time",
}

function CatPackMixin:__initmixin()
    
    PROFILE("CatPackMixin:__initmixin")

    self.catpackboost = false
    self.timeCatpackboost = 0

end

function CatPackMixin:GetHasCatPackBoost()
    return self.catpackboost
end

function CatPackMixin:GetCatPackTimeRemaining()

    local percentLeft = 0

    if self.catpackboost then
        percentLeft = Clamp( math.abs( (self.timeCatpackboost + kCatPackDuration) - Shared.GetTime() ) / kCatPackDuration, 0.0, 1.0 )
    end

    return percentLeft

end

function CatPackMixin:OnProcessMove(input)
    if self.catpackboost then
        self.catpackboost = Shared.GetTime() - self.timeCatpackboost < kCatPackDuration
    end
end

function CatPackMixin:ApplyCatPack()
    if Server then
        self.catpackboost = true
        self.timeCatpackboost = Shared.GetTime()
    end
end

function CatPackMixin:GetCanUseCatPack()

    local enoughTimePassed = self.timeCatpackboost + kCatPackPickupDelay < Shared.GetTime()
    return not self.catpackboost or enoughTimePassed

end

function CatPackMixin:ClearCatPackMixin()
    
    if self:GetHasCatPackBoost() then
        self.catpackboost = false
    end
    
    if Client then
        self:_RemoveEffect()
    end

end