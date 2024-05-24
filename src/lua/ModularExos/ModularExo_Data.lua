kExoModuleCategories = enum {
 --   "PowerSupply",
    "Weapon",
    "Utility",
    "Ability",
}
-- The slots that modules go in
kExoModuleSlots = enum {
 --   "PowerSupply",
    "RightArm",
    "LeftArm",
    "Utility",
    "Ability",
}

-- Slot data
kExoModuleSlotsData = {
    --[kExoModuleSlots.PowerSupply] = {
    --      category = kExoModuleCategories.PowerSupply,
    --     required = true,
    -- },
    [kExoModuleSlots.LeftArm]  = {
        category = kExoModuleCategories.Weapon,
        required = true,
    },
    [kExoModuleSlots.RightArm] = {
        category = kExoModuleCategories.Weapon,
        required = true,
    },
    [kExoModuleSlots.Utility]  = {
        category = kExoModuleCategories.Utility,
        required = false,
    },
    [kExoModuleSlots.Ability]  = {
        category = kExoModuleCategories.Ability,
        required = false,
    },
}

-- Module types
kExoModuleTypes = enum {
    "None",
   -- "Power1",
    "Claw",
    --"Welder",
    "Shield",
    "Railgun",
    "Minigun",
    --"Flamethrower",
	"PlasmaLauncher",
    "Armor",
    "NanoRepair",
    "NanoShield",
    "Thrusters",
    --"PhaseModule",
    "CatPack",
    --"MarineStructureAbility"
}

-- Information to decide which model to use for weapon combos
kExoArmTypes = enum {
    "Claw",
    "Minigun",
    "Railgun",
	"PlasmaLauncher",
}

