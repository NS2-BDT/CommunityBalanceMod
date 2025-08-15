Script.Load("lua/Weapons/Marine/ExoWeaponHolder.lua")
Script.Load("lua/Weapons/Marine/Claw.lua")
Script.Load("lua/Weapons/Marine/PlasmaLauncher.lua")
Script.Load("lua/Weapons/Marine/ExoFlamer.lua")
Script.Load("lua/Weapons/Marine/Minigun.lua")
Script.Load("lua/Weapons/Marine/Railgun.lua")

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
    "Flamethrower",
	"PlasmaLauncher",
    "Armor",
    "NanoRepair",
    "NanoShield",
    "Thrusters",
    --"PhaseModule",
    "CatPack",
	"EjectionSeat",
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
        leftArmOnly  = true,
        advancedOnly = false
    },
    --[kExoModuleTypes.Welder] = {
    --    category = kExoModuleCategories.Weapon,
    --    powerCost = 0,
    --	resourceCost = kExoWelderCost,
    --    mapName = ExoWelder.kMapName,
    --    armType = kExoArmTypes.Railgun,
    --    weight = kExoWelderWeight,
    --	requiredTechId = kExoWelderTech
    --},
    [kExoModuleTypes.Minigun]    = {
        category       = kExoModuleCategories.Weapon,
        powerCost      = 0,
        resourceCost   = kMinigunCost,
        mapName        = Minigun.kMapName,
        armType        = kExoArmTypes.Minigun,
        weight         = kMinigunWeight,
        armorValue     = kMinigunArmor,
        requiredTechId = kMinigunTech,
        leftArmOnly    = false,
        advancedOnly   = true
    },
    [kExoModuleTypes.Railgun]    = {
        category       = kExoModuleCategories.Weapon,
        powerCost      = 0,
        resourceCost   = kRailgunCost,
        mapName        = Railgun.kMapName,
        armType        = kExoArmTypes.Railgun,
        weight         = kRailgunWeight,
        armorValue     = kRailgunArmor,
        requiredTechId = kRailgunTech,
        leftArmOnly    = false,
        advancedOnly   = true

    },
	[kExoModuleTypes.PlasmaLauncher]    = {
        category       = kExoModuleCategories.Weapon,
        powerCost      = 0,
        resourceCost   = kPlasmaLauncherCost,
        mapName        = PlasmaLauncher.kMapName,
        armType        = kExoArmTypes.PlasmaLauncher,
        weight         = kPlasmaLauncherWeight,
        armorValue     = kPlasmaLauncherArmor,
        requiredTechId = kPlasmaLauncherTech,
        leftArmOnly    = false,
        advancedOnly   = true

    },
    [kExoModuleTypes.Flamethrower] = {
        category 	   = kExoModuleCategories.Weapon,
        powerCost 	   = 0,
    	resourceCost   = kExoFlamerCost,
        mapName 	   = ExoFlamer.kMapName,
        armType 	   = kExoArmTypes.Railgun,
        weight 		   = kExoFlamerWeight,
		armorValue     = kExoFlamerWelderArmor,
    	requiredTechId = kExoFlamerTech,
		leftArmOnly    = false,
        advancedOnly   = true
    },
    --[kExoModuleTypes.Shield] = {
    --    category = kExoModuleCategories.Weapon,
    --    powerCost = 0,
    --	resourceCost = kExoShieldCost,
    --    mapName = ExoShield.kMapName,
    --    armType = kExoArmTypes.Claw,
    --    weight = kExoShieldWeight,
    --    armorValue     = kThrustersArmor,
    --	requiredTechId = kExoShieldTech,
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
        requiredTechId = kExoThrusterModuleTech
        
    },
    --	[kExoModuleTypes.PhaseModule] = {
    --    category = kExoModuleCategories.Utility,
    --    powerCost = 0,
    --	resourceCost = kPhaseModuleCost,
    --    weight = kPhaseModuleWeight,
    --	requiredTechId = kPhaseModuleTech
    --
    --},
	
    --[kExoModuleTypes.Armor]      = {
    --    category       = kExoModuleCategories.Utility,
    --    powerCost      = 0,
    --    resourceCost   = kArmorModuleCost,
    --    armorValue     = kArmorModuleArmor,
    --    weight         = kArmorModuleWeight,
    --    requiredTechId = kArmorModuleTech
    --},
	
    --[kExoModuleTypes.NanoRepair] = {
    --    category     = kExoModuleCategories.Utility,
    --    powerCost    = 0,
    --    resourceCost = kNanoModuleCost,
    --    weight       = kNanoRepairWeight,
    --    armorValue   = kNanoRepairArmor,
    --    
    --},
    
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
	
	[kExoModuleTypes.EjectionSeat]  = {
	category       = kExoModuleCategories.Utility,
	powerCost      = 0,
	resourceCost   = kEjectionSeatCost,
	weight         = kEjectionSeatWeight,
	armorValue     = kEjectionSeatArmor,
	requiredTechId = kEjectionSeatModuleTech
	},
    
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
            worldModel     = "models/claw/exosuit_cm.model",
            worldAnimGraph = "models/claw/exosuit_cm.animation_graph",
            viewModel      = "models/claw/exosuit_cm_view.model",
            viewAnimGraph  = "models/claw/exosuit_cm_view.animation_graph",
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
            worldModel     = "models/railgun/exosuit_pr.model",
            worldAnimGraph = "models/railgun/exosuit_pr.animation_graph",
            viewModel      = "models/railgun/exosuit_pr_view.model",
            viewAnimGraph  = "models/railgun/exosuit_pr_view.animation_graph",
        },
        [kExoArmTypes.Claw]    = {
            isValid        = true,
            worldModel     = "models/claw/exosuit_cr.model",
            worldAnimGraph = "models/claw/exosuit_cr.animation_graph",
            viewModel      = "models/claw/exosuit_cr_view.model",
            viewAnimGraph  = "models/claw/exosuit_cr_view.animation_graph",
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
            worldModel     = "models/claw/exosuit_cm.model",
            worldAnimGraph = "models/claw/exosuit_cm.animation_graph",
            viewModel      = "models/claw/exosuit_cm_view.model",
            viewAnimGraph  = "models/claw/exosuit_cm_view.animation_graph",
        }, -- NOT A VALID MODEL!
    },
	[kExoArmTypes.PlasmaLauncher] = {
        isValid                = true,
        [kExoArmTypes.Minigun] = {
            isValid = false,
        },
        [kExoArmTypes.Railgun] = {
            isValid        = true,
            worldModel     = "models/railgun/exosuit_rp.model",
            worldAnimGraph = "models/railgun/exosuit_rp.animation_graph",
            viewModel      = "models/railgun/exosuit_rp_view.model",
            viewAnimGraph  = "models/railgun/exosuit_rp_view.animation_graph",
        },
		[kExoArmTypes.PlasmaLauncher] = {
            isValid        = true,
            worldModel     = "models/plasma/exosuit_pp.model",
            worldAnimGraph = "models/plasma/exosuit_pp.animation_graph",
            viewModel      = "models/plasma/exosuit_pp_view.model",
            viewAnimGraph  = "models/plasma/exosuit_pp_view.animation_graph",
        },
        [kExoArmTypes.Claw]    = {
            isValid        = true,
            worldModel     = "models/claw/exosuit_cp.model",
            worldAnimGraph = "models/claw/exosuit_cp.animation_graph",
            viewModel      = "models/claw/exosuit_cp_view.model",
            viewAnimGraph  = "models/claw/exosuit_cp_view.animation_graph",
        },
    },
}
