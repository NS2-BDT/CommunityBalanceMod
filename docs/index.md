# Changes between revision 2.0.2 and Vanilla Build 344

<br>
<br>

# Alien
![alt text](./assets/images/Alien_Banner.webp "Alien")


### Crag/Shift/Shade/Whip
  - Reduced cost to 8 tres from 13 tres
  - Reduced modelsize by 20%
  - Reduced HP by 20%
  - Changed Whip/Shade movement speed to be in line with Crag/Shift
  - Increased Speed by 25%
  - Reduced bouncing/glitching during and after moving

### Fortress Crag/Shift/Shade/Whip
  - Upgradeable version for 24 tres research cost and 25 second upgrade time
  - Normal modelsize
  - Increased HP to 300%
  - Reduced Speed by 25%
  - Cannot be echo'd
  - Restricted to max 1 of each kind
  - Are able to use ink, echo and healwave without a hivetype
  - Access to a new ability with the corresponding hive type (3 tres, 10 sec cooldown)
    - Umbra(Crag): Cast Umbra for 5 seconds on all Structures in healrange
    - Hallucinations(Shade): Create 6 moveable hallucination Structures (whip or shade likelier) for 600 seconds
    - Stormcloud(Shift): Increase alien movement speed by 20% for 9.5 seconds
    - Frenzy(Whip): 2x attack speed and 2.5x movement speed for 7.5 seconds (no hivetype needed)

### Whips
  - Fully matured whips attack without infestation
  - Added Bile Splash Ability
    - Available without any hivetype or upgrade
    - Splash nearby enemies with bile (3 tres, 10 sec cooldown)
    - Deals between 1.25-2 full bilebomb damage based on distance

### Shift
  - Reduced energy regenerate rate by 50%

### Onos
- Boneshield
  - Changed so if boneshield is broken it will display even if other weapon is active
- Stomp
  - Stomp will no longer knock Marines over, instead Marines that are hit by a Stomp shockwave will have the full web debuff applied
  - Jetpackers will no longer be affected by stomp when slightly above the ground
  - Increased damage from 40 to 50 heavy damage
    - This will increase damage against exos from 80 to 100

### Gorge
- Babblers
  - Babblers will now detach around the gorge instead of everyone at same location above the gorge
  - Babblers will stay out for at least the duration of the babbler ball
  - Hydras and Bilemine cost 30% less energy
  - Bile damage accelerates weapon expiration
    - 1 Bile ~ 5 seconds

### Upgrades
- Carapace
  - Replaced with Heat Plating
- Cloaking
  - Cloaked units' minimap and model visibility based upon proximity corresponding to amount of veils (8m/6m/4m)
  - Player and drifter eggs are now invisible while under the effect of cloak
  - Cloaking-in rate is now fixed at 3 (over 0.33s)
  - Cloaking at 40.1% effectiveness is considered Fully Cloaked, no longer show on enemy minimap and evade AI targetting
  - Moving Alien players drop below Fully Cloaked threshold when their default max speed is reached
  - (UI) Changed alien cloak status icon to show only when Fully cloaked
  - Not-in-combat alien units partially decloak, and have shorter cloaking delay (1.0s instead of 2.5) after being detected, scanned or touched
  - Camouflage upgrade slows de-cloaking rate, and reduces cloaking delay per level
  - Cloaking shader tweaked to be more consistent across different backgrounds. It now darkens as it decloaks and 
    includes high frequency distortions to visually camouflage better over distance
  - Lerk max speed scalar (used to scale cloaking) changed to 9
  - Onos with camouflage will be silent while crouch walking 
- Heat Plating
  - Reduce damage from flamethrower, grenadelauncher, mines, hand grenades and railguns (10% per shell)
  - Decreases duration of fire tick damage from flamethrowers by 33% per shell
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

### Veil/Spur/Shell
  - Veils: Cloaked
  - Spurs: Moveable (50% movement speed)
	- Shells: Selfheal (1% each healingcycle)

### Focus
  - affects Stab ability now
  - fixed bug which slowed Gore by 57% instead of 33%

# Marine
![alt text](./assets/images/Marine_Banner.webp "Marine")


### Infantry Portals
  - Marines start with 2 IPs at 7+ players instead of 9+ players

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

### Weapons and Equipment Changes
- Pulse Grenade
  - Increased damage from 50 to 60
  - Increased range of debuff by 50%

- Cluster Grenade
  - Reduced grenade range and fragment range by 20%

- Railgun
  - Falloff
    - Railguns will deal full damage to targets 15 meters or closer
    - Damage will drop off linearly until a max distance of 30 meters
    - The maximum damage reduction is 50%

  - Dropping mines cost 5 tres (from 7 tres)
  - Dropping welders cost 2 tres (from 3 tres)

  - ARCs dont deal damage to other ARCS anymore
  - Macs move 20% faster and have half the line of sight as a drifter
  - Selfdamage reduced by 66% (grenades/mines)

  - Autopickup for welders reduced from 5 to 1 second

### Advanced Support
- Advanced Support research cost changed to 15 res (from 20)

- Nanoshield
  - Cost reduced to 2 (from 3)

- Catpacks
  - Catpacked marines now build and weld faster 12.5% as well

### Robotics Factory
- MACs
  - Increased delay between MAC chatting sounds
  - Allow MACs to be welded while taking damage

### Structures
- Prototype Lab
  - Exotech
    - Exotech is tied to the specific protolab it was researched on.
    - Exotech will be lost when the protolab gets destroyed or recycled.

# Fixes & Improvements
![alt text](./assets/images/Fixes_Banner.webp "Marine")
 
### HUD
  - New Advanced Option (HUD) "STATUS ICONS"
    - Display status icons even with minimal hud elements.

### Commander
  - Alien Commander is able to see parasited mines

### Minimap rework
  - Players are able to see if a hive is at <34%, <67% or <=100% maturity
  - Added Icon for occupied Hive/Chair
  - Added Icon for Jetpackers
  - Added Icon for matured Whips
  - Added Icon for Drifter Eggs
  - Added Icon for deployed ARCS
  - Added Icon for Advanced Armory
  - Added Icons for Fortress PvE

### Armslab
- Hologram
  - Armslabs while researching will show a rotating hologram

### Protolab
- Hologram
  - Protolabs while researching exotech will show a rotating exo hologram
  - Protolabs with exotech available will show a static exo inside an orb

### Scoreboard Points
  - Changed point rewards for building structures from 4 points to be tied to the buildtime
  - Removed point reward for building hydras

### Techtree Map
  - Fixed various visual bugs with updating tech
  - Rerouted techs to illustrate proper tech and structure requirements
  - Replaced babblertech and webs with nutrientmist at bio 1

### Onos
- Stomp
- Implemented Stomp fixes for edge case issues [Link to original mod](https://steamcommunity.com/sharedfiles/filedetails/?id=1082228340)

<br/>
<hr/>
<br/>

Last updated: 2023/11/28
