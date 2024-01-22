-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================



function GUIMenuPlayList:GetOptionDefsTable()
    return
    {

        {
            name = "serverBrowser",
            class = GUIMenuPlayListItem,
            params =
            {
                label = Locale.ResolveString("MENU_SERVER_BROWSER"),
            },
            callback = GUIMenuPlayList.OnServerBrowserClicked,
        },


        {
            name = "matchMaking",
            class = GUIMenuPlayListItem,
            params =
            {
                label = Locale.ResolveString("MENU_MATCHED_PLAY"),
                font = MenuStyle.kPlayMatchMakingFont,
            },
            postInit = function(createdObj)
                createdObj:SetEnabled(not Client.GetIsConnected())
            end,
            callback = GUIMenuPlayList.OnMatchMakingClicked,
        },

       
        {
            name = "matchMakingDivider",
            class = GUIObject,
            postInit = function(createdObj)
                local parentWidth = createdObj:GetParent():GetSize().x
                createdObj:SetSize(parentWidth * 0.7, 2)
                createdObj:AlignCenter()
                createdObj:SetColor(0.8, 0.8, 0.8)
            end,
        },

        {
            name = "training",
            class = GUIMenuPlayListItem,
            params =
            {
                label = Locale.ResolveString("MENU_TRAINING"),
            },
            callback = GUIMenuPlayList.OnTrainingClicked,
        },

        {
            name = "challenges",
            class = GUIMenuPlayListItem,
            params =
            {
                label = Locale.ResolveString("MENU_CHALLENGES"),
            },
            callback = GUIMenuPlayList.OnChallengesClicked,
        },
        
        {
            name = "startServer",
            class = GUIMenuPlayListItem,
            params =
            {
                label = Locale.ResolveString("MENU_START_LISTEN_SERVER"),
            },
            callback = GUIMenuPlayList.OnStartListenServerClicked,
        },
    }
end
