-- ========= Community Balance Mod ===============================
--
-- lua\Globals.lua
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================

local kSmokeTexture = PrecacheAsset("ui/alien_hud_health_smoke.dds")
local kBackgroundNoiseTexture = PrecacheAsset("ui/alien_commander_bg_smoke.dds")

local UpdateNotifications = debug.getupvaluex(GUIAlienHUD.Update, "UpdateNotifications" )
local  UpdateHealthBall = debug.getupvaluex(GUIAlienHUD.Update, "UpdateHealthBall" )
local UpdateEnergyBall = debug.getupvaluex(GUIAlienHUD.Update, "UpdateEnergyBall" )
local UpdateBabblerIndication = debug.getupvaluex(GUIAlienHUD.Update, "UpdateBabblerIndication" )
local UpdateMucousBall = debug.getupvaluex(GUIAlienHUD.Update, "UpdateMucousBall" )



function GUIAlienHUD:Update(deltaTime)

    PROFILE("GUIAlienHUD:Update")

    local newHudMode = Client.GetHudDetail()
    local fullMode = newHudMode == kHUDMode.Full

    if self.cachedHudDetail ~= newHudMode then

        self.cachedHudDetail = newHudMode
        local minimal = self.cachedHudDetail == kHUDMode.Minimal

        self.secondaryAbilityBackground:SetTexture(ConditionalValue(minimal, "ui/transparent.dds", kSmokeTexture))
        self.healthBall:GetBackground():SetAdditionalTexture("noise", ConditionalValue(minimal, "ui/transparent.dds", kBackgroundNoiseTexture))
        self.energyBall:GetBackground():SetAdditionalTexture("noise", ConditionalValue(minimal, "ui/transparent.dds", kBackgroundNoiseTexture))

        self:Reset()
    end

    -- update resource display
    self.resourceDisplay:Update(deltaTime, { PlayerUI_GetTeamResources(), PlayerUI_GetPersonalResources(), CommanderUI_GetTeamHarvesterCount() } )
    
    -- updates animations
    GUIAnimatedScript.Update(self, deltaTime)
    
    UpdateNotifications(self, deltaTime)
    
    self.inventoryDisplay:Update(deltaTime, { PlayerUI_GetActiveWeaponTechId(), PlayerUI_GetInventoryTechIds() })

    -- Update player status icons
    local playerStatusIcons = {
        Detected = PlayerUI_GetIsDetected(),
        Enzymed = PlayerUI_GetIsEnzymed(),
        Stormed = PlayerUI_GetIsStormed(),
        MucousedState = PlayerUI_GetPlayerMucousShieldState(),
        MucousedTime = PlayerUI_GetMucousShieldTimeRemaining(),
        Cloaked = PlayerUI_GetIsCloaked(),
        OnFire = PlayerUI_GetIsOnFire(),
        Electrified = PlayerUI_GetIsElectrified(),
        WallWalking = PlayerUI_GetIsWallWalking(),
        Umbra = PlayerUI_GetHasUmbra(),
        Energize = PlayerUI_GetEnergizeLevel(),
        CragRange = PlayerUI_WithinCragRange(),
        NerveGas = PlayerUI_InGasGrenadeCloud(),
    }

    self.statusDisplays:Update(deltaTime, playerStatusIcons, fullMode)

    -- The resource display was modifying the update interval for the script, so this block will run last
    -- This way we can also update the display rate in case it's set to low after an animation finishes
    UpdateHealthBall(self, deltaTime)
    UpdateEnergyBall(self, deltaTime)
    UpdateBabblerIndication(self, deltaTime)
    UpdateMucousBall(self, deltaTime)

    if self.gameTime:GetIsVisible() then
        self.gameTime:SetText(PlayerUI_GetGameTimeString())
    end

    if self.teamResText:GetIsVisible() then
        self.teamResText:SetText(string.format(Locale.ResolveString("TEAM_RES"), math.floor(ScoreboardUI_GetTeamResources(kTeam2Index))))
    end
    
end