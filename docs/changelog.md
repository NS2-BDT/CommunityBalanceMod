
# Revision 2.0 (2023/?)
## ALIEN
### Crag/Shift/Shade/Whip
  - Reduced cost to 8 tres from 13 tres
  - Reduced hitbox by 20%
  - Reduced HP by 20%
  - Changed Whip/Shade movement speed to be in line with Crag/Shift
  - Increased Speed by 25%

### Fortress Crag/Shift/Shade/Whip
  - Upgradeable version for 24 tres research cost
  - Are able to use ink, echo and healwave without a hivetype
  - Normal hitbox
  - Increased HP to 300%
  - Reduced Speed by 25%
  - Cannot be echo'd
  - Restricted to max 1 of each kind
  - Access to 1 new ability each (3 tres, 10 sec cooldown)
    - Umbra(Crag): Cast Umbra on all Structures in healrange
    - Hallucinations(Shade): Create 5 fake moveable Structures for 120 seconds
    - Stormcloud(Shift): Increase alien movement speed by 20% for 9.5 seconds
    - Frenzy(Whip): 2x attack speed and 4x movement speed for 7.5 seconds

### Whips
  - Fully matured whips attack without infestation
  - Added Bile Splash Ability
    - Cast 3 Bile Bombs over itself (3 tres, 10 second cooldown). 

### Shift
  - Reduced energy regenerate rate by 66%

## Structure Damage Rework
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
  
### Veil/Spur/Shell
  - Veils: Selfcloak
  - Spurs: Moveable (50% movement speed)
  - Shells: Selfheal (1% each healingcycle)

### Focus
  - affects Stab ability now
  - fixed bug which slowed Gore by 57% instead of 33%

### Gorge
  - Hydras and Bilemine cost 30% less energy

## Marines
  - Marines start with 2 IPs at 7+ players instead of 9+ players
  - Dropping mines cost 5 tres (from 7 tres)
  - Dropping welders cost 2 tres (from 3 tres)

## QoL 
### Minimap rework
  - Players are able to see if a hive is at <34%, <67% or <=100% maturity
  - Added Icon for occupied Hive/Chair
  - Added Icon for Jetpackers
  - Added Icon for matured Whips
  - Added Icon for Drifter Eggs
  - Added Icon for deployed ARCS
  - Added Icon for Advanced Armory


# Revision 1.5.2 - (2023/08/05)
## ALIEN
### Cloak
  - Cloaked units' minimap and model visibility based upon proximity corresponding to amount of veils (8m/6m/4m)
  - Player and drifter eggs are now invisible while under the effect of cloak
  - Cloaking-in rate is now fixed at 3 (over 0.33s)
  - Cloaking at 40.1% effectiveness is considered Fully Cloaked, no longer show on enemy minimap and evade AI targetting.
  - Combat-passive alien units partially decloak, and have shorter cloaking delay (1.5s instead of 2.5) after taking damage, scanned or touched.
  - Cloaking effect is applied normally again.
  - Cyst uncloak proximity radius change reverted.
  - Whips and Harvester no longer turn fully invisible

### Onos
- Stomp
  - Marines that are hit by Stomp are able to jump again

### Gorge
- Web
  - Marines that are hit by Web are able to jump again

# Revision 1.5 - (2023/07/19)
## Alien
### Onos
- Boneshield
  - Changed so if boneshield is broken it will display even if other weapon is active
- Stomp
  - Increased damage from 40 to 50 heavy damage
    - This will increase damage against exos from 80 to 100
  - Marines that are hit by Stomp will not be able to jump for the duration of the debuff
  
### Gorge
- Babblers
  - Babblers will now detach around the gorge instead of everyone at same location above the gorge
  - Babblers will stay out for at least the duration of the babbler ball
- Web
  - Marines that are hit by Web will not be able to jump for the duration of the debuff

### Upgrades
- Resilience
  - Replaced with Heat Plating
