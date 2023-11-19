-- ======= Copyright (c) 2021, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua/Changelog/GUIBalanceChangelogData.lua
--
--    Created by:   Darrell Gentry (darrell@naturalselection2.com)
--
--    Data for the changelog window.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

-- Each change string should be prefixed with this character.
-- This'll all be parsed and processed when loaded into the changelog window.
function GetChangelogStyleToken()
  return "#"
end

gChangelogData =
[[


Welcome to the Community Balance Mod, a project built by the community, for the community. 
Ping me, @Shifter and the lead of the project, in any of the NS2 discords, or start a conversation in beta-balance-feedback 
on the official discord to let me and the team know what you think! Below are the changes this mod introduces:

# TLDR:
  - Weapon 0-1 deals less structure damage, Weapon 3 deals more structure damage
  - Railguns deal less damage over long distances (nerf)
  - Exos can only be bought at the proto they have been researched on (nerf)
  - Pulse grenades damage and range buffed, cluster grenades range nerfed
  - Advanced Support cost reduced (15 from 20) (buff)
  - Nanoshield cost reduced (2 from 3) (buff)
  - Catpacks improve welding as well (buff)
  - MACs move faster and are able to see aliens (buff)
  - Any kind of selfdamage reduced by 66% (grenades/mines) (buff)
  - Stomp doesnt knock down marines anymore, but deals 20% more damage
  - Carapace replaced with Heatplating (nerf)
  - Camouflage cloaks 100% at medium-far distance (buff)
  - Swapping upgrades cost less pres (eg. Vampirism->Regeneration) (buff)
  - Focus works with stab and gore (buff)
  - Crag/Shift/Shade/Whip cost reduction (8 from 13), 20% less HP, 25% faster speed (buff)
  - New fortress upgrade for them (24 pres), 300% HP, 25% slower speed, unlocks new abilities (new)
  - Fully matured whips attack without infestation
  - Reduced shift energy gain by 50% (nerf)
  - Hydras and Bilemine cost 30% less energy (buff)
  - Shells/Veils/Spurs are able to selfheal/selfcloak or move (buff)
  - Drifter hallucination ability replaced with cloak cloud ability (server performance)

# Changes between Revision 2.0.2 and 2.0.1: (2023/11/19)
## ALIEN
### Crag/Shift/Shade/Whip
  - Changed fortress PvE upgrade time to 25 seconds, up from 10
  - Shift energy regen nerf is now 50% the vanilla value (from 66% nerf).

### Onos
  - Onos with camouflage will be silent while crouch walking

### Heatplating 
  - Gas grenades now deal reduced damage with heatplating to match other hand grenades

## MARINE
### Advanced Support
  - Advanced support to 15 tres, nano shield cost reduction to 2
  - Catpacked marines now build and weld faster 12.5% as well
  - Nanoshield cost reduced to 2 (from 5)

### MACs
  - Allow MACs to be welded while taking damage

### Hand Grenades
  - Cluster grenade range and fragment range reduced by 20%

#Changes between Revision 2.0.2 and vanilla:
## MARINE
### Structure Damage Rework
- Buffed all Alien Structures HP by 15%
  - Hives receive an additional HP buff of 10% at full maturity for a total of +25%
- Buffed Arc Damage by 15%
- Buffed Gorge Structure Healing by 15%
- Every weapon upgrade does +20% structure damage (instead of + 10%)
    W1 → +10% to lifeforms / +20% to structures
    W2 → +20% to lifeforms / +40% to structures
    W3 → +30% to lifeforms / +60% to structures
- FT and GL scale at 10% (20% structure) instead of 7%
- W0 GL → 65 Player / 260 Structure from 74.4 Player Damage
- W0 FT → 9 Player / 18 Structure from 9.9 Player Damage

### Railgun 
  - Added falloff to the Railgun
    Railguns will deal full damage to targets 15 meters or closer
    Damage will drop off linearly for a max distance of 30 meters
    The maximum damage reduction is 50%

### Prototype Lab
  - Exotech is tied to the specific protolab it was researched on.
  - Exotech will be lost when the protolab gets destroyed or recycled.

### Grenades
  - Pulse grenade increased damage from 50 to 60
  - Pulse gernade debuff range increased by 50%
  - Cluster grenade range and fragment range reduced by 20%

### Advanced Support
  - Advanced support to 15 tres, nano shield cost reduction to 2
  - Catpacked marines now build and weld faster 12.5% as well
  - Nanoshield cost reduced to 2 (from 5)

### MACS
  - Macs move 20% faster and have half the line of sight as a drifter
  - Allow MACs to be welded while taking damage

### Others
  - ARCs dont deal damage to other ARCS anymore
  - Selfdamage reduced by 66% (grenades/mines)
  - Dropping mines cost 5 tres (from 7 tres)
  - Dropping welders cost 2 tres (from 3 tres)
  - Autopickup for welders reduced from 5 to 1 second

## ALIEN
### Stomp
  - Marines that are hit by Stomp will be webbed instead of knocked down
  - Increased damage by 20%
  - Able to hit enemies on small crates/elevations
  - Jetpackers will no longer be affected by stomp when slightly above the ground

### Heat Plating
  - Replaces Carapace
  - Reduce damage from flamethrower, grenadelauncher, mines, hand grenades and railguns (10% per shell)
  - Decreases duration of fire tick damage from flamethrowers by 33% per shell

###Cloak
  - Cloaked units' minimap and model visibility based upon proximity corresponding to amount of veils (8m/6m/4m)
  - Player and drifter eggs are now invisible while under the effect of cloak
  - Cloaking at 40.1% effectiveness is considered Fully Cloaked, no longer show on enemy minimap and evade AI targetting.
  - Combat-passive alien units partially decloak, and have shorter cloaking delay (1.5s instead of 2.5) 
    after taking damage, scanned or touched.
  - Whips and Harvester no longer turn fully invisible
  - Onos with camouflage will be silent while crouch walking

###Swapping Trait Cost
  - Swapping to another trait from the same chamber costs less:  
      Skulk: 0 (Same as vanilla)
      Gorge: 1 (Same as vanilla)
      Lerk: 2 (Changed)
      Fade: 3 (Changed)
      Onos: 4 (Changed)

### Focus
  - affects Stab ability now
  - fixed bug which slowed Gore by 57% instead of 33%

### Crag/Shift/Shade/Whip
  - Reduced cost to 8 tres from 13 tres
  - Reduced HP by 20%
  - Changed Whip/Shade movement speed to be in line with Crag/Shift
  - Increased Speed by 25%

### Fortress Crag/Shift/Shade/Whip
  - Upgradeable version for 24 tres research cost
  - Increased HP to 300%
  - Reduced Speed by 25%
  - Cannot be echo'd
  - Restricted to max 1 of each kind
  - Are able to use ink, echo and healwave without a hivetype
  - Access to a new ability with the corresponding hive type (3 tres, 10 sec cooldown)
    - Umbra(Crag): Cast Umbra 5 seconds on all Structures in healrange
    - Hallucinations(Shade): Create 6 moveable hallucination Structures (whip or shade likelier) for 120 seconds
    - Stormcloud(Shift): Increase alien movement speed by 20% for 9.5 seconds
    - Frenzy(Whip): 2x attack speed and 2.5x movement speed for 7.5 seconds (no hivetype needed)

### Whips
  - Fully matured whips attack without infestation
  - Added Bile Splash Ability
  - Available without any hivetype or upgrade
  - Splash nearby enemies with bile (3 tres, 10 sec cooldown)
  - Deals between 1.25-2 full bilebomb damage based on distance

### Shift
  - Reduced energy regenerate rate by 66% (changed to 50% with 2.0.2)

### Gorge
  - Hydras and Bilemine cost 30% less energy
  - Bile damage accelerates weapon expiration
    - 1 Bile ~ 5 seconds

### Veil/Spur/Shell
  - Veils: Cloaked
  - Spurs: Moveable (50% movement speed)
  - Shells: Selfheal (1% each healingcycle)

### Cloaking Cloud
  - Replaced Hallucination Cloud
  - Cloaks players, eggs and drifters (including those in combat) for up to 5 seconds.

### Others
  - New Advanced Option (HUD) "STATUS ICONS"
    - Display status icons even with minimal hud elements.
  - Changed so if boneshield is broken it will display even if other weapon is active
  - Babblers will now detach around the gorge instead of everyone at same location above the gorge
  - Babblers will stay out for at least the duration of the babbler ball

]]
