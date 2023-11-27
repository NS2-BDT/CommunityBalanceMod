
Script.Load("lua/CommunityBalanceMod/Scripts/GUIMenuBetaBalanceChangelogButton.lua")

function GUIMainMenu:CreateLinksButtons()

    -- Create wiki button.
    CreateGUIObject("wikiButton", GUIMenuWikiButton, self.linkButtonsHolder)

    -- Create a discord button.
    CreateGUIObject("wikiButton", GUIMenuDiscordButton, self.linkButtonsHolder)

    -- changelog button
    CreateGUIObject("changelogButton", GUIMenuBetaBalanceChangelogButton, self.linkButtonsHolder)

end