- Heat Plating
  - Reduce damage from flamethrower, grenadelauncher, mines, hand grenades and railguns (10% per shell)
  - Decreases duration of fire tick damage from flamethrowers by 33% per shell
- Cloaking
  - Cloaking at 40.6% effectiveness is considered Fully Cloaked, and sneaking aliens longer show blips on enemy minimap, and evade AI targetting.
  - Moving Alien players drop below Fully Cloaked threshold when their default max speed is reached.
  - (UI) Changed alien cloak status icon to show only when Fully cloaked.
  - Combat-passive alien units partially decloak, and have shorter cloaking delay (1.5s instead of 2.5) after taking damage, scanned or touched.
  - Cloaking effect is applied faster, and fades slower.
  - Camouflage upgrade slows decloaking rate per level.
  - Cloaking shader tweaked to be more consistent across different backgrounds. It now darkens as it decloaks and includes high frequency distortions to visually camouflage better over distance.
  - Cyst uncloak proximity radius reduced from 8 to 6.
  - Lerk speed scalar (used to scale cloaking and sound) tweaked.
- Swapping Trait Cost
  - Swapping to another trait from the same chamber costs less:
    - Skulk: 0 (Same as vanilla)
    - Gorge: 1 (Same as vanilla)
    - Lerk: 2 (Changed)
    - Fade: 3 (Changed)
    - Onos: 4 (Changed)


### Shade Hive
- Hallucination Cloud
  - Replaced Hallucination Cloud with Lesser Ink Cloud, cloaks players, eggs and drifters (including those in combat) for up to 5 seconds.
  - Hallucinated Hive and Harvester will still spawn in their allocated positions.
  - Ink Cloud (& Lesser Ink Cloud) provides enhanced cloaking for 1 second, removes sighted status, and gives improved visual camouflage (minimum 20%) even when in combat.
  - Cloaked Whips are more visible (same as players).

## Marines
### Grenades
 - Pulse Grenade
  - Increased damage from 50 to 60

### Protolab
- Exotech
  - Exotech is tied to the specific protolab it was researched on.
  - Exotech will be lost when the protolab gets destroyed or recycled.

# Fixes & Improvements
## Armslab
- Hologram
  - Armslabs while researching will show a rotating hologram

## Protolab
- Hologram
  - Protolabs while researching exotech will show a rotating exo hologram
  - Protolabs with exotech available will show a static exo inside an orb

## Scoreboard Points
  - Changed point rewards for building structures from 4 points to be tied to the buildtime
  - Removed point reward for building hydras

## Techtree Map
  - Fixed various visual bugs with updating tech
  - Rerouted techs to illustrate proper tech and structure requirements
  - Replaced babblertech and webs with nutrientmist at bio 1

<br />
<br />

# Revision 1 - (2023/03/24)
## Alien
### Onos
- Stomp
  - Stomp will no longer knock Marines over, instead Marines that are hit by a Stomp shockwave will have the full web debuff applied

### Upgrades
- Carapace
  - Replaced with Resilience
- Resilience
  - Increases duration of positive status effects and decreases duration of negative status effects
  - Positive status effects duration will increase by 33% per shell
  - Negative status effects duration will decrease by 33% per shell
  - Positive status effects include umbra, enzyme (drifter ability), and mucous membrane (drifter ability).
  - Positive status effects like umbra will not be removed when players are set on fire with resilience
  - Negative status effects include nerve gas dot, flamer dot, and pulse slow.
  - You must have resilience to receive the increased duration of buffs.

## Marine
### Weapons
- Railgun
  - Added falloff to the Railgun
    - Railguns will deal full damage to targets 15 meters or closer
    - Damage will drop off linearly until a max distance of 30 meters
    - The maximum damage reduction is 50%

# Fixes & Improvements
## Onos
- Stomp
- Implemented Stomp fixes for edge case issues ([Link to original mod](https://steamcommunity.com/sharedfiles/filedetails/?id=1082228340))
