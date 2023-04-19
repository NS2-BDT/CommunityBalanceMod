local kCommunityBalanceModRevisionKey = "communitybalancemod_revision"
local kChangeLogTitle = "BDT Community Balance Mod"
local kChangeLogURL = "https://ns2-bdt.github.io/CommunityBalanceMod"
local kChangeLogDetailURL = "https://ns2-bdt.github.io/CommunityBalanceMod/changelog.html"

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
