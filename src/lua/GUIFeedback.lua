
-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\GUIFeedback.lua
--
-- Created by: Brian Cronin (brianc@unknownworlds.com)
--
-- Manages the feedback text.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

class 'GUIFeedback' (GUIScript)

function GUIFeedback:OnResolutionChanged(oldX, oldY, newX, newY)
    self:Uninitialize()
    self:Initialize()
end

function GUIFeedback:Initialize()

    self.buildText = GUIManager:CreateTextItem()
    self.buildText:SetScale(GetScaledVector())
    self.buildText:SetFontName(Fonts.kAgencyFB_Tiny)
    GUIMakeFontScale(self.buildText)
    self.buildText:SetAnchor(GUIItem.Left, GUIItem.Top)
    self.buildText:SetTextAlignmentX(GUIItem.Align_Min)
    self.buildText:SetTextAlignmentY(GUIItem.Align_Center)
    self.buildText:SetPosition(GUIScale(Vector(3, 8, 0)))
    self.buildText:SetColor(Color(1.0, 1.0, 1.0, 0.5))
    self.buildText:SetFontIsBold(true)
    self.buildText:SetText(Locale.ResolveString("BETA_MAINMENU") .. tostring(Shared.GetBuildNumber()))
    
	local oldText = self.buildText:GetText()
    local newText = oldText .. " - CommunityBalanceMod v" .. g_communityBalanceModConfig.revision
    if g_communityBalanceModConfig.build_tag then
        newText = newText .. " (" .. g_communityBalanceModConfig.build_tag .. ")"
    end
	self.buildText:SetText(newText)
end

function GUIFeedback:Uninitialize()

    if self.buildText then
        GUI.DestroyItem(self.buildText)
        self.buildText = nil
    end
    
end