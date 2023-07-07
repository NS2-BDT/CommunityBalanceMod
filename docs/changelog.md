# Revision 1.5 - (TBD)
## Alien
### Onos
- Stomp
  - Increased damage from 80 to 100
  - Marines that are hit by Stomp will not be able to jump for the duration of the debuff

### Upgrades
- Swapping Trait Cost
  - Swapping to another trait from the same chamber costs less:
    - Skulk: 0 (Same as vanilla)
    - Gorge: 1 (Same as vanilla)
    - Lerk: 2 (Changed)
    - Fade: 3 (Changed)
    - Onos: 4 (Changed)

### Gorge
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
  - Exotech is tied to the specifc protolab it was researched on.
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

>>>>>>> dev
  


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
