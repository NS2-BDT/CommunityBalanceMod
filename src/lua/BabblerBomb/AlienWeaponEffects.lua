local kBabblerBombEffects =
{
 
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

GetEffectManager():AddEffectData("BabblerBombEffects", kBabblerBombEffects)
GetEffectManager():PrecacheEffects()