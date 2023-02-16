local kCommunityBalanceModRevisionKey = "communitybalancemod_revision"
local kCommunityBalanceModBetaRevisionKey = "communitybalancemod_betarevision"
local kChangeLogTitle = "NSL Competitive Mod"
local kChangeLogURL = "https://adsfgg.github.io/CommunityBalanceMod/changelog"
local kChangeLogDetailURL = "https://adsfgg.github.io/CommunityBalanceMod/revisions/revision" .. g_communityBalanceModRevision .. ".html"
local kBetaChangeLogURL = "https://adsfgg.github.io/CommunityBalanceMod-Beta/changelog"
local kBetaChangeLogDetailURL = string.format("https://adsfgg.github.io/CommunityBalanceMod-Beta/revisions/revision%sb%s.html", g_communityBalanceModRevision, g_communityBalanceModBeta)

local function showChangeLog(withDetail)
    withDetail = withDetail or false
    local url
    local isBeta = g_communityBalanceModBeta > 0
    if withDetail then
        if isBeta then
            url = kBetaChangeLogDetailURL
        else
            url = kChangeLogDetailURL
        end
    else
        if isBeta then
            url = kBetaChangeLogURL
        else
            url = kChangeLogURL
        end
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
    local oldBetaRevision = Client.GetOptionInteger(kCommunityBalanceModBetaRevisionKey, -1)
    if g_communityBalanceModRevision > oldRevision or (g_communityBalanceModBeta > 0 and g_communityBalanceModRevision == oldRevision and g_communityBalanceModBeta > oldBetaRevision) then
        Client.SetOptionInteger(kCommunityBalanceModRevisionKey, g_communityBalanceModRevision)
        Client.SetOptionInteger(kCommunityBalanceModBetaRevisionKey, g_communityBalanceModBeta)
        showChangeLog(true)
    end
end

Event.Hook("Console_changelog", showChangeLog)
