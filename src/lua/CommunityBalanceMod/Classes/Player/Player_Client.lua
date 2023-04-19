local kCommunityBalanceModRevisionKey = "communitybalancemod_revision"
local kChangeLogTitle = "NSL Competitive Mod"
local kChangeLogURL = "https://ns2-bdt.github.io/CommunityBalanceMod/changelog"
local kChangeLogDetailURL = "https://ns2-bdt.github.io/CommunityBalanceMod/revisions/revision" .. g_communityBalanceModRevision .. ".html"

local function showChangeLog(withDetail)
    withDetail = withDetail or false
    local url
    if withDetail then
        url = kChangeLogDetailURL
    else
        url = kChangeLogURL
    end

    if Shine then
        Shine:OpenWebpage(url, kChangeLogTitle)
    elseif Client.GetIsSteamOverlayEnabled() then
        Client.ShowWebpage(url)
    else
        print("Warn: Couldn't open changelog because no webview is available")
    end
end

local oldOnInitLocalClient = Player.OnInitLocalClient
function Player:OnInitLocalClient()
    oldOnInitLocalClient(self)

    local oldRevision = Client.GetOptionInteger(kCommunityBalanceModRevisionKey, -1)
    if g_communityBalanceModRevision > oldRevision then
        Client.SetOptionInteger(kCommunityBalanceModRevisionKey, g_communityBalanceModRevision)
        showChangeLog(true)
    end
end

Event.Hook("Console_changelog", showChangeLog)
