GetEffectManager():AddEffectData("ScattersModEffects", {
    leftexowelder_muzzle  = {
        welderMuzzleEffects = {
            { viewmodel_cinematic = "cinematics/marine/welder/exowelder_muzzle.cinematic", attach_point = "fxnode_l_railgun_muzzle" },
            { weapon_cinematic = "cinematics/marine/welder/exowelder_muzzle.cinematic", attach_point = "fxnode_lrailgunmuzzle" },
        },
    },
    rightexowelder_muzzle = {
        welderMuzzleEffects = {
            { viewmodel_cinematic = "cinematics/marine/welder/exowelder_muzzle.cinematic", attach_point = "fxnode_r_railgun_muzzle" },
            { weapon_cinematic = "cinematics/marine/welder/exowelder_muzzle.cinematic", attach_point = "fxnode_rrailgunmuzzle" },
        },
    },
    exowelder_hit         = {
        welderHitEffects = {
            { cinematic = "cinematics/marine/welder/exowelder_hit.cinematic" },
        },
    },
})

GetEffectManager():AddEffectData("FlamerModEffects", {
    leftexoflamer_muzzle  = {
        flamerMuzzleEffects = {
            { viewmodel_cinematic = "cinematics/marine/flamethrower/flame_1p.cinematic", attach_point = "fxnode_l_railgun_muzzle" },
            { weapon_cinematic = "cinematics/marine/flamethrower/flame.cinematic", attach_point = "fxnode_lrailgunmuzzle" },
        },
    },
    rightexoflamer_muzzle = {
        flamerMuzzleEffects = {
            { viewmodel_cinematic = "cinematics/marine/flamethrower/flame_1p.cinematic", attach_point = "fxnode_r_railgun_muzzle" },
            { weapon_cinematic = "cinematics/marine/flamethrower/flame.cinematic", attach_point = "fxnode_rrailgunmuzzle" },
        },
    },
})
    
GetEffectManager():AddEffectData("plasma_impact", {
	plasma_impact = 
    {
        PlasmaImpact = 
        {
            {cinematic = "cinematics/modularexo/plasma_impact.cinematic", done = true}
        }
    },
})	
	