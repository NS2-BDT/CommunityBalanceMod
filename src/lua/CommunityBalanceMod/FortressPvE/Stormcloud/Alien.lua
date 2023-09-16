
local networkVars =
{
    -- The alien energy used for all alien weapons and abilities (instead of ammo) are calculated
    -- from when it last changed with a constant regen added
    timeAbilityEnergyChanged = "compensated time",
    abilityEnergyOnChange = "compensated float (0 to " .. math.ceil(kAbilityMaxEnergy) .. " by 0.05 [] )",
    movementModiferState = "compensated boolean",
    oneHive = "private boolean",
    twoHives = "private boolean",
    threeHives = "private boolean",
    hasAdrenalineUpgrade = "boolean",
    enzymed = "boolean",
    silenceLevel = "integer (0 to 3)",
    electrified = "boolean",
    hatched = "private boolean",
    darkVisionSpectatorOn = "private boolean",
    isHallucination = "boolean",
    hallucinatedClientIndex = "integer",
    creationTime = "time",

    stormed = "boolean",
}

AddMixinNetworkVars(CloakableMixin, networkVars)
AddMixinNetworkVars(UmbraMixin, networkVars)
AddMixinNetworkVars(CatalystMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(EnergizeMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(DetectableMixin, networkVars)
AddMixinNetworkVars(StormCloudMixin, networkVars)
AddMixinNetworkVars(ScoringMixin, networkVars)
AddMixinNetworkVars(MucousableMixin, networkVars)
AddMixinNetworkVars(ShieldableMixin, networkVars)
AddMixinNetworkVars(GUINotificationMixin, networkVars)
AddMixinNetworkVars(PlayerStatusMixin, networkVars)

Shared.LinkClassToMap("Alien", Alien.kMapName, networkVars, true)


local oldAlienOnCreate = Alien.OnCreate
function Alien:OnCreate()
    oldAlienOnCreate(self)
    self.stormed = false     

    if Server then
            self.timeWhenStormExpires = 0                    
    end

end

          

function Alien:GetIsStormed()
    return self.stormed
end

function Alien:ClearStorm()
    local rval = (self.stormed == true)

    if Server then
        self.timeWhenStormExpires = 0 -- Expire with zero. Shared.GetTime at this point will cause harmonic oscillation under constant electrify effect
    end

    self.stormed = false

    return rval
end

      

