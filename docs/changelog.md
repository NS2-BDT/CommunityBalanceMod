# Revision 1.5 - (TBD)
## Alien
### Onos
- Stomp
  - Damage increase from 80 to 100
  - Marines that are hit by Stomp will not be able to jump for the duration of the debuff

### Gorge
- Web
  - Marines that are hit by Web will not be able to jump for the duration of the debuff

### Upgrades
- Resilience
  - Replaced with Heat Plating
- Heat Plating
  - Reduce damage from flamethrower, grenadelauncher, mines, hand grenades and railguns (10% per shell)
  - Decreases duration of fire tick damage from flamethrowers by 33% per shell

### Shade Hive
- Hallucination Cloud
   - Removed hallucination bots from spawning for server performance
   - Added cloak effect for aliens passing through the cloud for a short duration even while attacking

## Marines
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
  - Marines
    - Increased point reward for structures from 4 to 5
  - Gorge
    - Removed point reward for building hydras
  


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
