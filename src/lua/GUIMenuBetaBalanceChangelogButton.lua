-- ====**** Scripts\GUIMenuBetaBalanceChangelogButton.lua ****====
-- ======= Copyright (c) 2021, Unknown Worlds Entertainment, Inc. All rights reserved. =============
--
-- lua/Changelog/GUIMenuBetaBalanceChangelogButton.lua
--
--    Created by:  Darrell Gentry (darrell@naturalselection2.com)
--
--    Button that opens the balance mod's changelog.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

Script.Load("lua/menu2/GUIMenuExitButton.lua")
Script.Load("lua/menu2/wrappers/Tooltip.lua")

Script.Load("lua/GUIBetaBalanceChangelog.lua")
Script.Load("lua/GUIBetaBalanceChangelogData.lua")

local kBalanceChangelogViewedOptionKey = "beta_balance_mod/lastVersionViewed"

---@class GUIMenuBetaBalanceChangelogButton : GUIMenuExitButton
local baseClass = GUIMenuExitButton
baseClass = GetTooltipWrappedClass(baseClass)
class "GUIMenuBetaBalanceChangelogButton" (baseClass)

GUIMenuBetaBalanceChangelogButton.kTextureRegular = PrecacheAsset("ui/newMenu/balance_icon.dds")
GUIMenuBetaBalanceChangelogButton.kTextureHover   = PrecacheAsset("ui/newMenu/balance_icon_hover.dds")

GUIMenuBetaBalanceChangelogButton.kShadowScale = Vector(10, 5, 1)

GUIMenuBetaBalanceChangelogButton:AddClassProperty("WantsAttention", false)

function GUIMenuBetaBalanceChangelogButton:OnPressed()
    self.changelog:Open()
end

function GUIMenuBetaBalanceChangelogButton:Initialize(params, errorDepth)
    errorDepth = (errorDepth or 1) + 1
    baseClass.Initialize(self, params, errorDepth)
    self:SetTooltip("Balance Changelog")

    self:SetGraphicsRotationOffset(Vector(0.67, 1, 0))

    self.changelog = CreateGUIObject("changelog", GUIBetaBalanceChangelog) -- Vanilla creates links before navbar, so we poll for it
    self.changelog:LoadChangelog(gChangelogData)
    self:HookEvent(self.changelog, "Opened", self.OnChangelogOpened)

    self:HookEvent(GetMainMenu(), "OnClosed", self.OnMainMenuClosed)
    self:HookEvent(self, "OnMouseOverChanged", self.OnMouseOverChanged)
    self:HookEvent(self, "OnAngleChanged", self.OnAngleChanged)
    self:HookEvent(self, "OnWantsAttentionChanged", self.OnWantsAttentionChanged)

    self.callback = self:AddTimedCallback(self.NavBarPollCallback, 0.5, true)

end


function GetBetaBalanceVersion()
    if g_communityBalanceModConfig.revision then
        return g_communityBalanceModConfig.revision
    else 
        return false
    end
end

function GUIMenuBetaBalanceChangelogButton:OnChangelogOpened()

    if not GetBetaBalanceVersion() or GetBetaBalanceVersion() == "0.0.0" then return end

    Client.SetOptionString(kBalanceChangelogViewedOptionKey, GetBetaBalanceVersion())
    self:SetWantsAttention(false)
    self:StopRockingAnimation()

end

local RockingAnimation =
{
    speed = 0.25,
    halfDistance = math.pi/20,

    func = function(obj, time, params, currentValue, startValue, endValue, startTime)
        local radsTraversed = time * params.speed
        local radianOneRange = params.halfDistance
        local range = radianOneRange - (-radianOneRange) -- max - min
        return math.abs(((radsTraversed + range) % (range * 2)) - range) - radianOneRange, false
    end
}

function GUIMenuBetaBalanceChangelogButton:SetGraphicsRotationOffset(rotationOffset)
    self.normalGraphic:SetRotationOffsetNormalized(rotationOffset)
    self.hoverGraphic:SetRotationOffsetNormalized(rotationOffset)
end

function GUIMenuBetaBalanceChangelogButton:OnAngleChanged()
    local angle = self:GetAngle()
    self.normalGraphic:SetAngle(angle)
    self.hoverGraphic:SetAngle(angle)
end

function GUIMenuBetaBalanceChangelogButton:OnMouseOverChanged()

    local isMouseOver = self:GetMouseOver()
    if isMouseOver then
        self:StartRockingAnimation()
    elseif not self:GetWantsAttention() then
        self:StopRockingAnimation()
    end

end

function GUIMenuBetaBalanceChangelogButton:StartRockingAnimation()
    self:AnimateProperty("Angle", 0, RockingAnimation)
end

function GUIMenuBetaBalanceChangelogButton:StopRockingAnimation()
    self:ClearPropertyAnimations("Angle")
    self:SetAngle(0)
end

function GUIMenuBetaBalanceChangelogButton:NavBarPollCallback()
    local navBar = GetNavBar()
    if not navBar then return end

    self.changelog:SetParent(navBar)
    self:MaybeOpenChangelog()

    self:RemoveTimedCallback(self.callback)
    self.callback = nil

end

local function GetIsVersionOlderThanCurrent(oldVersion)

    if not GetBetaBalanceVersion() then return true end

    local lastVersionUnits = string.Explode(oldVersion, "%.")
    local currentVersionUnits = string.Explode(GetBetaBalanceVersion(), "%.")
    local maxUnitPos = math.min(#lastVersionUnits, #currentVersionUnits)

    for i = 1, maxUnitPos do
        if tonumber(lastVersionUnits[i]) < tonumber(currentVersionUnits[i]) then
            return true
        end
    end

    return false

end

function GUIMenuBetaBalanceChangelogButton:MaybeOpenChangelog()
    local lastChangelogVerViewed = Client.GetOptionString(kBalanceChangelogViewedOptionKey, "0")
    self:SetWantsAttention(GetIsVersionOlderThanCurrent(lastChangelogVerViewed))
end

function GUIMenuBetaBalanceChangelogButton:OnWantsAttentionChanged()
    if self:GetWantsAttention() then
        self:StartRockingAnimation()
    else
        self:StopRockingAnimation()
    end
end

function GUIMenuBetaBalanceChangelogButton:OnMainMenuClosed()
    self.changelog:Close()
end

if Client then
    Event.Hook("Console_mpb_reset_changelog", function()
        Client.SetOptionString(kBalanceChangelogViewedOptionKey, "0")
    end)
end
