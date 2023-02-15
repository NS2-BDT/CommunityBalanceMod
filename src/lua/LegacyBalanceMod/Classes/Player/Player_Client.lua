local kLegacyBalanceModRevisionKey = "legacybalancemod_revision"
local kLegacyBalanceModBetaRevisionKey = "legacybalancemod_betarevision"
local kChangeLogTitle = "NSL Competitive Mod"
local kChangeLogURL = "https://adsfgg.github.io/LegacyBalanceMod/changelog"
local kChangeLogDetailURL = "https://adsfgg.github.io/LegacyBalanceMod/revisions/revision" .. g_legacyBalanceModRevision .. ".html"
local kBetaChangeLogURL = "https://adsfgg.github.io/LegacyBalanceMod-Beta/changelog"
local kBetaChangeLogDetailURL = string.format("https://adsfgg.github.io/LegacyBalanceMod-Beta/revisions/revision%sb%s.html", g_legacyBalanceModRevision, g_legacyBalanceModBeta)

local function showChangeLog(withDetail)
    withDetail = withDetail or false
    local url
    local isBeta = g_legacyBalanceModBeta > 0
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

    local oldRevision = Client.GetOptionInteger(kLegacyBalanceModRevisionKey, -1)
    local oldBetaRevision = Client.GetOptionInteger(kLegacyBalanceModBetaRevisionKey, -1)
    if g_legacyBalanceModRevision > oldRevision or (g_legacyBalanceModBeta > 0 and g_legacyBalanceModRevision == oldRevision and g_legacyBalanceModBeta > oldBetaRevision) then
        Client.SetOptionInteger(kLegacyBalanceModRevisionKey, g_legacyBalanceModRevision)
        Client.SetOptionInteger(kLegacyBalanceModBetaRevisionKey, g_legacyBalanceModBeta)
        showChangeLog(true)
    end
end

Event.Hook("Console_changelog", showChangeLog)