-- Module type data
kExoModuleTypesData = {
    
    -- Weapon modules
    [kExoModuleTypes.Claw]       = {
        category     = kExoModuleCategories.Weapon,
        powerCost    = 0,
        resourceCost = kClawCost,
        mapName      = Claw.kMapName,
        armType      = kExoArmTypes.Claw,
        weight       = kClawWeight,
        armorValue   = kClawArmor,
        leftArmOnly  = true
    },
    --[kExoModuleTypes.Welder] = {
    --    category = kExoModuleCategories.Weapon,
    --    powerCost = 0,
    --	resourceCost = kExoWelderCost,
    --    mapName = ExoWelder.kMapName,
    --    armType = kExoArmTypes.Railgun,
    --    weight = kExoWelderWeight,
    --	requiredTechId = Exo.ExoWelderTech
    --},
    [kExoModuleTypes.Minigun]    = {
        category       = kExoModuleCategories.Weapon,
        powerCost      = 0,
        resourceCost   = kMinigunCost,
        mapName        = Minigun.kMapName,
        armType        = kExoArmTypes.Minigun,
        weight         = kMinigunWeight,
        armorValue     = kMinigunArmor,
        requiredTechId = Exo.MinigunTech,
        leftArmOnly    = false
    },
    [kExoModuleTypes.Railgun]    = {
        category       = kExoModuleCategories.Weapon,
        powerCost      = 0,
        resourceCost   = kRailgunCost,
        mapName        = Railgun.kMapName,
        armType        = kExoArmTypes.Railgun,
        weight         = kRailgunWeight,
        armorValue     = kRailgunArmor,
        requiredTechId = Exo.RailgunTech,
        leftArmOnly    = false
    },
	[kExoModuleTypes.PlasmaLauncher]    = {
        category       = kExoModuleCategories.Weapon,
        powerCost      = 0,
        resourceCost   = kPlasmaLauncherCost,
        mapName        = PlasmaLauncher.kMapName,
        armType        = kExoArmTypes.PlasmaLauncher,
        weight         = kPlasmaLauncherWeight,
        armorValue     = kPlasmaLauncherArmor,
        requiredTechId = Exo.PlasmaLauncherTech,
        leftArmOnly    = false
    },
    --[kExoModuleTypes.Flamethrower] = {
    --    category = kExoModuleCategories.Weapon,
    --    powerCost = 0,
    --	resourceCost = kExoFlamerCost,
    --    mapName = ExoFlamer.kMapName,
    --    armType = kExoArmTypes.Railgun,
    --    weight = 0.12,
    --	requiredTechId = Exo.ExoFlamerTech
    --},
    --[kExoModuleTypes.Shield] = {
    --    category = kExoModuleCategories.Weapon,
    --    powerCost = 0,
    --	resourceCost = kExoShieldCost,
    --    mapName = ExoShield.kMapName,
    --    armType = kExoArmTypes.Claw,
    --    weight = kExoShieldWeight,
    --    armorValue     = kThrustersArmor,
    --	requiredTechId = Exo.ExoShieldTech,
    --    leftArmOnly  = true
    --},
    --[kExoModuleTypes.MarineStructureAbility] = {
    --    category = kExoModuleCategories.Weapon,
    --    powerCost = 0,
    --	resourceCost = kExoBuilderCost,
    --    mapName = MarineStructureAbility.kMapName,
    --    armType = kExoArmTypes.Claw,
    --    weight = kExoBuilderWeight,
    --},
    
    
    
    -- Utility modules
    [kExoModuleTypes.Thrusters]  = {
        category       = kExoModuleCategories.Utility,
        powerCost      = 0,
        resourceCost   = kThrustersCost,
        weight         = kThrustersWeight,
        armorValue     = kThrustersArmor,
        requiredTechId = Exo.ThrusterModuleTech
        
    },
    --	[kExoModuleTypes.PhaseModule] = {
    --    category = kExoModuleCategories.Utility,
    --    powerCost = 0,
    --	resourceCost = kPhaseModuleCost,
    --    weight = kPhaseModuleWeight,
    --	requiredTechId = Exo.PhaseModuleTech
    --
    --},
    [kExoModuleTypes.Armor]      = {
        category       = kExoModuleCategories.Utility,
        powerCost      = 0,
        resourceCost   = kArmorModuleCost,
        armorValue     = kArmorModuleArmor,
        weight         = kArmorModuleWeight,
        requiredTechId = Exo.ArmorModuleTech
        
    },
    [kExoModuleTypes.NanoRepair] = {
        category     = kExoModuleCategories.Utility,
        powerCost    = 0,
        resourceCost = kNanoModuleCost,
        weight       = kNanoRepairWeight,
        armorValue   = kNanoRepairArmor,
        
    },
    
    --[kExoModuleTypes.NanoShield] = {
    --    category     = kExoModuleCategories.Ability,
    --    powerCost    = 0,
    --    resourceCost = kExoNanoShieldCost,
    --    weight       = kNanoShieldWeight,
    --    
    --},
    --[kExoModuleTypes.CatPack]    = {
    --    category     = kExoModuleCategories.Ability,
    --    powerCost    = 0,
    --    resourceCost = kExoCatPackCost,
    --    weight       = kCatPackWeight,
    --    armorValue   = kCatPackArmor,
    --    
    --},
    
    [kExoModuleTypes.None]       = { },
}

