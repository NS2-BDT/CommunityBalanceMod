local kAlienWeaponEffects = {
    shockwave_trail =
    {
        {
            -- CommunityBalanceMod: Use new shockwave_segment cinematic
            {cinematic = "cinematics/alien/onos/shockwave_segment.cinematic"},
        }
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
}

GetEffectManager():AddEffectData("AlienWeaponEffects", kAlienWeaponEffects)
