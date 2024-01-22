-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


Script.Load("lua/CommunityBalanceMod/Others/Scripts/GUIMenuBetaBalanceChangelogButton.lua")


local oldGUIMainMenuCreateLinksButtons = GUIMainMenu.CreateLinksButtons
function GUIMainMenu:CreateLinksButtons()

    oldGUIMainMenuCreateLinksButtons(self)

    -- changelog button
    CreateGUIObject("changelogButton", GUIMenuBetaBalanceChangelogButton, self.linkButtonsHolder)
end

