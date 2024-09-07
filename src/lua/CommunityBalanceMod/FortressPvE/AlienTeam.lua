
-- Fortress PvE
function AlienTeam:InitTechTree()

    PlayingTeam.InitTechTree(self)

    -- Add special alien menus
    self.techTree:AddMenu(kTechId.MarkersMenu)
    self.techTree:AddMenu(kTechId.UpgradesMenu)
    self.techTree:AddMenu(kTechId.ShadePhantomMenu)
    self.techTree:AddMenu(kTechId.ShadePhantomStructuresMenu)
    self.techTree:AddMenu(kTechId.ShiftEcho, kTechId.None) --Fortress, removed requirement
    self.techTree:AddMenu(kTechId.LifeFormMenu)
    self.techTree:AddMenu(kTechId.SkulkMenu)
    self.techTree:AddMenu(kTechId.GorgeMenu)
    self.techTree:AddMenu(kTechId.LerkMenu)
    self.techTree:AddMenu(kTechId.FadeMenu)
    self.techTree:AddMenu(kTechId.OnosMenu)
    self.techTree:AddMenu(kTechId.Return)

    self.techTree:AddOrder(kTechId.Grow)
    self.techTree:AddAction(kTechId.FollowAlien)

    self.techTree:AddPassive(kTechId.Infestation)
    self.techTree:AddPassive(kTechId.SpawnAlien)
    self.techTree:AddPassive(kTechId.CollectResources, kTechId.Harvester)

    -- Add markers (orders)
    self.techTree:AddSpecial(kTechId.ThreatMarker, kTechId.None, kTechId.None, true)
    self.techTree:AddSpecial(kTechId.LargeThreatMarker, kTechId.None, kTechId.None, true)
    self.techTree:AddSpecial(kTechId.NeedHealingMarker, kTechId.None, kTechId.None, true)
    self.techTree:AddSpecial(kTechId.WeakMarker, kTechId.None, kTechId.None, true)
    self.techTree:AddSpecial(kTechId.ExpandingMarker, kTechId.None, kTechId.None, true)

    -- bio mass levels (required to unlock new abilities)
    self.techTree:AddSpecial(kTechId.BioMassOne)
    self.techTree:AddSpecial(kTechId.BioMassTwo)
    self.techTree:AddSpecial(kTechId.BioMassThree)
    self.techTree:AddSpecial(kTechId.BioMassFour)
    self.techTree:AddSpecial(kTechId.BioMassFive)
    self.techTree:AddSpecial(kTechId.BioMassSix)
    self.techTree:AddSpecial(kTechId.BioMassSeven)
    self.techTree:AddSpecial(kTechId.BioMassEight)
    self.techTree:AddSpecial(kTechId.BioMassNine)
    self.techTree:AddSpecial(kTechId.BioMassTen)
    self.techTree:AddSpecial(kTechId.BioMassEleven)
    self.techTree:AddSpecial(kTechId.BioMassTwelve)

    -- Commander abilities
    self.techTree:AddBuildNode(kTechId.Cyst)
    self.techTree:AddBuildNode(kTechId.NutrientMist)
    self.techTree:AddBuildNode(kTechId.Rupture, kTechId.BioMassTwo)
    self.techTree:AddBuildNode(kTechId.BoneWall, kTechId.BioMassThree)
    self.techTree:AddBuildNode(kTechId.Contamination, kTechId.BioMassTwelve)
    self.techTree:AddAction(kTechId.SelectDrifter)
    self.techTree:AddAction(kTechId.SelectHallucinations, kTechId.ShadeHive)
    self.techTree:AddAction(kTechId.SelectShift, kTechId.None) --Fortress, removed requirement

    -- Count consume like an upgrade so we can have multiples
    self.techTree:AddUpgradeNode(kTechId.Consume, kTechId.None, kTechId.None)

    -- Drifter triggered abilities
    self.techTree:AddTargetedActivation(kTechId.EnzymeCloud,      kTechId.ShiftHive,      kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.Hallucinate,      kTechId.ShadeHive,      kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.MucousMembrane,   kTechId.CragHive,      kTechId.None)
    --self.techTree:AddTargetedActivation(kTechId.Storm,            kTechId.ShiftHive,       kTechId.None)
    self.techTree:AddActivation(kTechId.DestroyHallucination)
    self.techTree:AddActivation(kTechId.HallucinateRandom)
    self.techTree:AddTargetedActivation(kTechId.HallucinateCloning)

    -- Cyst passives
    self.techTree:AddPassive(kTechId.CystCamouflage, kTechId.ShadeHive,      kTechId.None)
    self.techTree:AddPassive(kTechId.CystCelerity, kTechId.ShiftHive,      kTechId.None)
    self.techTree:AddPassive(kTechId.CystCarapace, kTechId.CragHive,      kTechId.None)

    -- Drifter passive abilities
    self.techTree:AddPassive(kTechId.DrifterCamouflage, kTechId.ShadeHive,      kTechId.None)
    self.techTree:AddPassive(kTechId.DrifterCelerity, kTechId.ShiftHive,      kTechId.None)
    self.techTree:AddPassive(kTechId.DrifterRegeneration, kTechId.CragHive,      kTechId.None)

    -- Hive types
    self.techTree:AddBuildNode(kTechId.Hive,                    kTechId.None,           kTechId.None)
    self.techTree:AddPassive(kTechId.HiveHeal)
    self.techTree:AddBuildNode(kTechId.CragHive,                kTechId.Hive,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.ShadeHive,               kTechId.Hive,                kTechId.None)
    self.techTree:AddBuildNode(kTechId.ShiftHive,               kTechId.Hive,                kTechId.None)

    self.techTree:AddTechInheritance(kTechId.Hive, kTechId.CragHive)
    self.techTree:AddTechInheritance(kTechId.Hive, kTechId.ShiftHive)
    self.techTree:AddTechInheritance(kTechId.Hive, kTechId.ShadeHive)

    self.techTree:AddUpgradeNode(kTechId.ResearchBioMassOne)
    self.techTree:AddUpgradeNode(kTechId.ResearchBioMassTwo)
    self.techTree:AddUpgradeNode(kTechId.ResearchBioMassThree)
    self.techTree:AddUpgradeNode(kTechId.ResearchBioMassFour)

    self.techTree:AddUpgradeNode(kTechId.UpgradeToCragHive,     kTechId.Hive,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToShadeHive,    kTechId.Hive,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToShiftHive,    kTechId.Hive,                kTechId.None)

    self.techTree:AddBuildNode(kTechId.Harvester)
    self.techTree:AddBuildNode(kTechId.DrifterEgg)
    self.techTree:AddBuildNode(kTechId.Drifter, kTechId.None, kTechId.None, true)

    -- Whips
    self.techTree:AddBuildNode(kTechId.Whip,                      kTechId.None,                kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.EvolveBombard,             kTechId.None,                kTechId.None)

    self.techTree:AddPassive(kTechId.WhipBombard)
    self.techTree:AddPassive(kTechId.Slap)
    self.techTree:AddActivation(kTechId.WhipUnroot)
    self.techTree:AddActivation(kTechId.WhipRoot)

    -- Tier 1 lifeforms
    self.techTree:AddAction(kTechId.Skulk,                     kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Gorge,                     kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Lerk,                      kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Fade,                      kTechId.None,                kTechId.None)
    self.techTree:AddAction(kTechId.Onos,                      kTechId.None,                kTechId.None)
    self.techTree:AddBuyNode(kTechId.Egg,                      kTechId.None,                kTechId.None)

    self.techTree:AddUpgradeNode(kTechId.GorgeEgg, kTechId.BioMassTwo)
    self.techTree:AddUpgradeNode(kTechId.LerkEgg, kTechId.BioMassFour)
    self.techTree:AddUpgradeNode(kTechId.FadeEgg, kTechId.BioMassEight)
    self.techTree:AddUpgradeNode(kTechId.OnosEgg, kTechId.BioMassNine)

    -- Special alien structures. These tech nodes are modified at run-time, depending when they are built, so don't modify prereqs.
    self.techTree:AddBuildNode(kTechId.Crag,                      kTechId.Hive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.Shift,                     kTechId.Hive,          kTechId.None)
    self.techTree:AddBuildNode(kTechId.Shade,                     kTechId.Hive,          kTechId.None)


    
    --Fortress
    self.techTree:AddBuildNode(kTechId.FortressCrag,               kTechId.Crag,        kTechId.None)
    self.techTree:AddPassive(kTechId.FortressCragAbility,                kTechId.FortressCrag,          kTechId.CragHive)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressCrag,  kTechId.Crag)

    self.techTree:AddBuildNode(kTechId.FortressShift,               kTechId.Shift,        kTechId.None)
    self.techTree:AddPassive(kTechId.FortressShiftAbility,                kTechId.FortressShift,          kTechId.ShiftHive)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressShift,  kTechId.Shift)

    self.techTree:AddBuildNode(kTechId.FortressShade,               kTechId.Shade,        kTechId.None)
    self.techTree:AddActivation(kTechId.ShadeHallucination,                kTechId.FortressShade,          kTechId.ShadeHive)
	--self.techTree:AddPassive(kTechId.ShadeSonar,                kTechId.FortressShade,          kTechId.ShadeHive)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressShade,  kTechId.Shade)

    self.techTree:AddBuildNode(kTechId.FortressWhip,               kTechId.Whip,        kTechId.None)
    self.techTree:AddActivation(kTechId.WhipAbility,               kTechId.None,          kTechId.None)
    self.techTree:AddActivation(kTechId.FortressWhipAbility,                kTechId.FortressWhip,          kTechId.None)
    self.techTree:AddUpgradeNode(kTechId.UpgradeToFortressWhip,  kTechId.Whip)
    

    -- Alien upgrade structure
    self.techTree:AddBuildNode(kTechId.Shell, kTechId.CragHive)
    self.techTree:AddSpecial(kTechId.TwoShells, kTechId.Shell)
    self.techTree:AddSpecial(kTechId.ThreeShells, kTechId.TwoShells)

    self.techTree:AddBuildNode(kTechId.Veil, kTechId.ShadeHive)
    self.techTree:AddSpecial(kTechId.TwoVeils, kTechId.Veil)
    self.techTree:AddSpecial(kTechId.ThreeVeils, kTechId.TwoVeils)

    self.techTree:AddBuildNode(kTechId.Spur, kTechId.ShiftHive)
    self.techTree:AddSpecial(kTechId.TwoSpurs, kTechId.Spur)
    self.techTree:AddSpecial(kTechId.ThreeSpurs, kTechId.TwoSpurs)


    -- personal upgrades (all alien types)
    self.techTree:AddBuyNode(kTechId.Vampirism, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Carapace, kTechId.Shell, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Regeneration, kTechId.Shell, kTechId.None, kTechId.AllAliens)

    self.techTree:AddBuyNode(kTechId.Focus, kTechId.Veil, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Aura, kTechId.Veil, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Camouflage, kTechId.Veil, kTechId.None, kTechId.AllAliens)

    self.techTree:AddBuyNode(kTechId.Crush, kTechId.Spur, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Celerity, kTechId.Spur, kTechId.None, kTechId.AllAliens)
    self.techTree:AddBuyNode(kTechId.Adrenaline, kTechId.Spur, kTechId.None, kTechId.AllAliens)


    -- Crag
    self.techTree:AddPassive(kTechId.CragHeal)
    --self.techTree:AddActivation(kTechId.HealWave,                kTechId.CragHive,          kTechId.None)
    self.techTree:AddActivation(kTechId.HealWave,                kTechId.None,          kTechId.None) --Fortress, removed requirement

    -- Shift
    self.techTree:AddActivation(kTechId.ShiftHatch,               kTechId.None,         kTechId.None)
    self.techTree:AddPassive(kTechId.ShiftEnergize,               kTechId.None,         kTechId.None)


    self.techTree:AddTargetedActivation(kTechId.TeleportHydra,       kTechId.ShiftHive,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportWhip,        kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportTunnel,      kTechId.ShiftHive,         kTechId.None)
    self.techTree:AddTargetedActivation(kTechId.TeleportCrag,        kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportShade,       kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportShift,       kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportVeil,        kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportSpur,        kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportShell,       kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportHive,        kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportEgg,         kTechId.None,         kTechId.None) --Fortress, removed requirement
    self.techTree:AddTargetedActivation(kTechId.TeleportHarvester,   kTechId.None,         kTechId.None) --Fortress, removed requirement

    -- Shade
    self.techTree:AddPassive(kTechId.ShadeDisorient)
    self.techTree:AddPassive(kTechId.ShadeCloak)
    self.techTree:AddActivation(kTechId.ShadeInk,                 kTechId.None,         kTechId.None) --Fortress, removed requirement

    self.techTree:AddSpecial(kTechId.TwoHives)
    self.techTree:AddSpecial(kTechId.ThreeHives)

    self.techTree:AddSpecial(kTechId.TwoWhips)
    self.techTree:AddSpecial(kTechId.TwoShifts)
    self.techTree:AddSpecial(kTechId.TwoShades)
    self.techTree:AddSpecial(kTechId.TwoCrags)

    -- Tunnel
    self.techTree:AddBuildNode(kTechId.TunnelExit)
    self.techTree:AddBuildNode(kTechId.TunnelRelocate)
    self.techTree:AddActivation(kTechId.TunnelCollapse)

    --self.techTree:AddBuildNode(kTechId.InfestedTunnel)
    --self.techTree:AddUpgradeNode(kTechId.UpgradeToInfestedTunnel)

    self.techTree:AddAction(kTechId.BuildTunnelMenu)

    self.techTree:AddBuildNode(kTechId.BuildTunnelEntryOne)
    self.techTree:AddBuildNode(kTechId.BuildTunnelEntryTwo)
    self.techTree:AddBuildNode(kTechId.BuildTunnelEntryThree)
    self.techTree:AddBuildNode(kTechId.BuildTunnelEntryFour)
    self.techTree:AddBuildNode(kTechId.BuildTunnelExitOne)
    self.techTree:AddBuildNode(kTechId.BuildTunnelExitTwo)
    self.techTree:AddBuildNode(kTechId.BuildTunnelExitThree)
    self.techTree:AddBuildNode(kTechId.BuildTunnelExitFour)
    self.techTree:AddAction(kTechId.SelectTunnelEntryOne)
    self.techTree:AddAction(kTechId.SelectTunnelEntryTwo)
    self.techTree:AddAction(kTechId.SelectTunnelEntryThree)
    self.techTree:AddAction(kTechId.SelectTunnelEntryFour)
    self.techTree:AddAction(kTechId.SelectTunnelExitOne)
    self.techTree:AddAction(kTechId.SelectTunnelExitTwo)
    self.techTree:AddAction(kTechId.SelectTunnelExitThree)
    self.techTree:AddAction(kTechId.SelectTunnelExitFour)

    -- abilities unlocked by bio mass:

    -- skulk researches
    self.techTree:AddResearchNode(kTechId.Leap,              kTechId.BioMassFour, kTechId.None, kTechId.AllAliens)
    self.techTree:AddResearchNode(kTechId.Xenocide,          kTechId.BioMassNine, kTechId.None, kTechId.AllAliens)

    -- gorge researches
    self.techTree:AddBuyNode(kTechId.BabblerAbility,        kTechId.None)
    self.techTree:AddPassive(kTechId.WebTech,            kTechId.None) --, kTechId.None, kTechId.AllAliens
    --FIXME Above still shows in Alien-Comm buttons/menu
    self.techTree:AddBuyNode(kTechId.Web,                   kTechId.None)
    self.techTree:AddBuyNode(kTechId.BabblerEgg,            kTechId.None)
    self.techTree:AddResearchNode(kTechId.BileBomb,         kTechId.BioMassTwo, kTechId.None, kTechId.AllAliens)

    -- lerk researches
    self.techTree:AddResearchNode(kTechId.Umbra,               kTechId.BioMassSix, kTechId.None, kTechId.AllAliens)
    self.techTree:AddResearchNode(kTechId.Spores,              kTechId.BioMassSix, kTechId.None, kTechId.AllAliens)

    -- fade researches
    self.techTree:AddResearchNode(kTechId.MetabolizeEnergy,        kTechId.BioMassThree, kTechId.None, kTechId.AllAliens)
    self.techTree:AddResearchNode(kTechId.MetabolizeHealth,        kTechId.BioMassFive, kTechId.MetabolizeEnergy, kTechId.AllAliens)
    self.techTree:AddResearchNode(kTechId.Stab,              kTechId.BioMassSeven, kTechId.None, kTechId.AllAliens)

    -- onos researches
    self.techTree:AddPassive(kTechId.Charge)
    self.techTree:AddResearchNode(kTechId.BoneShield,        kTechId.BioMassSix, kTechId.None, kTechId.AllAliens)
    self.techTree:AddResearchNode(kTechId.Stomp,             kTechId.BioMassEight, kTechId.None, kTechId.AllAliens)

    -- gorge structures
    self.techTree:AddBuildNode(kTechId.Hydra)
    self.techTree:AddBuildNode(kTechId.Clog)

    self.techTree:SetComplete()

end
