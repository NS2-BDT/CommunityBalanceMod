


local oldInitialize = GUIFeedback.Initialize
function GUIFeedback:Initialize()
    oldInitialize(self)

    local oldText = self.buildText:GetText()
    local newText = oldText .. " - CommunityBalanceMod v" .. g_communityBalanceModConfig.revision
    if g_communityBalanceModConfig.build_tag then
        newText = newText .. " (" .. g_communityBalanceModConfig.build_tag .. ")"
    end

    self.buildText:SetText(newText)
end
