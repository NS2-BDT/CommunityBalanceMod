-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

local kChangeLogTitle = "BDT Community Balance Mod"

local function showChangeLog(withDetail)
    local changelog_url = g_communityBalanceModConfig.changelog_url
    local revision_changelog_url = g_communityBalanceModConfig.revision_changelog_url

    if not changelog_url and not revision_changelog_url then
        print("Warn: Not showing changelog because no URL exists")
        return
    end

    withDetail = withDetail or false
    local url
    if withDetail then
        url = revision_changelog_url
    else
        url = changelog_url
    end

    if Shine then
        Shine:OpenWebpage(url, kChangeLogTitle)
    elseif Client.GetIsSteamOverlayEnabled() then
        Client.ShowWebpage(url)
    else
        print("Warn: Couldn't open changelog because no webview is available")
    end
end

--[[

local oldOnInitLocalClient = Player.OnInitLocalClient
function Player:OnInitLocalClient()
    oldOnInitLocalClient(self)
    local kCommunityBalanceModRevisionKey = "communitybalancemod_"
    if g_communityBalanceModConfig.build_tag then
        kCommunityBalanceModRevisionKey = kCommunityBalanceModRevisionKey .. g_communityBalanceModConfig.build_tag .. "_"
    end
    kCommunityBalanceModRevisionKey = kCommunityBalanceModRevisionKey .. "_revision"

    local oldRevision = Client.GetOptionString(kCommunityBalanceModRevisionKey, "-1")
    if g_communityBalanceModConfig.revision > oldRevision then
        Client.SetOptionString(kCommunityBalanceModRevisionKey, g_communityBalanceModConfig.revision)
        showChangeLog(true)
    end
end
]]

Event.Hook("Console_changelog", showChangeLog)
