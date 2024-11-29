-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\AlienWeaponEffects.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- Debug with: {player_cinematic = "cinematics/locateorigin.cinematic"},

kAlienWeaponEffects =
{
    shockwave_trail =
    {
        {
            -- CommunityBalanceMod: Use new shockwave_segment cinematic
            {cinematic = "cinematics/alien/onos/shockwave_segment.cinematic"},
        }
    },
	
    shockwave_hit =
    {
        {
            {decal =  "cinematics/vfx_materials/decals/shockwave_hit.material", scale = 2.0},
            {cinematic = "cinematics/alien/onos/shockwave_hit.cinematic"},
        }
    },

    draw =
    {
    },

    bite_kill =
    {
        biteKillSound =
        {
            {sound = "", silenceupgrade = true, done = true},
            {sound = "sound/NS2.fev/alien/skulk/bite_kill", attach_point = "Bip01_Head", done = true},
        }
    },

    bite_structure =
    {
        biteHitSound =
        {
            {sound = "sound/NS2.fev/alien/skulk/bite_hit_structure", world_space = true, isalien = false, done = true},
        },
    },

    bite_attack =
    {
        biteAttackSounds =
        {
            {sound = "", silenceupgrade = true, done = true},

            {player_sound = "sound/NS2.fev/alien/skulk/bite_structure", attach_point = "Bip01_Head", surface = "structure", done = true},
            {player_sound = "sound/NS2.fev/alien/skulk/bite", attach_point = "Bip01_Head"},
        },
    },

    lerkbite_attack =
    {
        lerkBiteAttackSounds =
        {
            {sound = "", silenceupgrade = true, done = true},

            {player_sound = "sound/NS2.fev/alien/lerk/bite", attach_point = "Bip01_Head", surface = "structure", done = true},
            {player_sound = "sound/NS2.fev/alien/lerk/bite", attach_point = "Bip01_Head"},
        },
    },

    -- Leap
    leap =
    {
        biteAltAttackEffects =
        {
            -- TODO: Take volume or hasLeap
            {sound = "", silenceupgrade = true, done = true},

            {player_sound = "sound/NS2.fev/alien/skulk/bite_alt"},

        },
    },

    bilebomb_decal =
    {
        bileBombDecal =
        {
            {decal = "cinematics/vfx_materials/decals/bilebomb_decal.material", scale = 3.5, done = true}
        }
    },

    parasite_attack =
    {
        parasiteAttackEffects =
        {
            {player_cinematic = "cinematics/alien/skulk/parasite_fire.cinematic"},
            {viewmodel_cinematic = "cinematics/alien/skulk/parasite_view.cinematic", attach_point = "CamBone"},

            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/skulk/parasite"},
        },
    },

    xenocide =
    {
        xenocideEffects =
        {
            {sound = "sound/NS2.fev/alien/common/xenocide_end", world_space = true},
            {cinematic = "cinematics/alien/skulk/xenocide.cinematic"}
        }
    },

    spitspray_attack =
    {
        spitFireEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/gorge/spit"},
        },
    },

    babblerability_attack =
    {
        babblerabilityAttackEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/gorge/babbler_ball_spit", world_space = true},
        },
    },

    healspray_collide =
    {
        healSpayCollideEffects =
        {
            {cinematic = "cinematics/alien/heal.cinematic"},
        },
    },

    heal_spray =
    {
        sprayFireEffects =
        {
            -- Use player_cinematic because at world position, not attach_point
            {player_cinematic = "cinematics/alien/gorge/healthspray.cinematic"},
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/gorge/heal_spray"}
        },
    },

    digest =
    {
        sprayFireEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {sound = "sound/NS2.fev/alien/gorge/build"}
        },
    },

    bilebomb_onstructure =
    {
        bileBombOnStructureEffects =
        {
            {sound = "sound/NS2.fev/alien/structures/deploy_large"},
            -- structure specific effects

            {cinematic = "cinematics/alien/lerk/bomb_small.cinematic", classname = "InfantryPortal", done = true },
            {cinematic = "cinematics/alien/lerk/bomb_big.cinematic", classname = "CommandStation", done = true },
            {cinematic = "cinematics/alien/lerk/bomb_big.cinematic", classname = "RoboticsFactory", done = true },
            {cinematic = "cinematics/alien/lerk/bomb_small.cinematic", classname = "Sentry", done = true },
            {parented_cinematic = "cinematics/alien/lerk/bomb_small.cinematic", classname = "MAC", done = true },
            {parented_cinematic = "cinematics/alien/lerk/bomb_structure.cinematic", classname = "ARC", done = true },
            {parented_cinematic = "cinematics/alien/lerk/bomb_marine.cinematic", classname = "Marine", done = true},

            {cinematic = "cinematics/alien/lerk/bomb_structure.cinematic"},


        }

    },

    bilebomb_attack =
    {
        bilebombFireEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/gorge/bilebomb"},
        },
    },

    bilebomb_hit =
    {
        bilebombHitEffects =
        {

            -- TODO: Change to something else
            {cinematic = "cinematics/alien/gorge/bilebomb_impact.cinematic"},
            {parented_sound = "sound/NS2.fev/alien/gorge/bilebomb_hit", done = true},
        },
    },

    spit_structure =
    {
        spitStructureEffects =
        {
            {cinematic = "cinematics/alien/gorge/spit_structure.cinematic"},
            {sound = "", silenceupgrade = true, done = true},
            {sound = "sound/NS2.fev/alien/gorge/create_structure_start", world_space = true},
        }
    },

    spikes_attack =
    {
        spikeAttackSounds =
        {
            {sound = "sound/NS2.fev/alien/lerk/spikes", done = true},
        },
    },

    spores_attack =
    {
        sporesAttackEffects =
        {
            {viewmodel_cinematic = "cinematics/alien/lerk/spore_view_fire.cinematic", attach_point = "fxnode_hole_left"},
            {viewmodel_cinematic = "cinematics/alien/lerk/spore_view_fire.cinematic", attach_point = "fxnode_hole_right"},
            {sound = "", silenceupgrade = true, done = true},
            {sound = "sound/NS2.fev/alien/lerk/spore_spray_once", world_space = true},
        },
    },

    spores_hit =
    {
        sporesHitEffects =
        {
            {sound = "sound/NS2.fev/alien/lerk/spores_hit", world_space = true},
        }
    },
    spores_hit_end =
    {
        sporesHitEffects =
        {
            {stop_sound = "sound/NS2.fev/alien/lerk/spores_hit", world_space = true},
        }
    },

    umbra_attack =
    {
        umbraAttackEffects =
        {
            {viewmodel_cinematic = "cinematics/alien/lerk/umbra_view_fire.cinematic", attach_point = "fxnode_hole_left"},
            {viewmodel_cinematic = "cinematics/alien/lerk/umbra_view_fire.cinematic", attach_point = "fxnode_hole_right"},
            {sound = "", silenceupgrade = true, done = true},
            {sound = "sound/NS2.fev/alien/structures/crag/umbra", world_space = true},
        },
    },


    spores_attack_end =
    {
        sporesAttackEndEffects =
        {
        },
    },

    poison_dart_trail =
    {
        PoisonDartTrail =
        {
            {cinematic = "cinematics/alien/lerk/poison_trail.cinematic"},
            {sound = "sound/NS2.fev/alien/lerk/spores_shoot"},
        }
    },

    swipe_attack =
    {
        swipeAttackSounds =
        {
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/fade/swipe_structure", surface = "structure", done = true},
            {player_sound = "sound/NS2.fev/alien/fade/swipe"},
        },
    },

    stab_attack =
    {
        stabAttackEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/fade/stab"},
        },
    },

    metabolize =
    {
        metabolizeSounds =
        {
            {player_sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/fade/metabolize"}
        }
    },

    metabolize_stop =
    {
        metabolizeSounds =
        {
            {stop_sound = "sound/NS2.fev/alien/fade/metabolize"}
        }
    },

    blink_in =
    {
        blinkInEffects =
        {
            {player_sound = "sound/NS2.fev/alien/fade/blink_end"},
            {player_cinematic = "cinematics/alien/fade/blink_in_silent.cinematic", done = true},
        },
    },

    blink_out =
    {
        blinkOutEffects =
        {
            {player_sound = "sound/NS2.fev/alien/fade/blink"},
            {player_cinematic = "cinematics/alien/fade/blink_out_silent.cinematic", done = true},
        },
    },

    blink_loop_start =
    {
        blinkInEffects =
        {
            {private_sound = "sound/NS2.fev/alien/fade/blink_loop"},
        },
    },

    blink_loop_end =
    {
        blinkOutEffects =
        {
            {stop_sound = "sound/NS2.fev/alien/fade/blink_loop"},
        },
    },

    blink_world_loop_start =
    {
        blinkWorldInEffects =
        {
            {player_sound = "sound/NS2.fev/alien/fade/blink_loop_3D"},
        },
    },

    blink_world_loop_end =
    {
        blinkWorldOutEffects =
        {
            {stop_sound = "sound/NS2.fev/alien/fade/blink_loop_3D"},
        },
    },


    shadow_step =
    {
        shadowStepEffects =
        {
            {player_sound = "sound/NS2.fev/alien/fade/shadow_step"},
            {player_cinematic = "cinematics/alien/fade/shadowstep_silent.cinematic", done = true},
        }

    },

    blink_out_local =
    {
        blinkOutEffects =
        {
            {viewmodel_cinematic = "cinematics/alien/fade/blink_view.cinematic", attach_point = ""},
        },
    },

    -- Sound Effects only
    gore_attack =
    {
        goreAttackEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/onos/gore"},
        },
    },

    smash_attack =
    {
        smashAttackEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/onos/gore"},
        },
    },

    smash_attack_hit =
    {
        smashAttackHitEffects =
        {
            {cinematic = "cinematics/alien/onos/door_hit.cinematic"}
        },
    },

    stomp_attack =
    {
        stompAttackEffects =
        {
            {cinematic = "cinematics/alien/onos/stomp.cinematic"},
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/onos/stomp"},
        },
    },

    stomp_attack =
    {
        stompAttackEffects =
        {
            -- CommunityBalanceMod: Use new stomp_trimmed cinematic
            {cinematic = "cinematics/alien/onos/stomp_trimmed.cinematic"},
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/onos/stomp"},
        },
    },
	
    onos_charge =
    {
        onosChargeEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {player_sound = "sound/NS2.fev/alien/onos/wound_serious"},
        },

    },

    onos_charge_hit_marine =
    {
        onosChargeEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {sound = "sound/NS2.fev/alien/onos/charge_hit_marine"},
        },
    },

    onos_charge_hit_exo =
    {
        onosChargeEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {sound = "sound/NS2.fev/alien/onos/charge_hit_exo"},
        },
    },

    onos_charge_crash =
    {
        onosChargeCrashEffects =
        {
            {cinematic = "cinematics/alien/onos/stomp_hit.cinematic"},
        },

    },

    onos_shield_start =
    {
        onosShieldEffects =
        {
            --{parented_cinematic = "cinematics/alien/onos/stomp_hit.cinematic", attach_point = "Onos_Head"},
            {sound = "", silenceupgrade = true, done = true},
            {sound = "sound/NS2.fev/alien/onos/land", attach_point = "Onos_Head", done = true},
        },
    },

    onos_shield_break =
    {
        onosShieldBreakEffects =
        {
            {sound = "sound/NS2.fev/alien/common/armor_break", done = true}
        }
    },

    -- Alien vision mode effects
    alien_vision_on =
    {
        visionModeOnEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {sound = "sound/NS2.fev/alien/common/vision_on"},
        },
    },

    alien_vision_off =
    {
        visionModeOnEffects =
        {
            {sound = "", silenceupgrade = true, done = true},
            {sound = "sound/NS2.fev/alien/common/vision_off"},
        },
    },

    comm_nutrient_mist =
    {
        nutrienMist =
        {
            { sound = "sound/NS2.fev/alien/commander/catalyze_3D" },
            --{ cinematic = "cinematics/alien/nutrientmist.cinematic" }
        }
    },
	
	babbler_bomb_fire = 
    {
        babblerBombFireEffects = 
        {
            {sound = "", silenceupgrade = true, done = true}, 
            {player_sound = "sound/combat.fev/combat/abilities/alien/gorge/babbler_bomb_throwup"},
        },
    },
    
    babbler_bomb_hit = 
    {
        babblerbombEffects = 
        {
            {sound = "sound/combat.fev/combat/abilities/alien/gorge/babbler_bomb_explode"},
            {cinematic = "cinematics/alien/gorge/babbler_bomb_hit.cinematic", done = true},
        },
    },
	
	babbler_bomb_fire = 
    {
        babblerBombFireEffects = 
        {
            {sound = "", silenceupgrade = true, done = true}, 
            {player_sound = "sound/combat.fev/combat/abilities/alien/gorge/babbler_bomb_throwup"},
        },
    },
}

-- "false" means play all effects in each block
GetEffectManager():AddEffectData("AlienWeaponEffects", kAlienWeaponEffects)