-- Model data for weapon combos (data[rightArmType][leftArmType])
kExoWeaponRightLeftComboModels = {
    [kExoArmTypes.Minigun] = {
        isValid                = true,
        [kExoArmTypes.Minigun] = {
            isValid        = true,
            worldModel     = "models/marine/exosuit/exosuit_mm.model",
            worldAnimGraph = "models/marine/exosuit/exosuit_mm.animation_graph",
            viewModel      = "models/marine/exosuit/exosuit_mm_view.model",
            viewAnimGraph  = "models/marine/exosuit/exosuit_mm_view.animation_graph",
        },
        [kExoArmTypes.Railgun] = {
            isValid = false,
        },
		[kExoArmTypes.PlasmaLauncher] = {
            isValid = false,
        },
        [kExoArmTypes.Claw]    = {
            isValid        = true,
            worldModel     = "models/marine/exosuit/exosuit_cm.model",
            worldAnimGraph = "models/marine/exosuit/exosuit_cm.animation_graph",
            viewModel      = "models/marine/exosuit/exosuit_cm_view.model",
            viewAnimGraph  = "models/marine/exosuit/exosuit_cm_view.animation_graph",
        },
    },
    [kExoArmTypes.Railgun] = {
        isValid                = true,
        [kExoArmTypes.Minigun] = {
            isValid = false,
        },
        [kExoArmTypes.Railgun] = {
            isValid        = true,
            worldModel     = "models/marine/exosuit/exosuit_rr.model",
            worldAnimGraph = "models/marine/exosuit/exosuit_rr.animation_graph",
            viewModel      = "models/marine/exosuit/exosuit_rr_view.model",
            viewAnimGraph  = "models/marine/exosuit/exosuit_rr_view.animation_graph",
        },
		[kExoArmTypes.PlasmaLauncher] = {
            isValid        = true,
            worldModel     = "models/marine/exosuit/exosuit_rr.model",
            worldAnimGraph = "models/marine/exosuit/exosuit_rr.animation_graph",
            viewModel      = "models/marine/exosuit/exosuit_rr_view.model",
            viewAnimGraph  = "models/marine/exosuit/exosuit_rr_view.animation_graph",
        },
        [kExoArmTypes.Claw]    = {
            isValid        = true,
            worldModel     = "models/marine/exosuit/exosuit_cr.model",
            worldAnimGraph = "models/marine/exosuit/exosuit_cr.animation_graph",
            viewModel      = "models/marine/exosuit/exosuit_cr_view.model",
            viewAnimGraph  = "models/marine/exosuit/exosuit_cr_view.animation_graph",
        },
    },
    [kExoArmTypes.Claw]    = {
        isValid                = false,
        
        [kExoArmTypes.Minigun] = {
            isValid = false,
        },
        [kExoArmTypes.Railgun] = {
            isValid = false,
        },
		[kExoArmTypes.PlasmaLauncher] = {
            isValid = false,
        },
        [kExoArmTypes.Claw]    = {
            isValid        = false,
            worldModel     = "models/marine/exosuit/exosuit_cm.model",
            worldAnimGraph = "models/marine/exosuit/exosuit_cm.animation_graph",
            viewModel      = "models/marine/exosuit/exosuit_cm_view.model",
            viewAnimGraph  = "models/marine/exosuit/exosuit_cm_view.animation_graph",
        },
    },
	[kExoArmTypes.PlasmaLauncher] = {
        isValid                = true,
        [kExoArmTypes.Minigun] = {
            isValid = false,
        },
        [kExoArmTypes.Railgun] = {
            isValid        = true,
            worldModel     = "models/marine/exosuit/exosuit_rr.model",
            worldAnimGraph = "models/marine/exosuit/exosuit_rr.animation_graph",
            viewModel      = "models/marine/exosuit/exosuit_rr_view.model",
            viewAnimGraph  = "models/marine/exosuit/exosuit_rr_view.animation_graph",
        },
		[kExoArmTypes.PlasmaLauncher] = {
            isValid        = true,
            worldModel     = "models/marine/exosuit/exosuit_rr.model",
            worldAnimGraph = "models/marine/exosuit/exosuit_rr.animation_graph",
            viewModel      = "models/marine/exosuit/exosuit_rr_view.model",
            viewAnimGraph  = "models/marine/exosuit/exosuit_rr_view.animation_graph",
        },
        [kExoArmTypes.Claw]    = {
            isValid        = true,
            worldModel     = "models/marine/exosuit/exosuit_cr.model",
            worldAnimGraph = "models/marine/exosuit/exosuit_cr.animation_graph",
            viewModel      = "models/marine/exosuit/exosuit_cr_view.model",
            viewAnimGraph  = "models/marine/exosuit/exosuit_cr_view.animation_graph",
        },
    },
}
