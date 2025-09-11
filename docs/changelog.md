# TLDR of Community Balance Mod vs. Vanilla: (9/X/2025)
  - Reworks to marines structures (sentry and sentry battery)
  - New marine commander units (SPARC and A-MAC).
  - Modular exosuits with new exo arms (plasma launcher and blowtorch) and upgrades.
  - Scaling structure damage with weapon upgrades.
  - Extension to electrify debuff (works on PvE).
  - Reworks and balance of some alien traits (carapace and aura) and trait swapping.
  - Rework to stomp and new gorge ability (babblerbomb).
  - New khammander units (Fortress crag, shift, shade, and whip) with powerful abilites.
  - Major rebalance of alien PvE.
  - Massive improvements to MACs and drifters.
  - New map icons for alien and marine structures and units.
  - Various QoL, game improvements, and bugfixes.
  - Custom skins and cinematics for new content.

<br />
<br />

# Version 2.7.3 vs. Vanilla: (9/X/2025)
## MARINE
### Modular Exosuits
  - Exosuits changed to have swappable arms and cores (pres refunds disabled when swapping arms/cores).
  - Base kit thruster replaced with jump (exos can no longer sprint by default).
  - Base Armor is 200 (+40 per armor level) and base speed is 6 m/s.
  - Additional armor/weight(inverse of speed)/pres cost is dependent on selected arms:
	- Railgun: 25/0.1/20
	- Minigun: 100/0.2/25
	- Plasma Launcher: 50/0.125/15
	- Blowtorch: 0/0.05/15
	- Claw: 0/0.0/5
  - Cores - Optional Upgrade:
	- Ejection Seat: Auto-ejects marine on exosuit reaching 0 armor (+0.025 Weight / Costs 5 pres).
      - Requires valid ejection spot.
	  - Empty exosuit will spawn with 50 armor upon automatic ejection (minus overflow damage).
      - Empty exosuit must have >50 armor to enter exosuit after automatic ejection.	
	- Thruster: Increases movement speed and allows for flight at the cost of energy (+0.05 Weight). 
	  - Min 25% activation energy required.
  - Setting to make duals fire both arms upon primary attack (options -> mods -> CBM: Accessibility Options)

### Railgun 
  - Railgun reworked to be more forgiving and less "bursty".
  - Firing cooldown set to 1s from 1.4s.
  - Charge time to 1s from 2s.
  - Shots can be stored for 2s.
  - Base damage range is now 35 (0% charge) to 70 (100% charge) from 10/150.
	- Maximum burst is 140 (280 for structures) at W0. Down from ~170 (340) in vanilla.
	- Maximum DPS is 70 (140 for structures) at W0. Down from ~88 (176) in vanilla.
  - Maximum range set to 30 m and falloff removed.
  - Dual railgun now allows simultaneous firing of both arms.
  - Target highlighting now works on all lifeforms and alien structures (red).
  - Target highlighting now matches maximum range of railgun.
  
### Claw 
  - Reintroduced into the game.
  - Deals 50 structural damage.
  - Range is equal to 2.6.
  - Pierces through multiple targets in range.
  
### Plasma Launcher
  - Energy based weapon. Energy regens over time (20%/s).
  - Plasma bomb projectile:
	- Costs 80% energy per bomb.
	- Direct (35) and DoT Damage (25) in size 4 AoE. 
    - Fires one plasma ball in an arc.
	- Pulse debuff for 5 seconds.
    - Hitbox size of 0.495.
    - Shot speed of 15 m/s.
  - Has custom cinematics and materials.
  - Applies the pulse effect to aliens (reduces animation speed).
	- Pulse effect does not apply to structures.
  - Projectiles spawn on each weapon and are fired towards the crosshair target.
  - Projectiles have dual projectile controller (one for geometry and one for entities) to reduce geo clipping.

### Blowtorch
  - Heat based weapon.
    - Heat buffer is 10s.
	- Cooldown is 5s.
  - Blowtorch welds marines and burns aliens within cone.
    - Damage and welding is SPLIT between all targets.
  - Welds at 1.0x weld rate.
	- 90 eHP/s for structures.
	- 20 eHP/s for marines.
  - Base damage is 8 eHP/s.
	- Flame damage type (bonus damage to structures and flammables)
  - Has custom cinematics and materials.
  - DOES NOT IGNITE ALIEN PLAYERS, STRUCTURES, OR ABILITIES (NO BURNT MARINES ALLOWED)!
  - Target highlighting on all aliens (red) and weldable marines (blue) including structures.
  
### Prototype Lab
  - Advanced prototype lab upgrade required to unlock modular exosuits and cores.
  - Protolabs while researching exotech will show a rotating exo hologram.
  - Protolabs with exotech available will show a static exo inside an orb.
  - Exotech is tied to the specific protolab it was researched on.
  - Exotech will be lost when the protolab gets destroyed or recycled.

### Arc (Robotics) Factory
  - New skin
  - Has two new units to construct:
	- SPARC
	- A-MAC
  - Research time decreased to 15s from 20s.
  
### ARC
  - Build time is now 12.5s from 10s.

### SPARC (ARC Variant)
  - Commander unit built from the ARC Factory.
  - Has purple map icon, custom cinematics, and custom skin.
  - Has 2600 health and 400 armor (same as ARC).
  - Moves at 2.5 m/s speed unless in combat (2.25 m/s in combat).
  - Does NOT deal damage (deals 5 damage for map indicators).
  - Has higher range (30 vs. 26).
  - Can see through fog of war and ink to target alien structures.
  - Applies electrify to alien structures in small AoE.
  - Build time is 10s.
  - Cost 10 tres.

### MACS
  - Macs move 20% faster and have half the line of sight as a drifter.
  - Allow MACs to be welded while taking damage.
  - MACs are 25% smaller (model size).
  - Rollout speed multiplier increased from 2 to 5.
  - MACs can be recycled.
  - MAC repair rate reduced from 50/s to 30/s (matches MAC build efficacy).
  - MAC combat repair rate reduction (90%) removed.
  - AI Changes: (Applies to AMAC as well!)
    - Taking damage no longer prevents MAC from welding.
    - Marine and Exo can request busy MACs for weld with "use" key.
    - MAC won't try to circle behind a Marine who has a welder, or if MAC is far from its leash anchor.
    - MAC stops following marines who phased.
    - Auto search new target to follow if the original died or isn't available.
    - Added Hold position order.
    - Reduced default order search radius to 10m. Hold position order reduces it to 3m.
    - MAC now prioritizes its closest target first.
    - Reduced follow order secondary job search radius to 6m.
    - Changed several local functions into class functions.
    - Enabled battle MAC basic order commands such as Move, Stop and added Hold position.

### A-MAC (MAC Variant)
  - Commander unit built from the ARC factory.
  - Has purple map icon and custom skin.
  - 400 Health.
  - 200 Armor.
  - Cost 15 tres.
  - 20 Supply.
  - Has 100 energy cap (starts at 50).
  - Repair is 60/s and construction efficiency is 60%.
  - Regerates 3 energy / sec.
  - Has Four Commander Abilities:
    - Healing Field: Heals players in AoE over duration (~50 HP total).
	- Catalyst Field: Catpacks players in AoE.
	- Shield Field: Nanoshields players in AoE.
	- Speed Boost: Speed boosts the AMAC by 50%.
  - Healing Field: (Green Cinematic)
    - Cost 20 energy.
	- 10 sec cooldown.
	- Lasts 5s.
  - Catalyst Field: (Red Cinematic)
    - Cost 30 energy.
	- 10 sec cooldown.
	- Lasts 5s.
	- Requires Advanced Assistance.
  - Shield Field: (Blue Cinematic)
    - Cost 70 energy.
	- 10 sec cooldown
	- Lasts 3s
	- Requires Advanced Assistance.
  - Speed Boost:
    - Cost 20 energy.
	- 10 sec cooldown
	- Lasts 5s

### Sentry
  - Attack cone increased to 360 degrees from 135 degrees.
  - Requires room power instead of sentry battery.
  - Outer build range cannot overlap with another sentry.
  - Two sentries can not be placed in the same room.
  - Sentry supply cost reduced from 15 to 10.
  - Cost 6 tres.
  - 8s Buildtime.
  - Limited to 2.
  - Removed weld override (welds at same rate as other structures).

### Power (formerly Sentry) Battery
  - Provides power to nearby marine structures.
  - Provided power does not require room power.
  - Power battery supply cost changed from 25 to 10.
  - Power lines drawn to all potentially powered structures before placement.
  - Health/Armor increased to 1000/250.

### Structure Damage Rework
  - Buffed clogs, hydras, harvester, tunnels, and upgrade chambers eHP by ~15%
  - Balanced hive and support structure eHP (see alien section for details).
  - Buffed Arc Damage by 15%
  - Buffed Gorge Structure Healing by 15%
  - Every weapon upgrade does +20% structure damage (instead of + 10%)
    - W1 → +10% to lifeforms / +20% to structures
    - W2 → +20% to lifeforms / +40% to structures
    - W3 → +30% to lifeforms / +60% to structures
  - FT and GL scale at 10% (20% structure) instead of 7%
  - W0 GL → 65 Player / 260 Structure from 74.4 Player Damage
  - W0 FT → 9 Player / 18 Structure from 9.9 Player Damage
  - Cluster damage type modifier increased from 2.5 to 2.875.

### Electrify Debuff (pulse/plasma/SPARC)
  - TLDR: Disables passives, reduces movement speed, and slows alien attacks and abilities.
  - Electrify slow on players increased to 30% from 20% (vanilla).
  - Electrify now works on structures (including fortress variants):
    - Whips: Prevents slapping / bombarding, reduces movement speed.
    - Hydra: Prevents spiking.
    - Crag: Prevents healing and douse, reduces movement speed.
    - Shift: Prevents energize and stormcloud, reduces movement speed.
    - Shade: Prevents cloaking and sonar, reduces movement speed.
    - Hive: Reduces healing by 33%.
    - Shell: Prevents healing.
    - Spur: Prevents movement.
    - Veils: Prevents cloaking.
  - NOTE: Active abilities still can be used if electrified!

### Advanced Support
  - Advanced support to 15 tres, nano shield cost reduction to 2
  - Catpacked marines now build and weld faster 12.5% as well
  - Nanoshield cost reduced to 2 (from 5)

### Misc Changes
  - Pulse grenade debuff range increased by 50%, based damage set to 40, and given a 10 damage DoT.
  - Cluster grenade range and fragment range reduced by 20%.
  - ARCs dont deal damage to other ARCS anymore.
  - ARCs can manually target hydras and cysts.
  - Don't exploit to get more than 5 arcs. You have been warned...
  - Selfdamage reduced by 66% (grenades/mines).
  - Dropping mines cost 5 tres (from 7 tres).
  - Dropping welders cost 2 tres (from 3 tres).
  - Autopickup for welders reduced from 5 to 1 second.
  
### Status Icons
  - New status icon for webbed status (web, stomp, whip webbing).
  - New status icons for fortress structure passives.
  - Display status icons even with minimal hud elements.

## ALIEN
### Hives
  - Based eHP decreased to be +7.5% of vanilla.
  - Gains +2.5% eHP per hive biomass returned to current value after final biomass upgrade.

### Veil/Spur/Shell
  - Veils: Cloaked
  - Spurs: Moveable (50% movement speed)
  - Shells: Selfheal (1% each healingcycle)

### Rage
  - Replaces Heat Plating
  - Increases energy regeneration rate for 3s after taking damage (+16.67% per shell).

### Aura
  - No longer reveals health information (moved to Fortress Shade)
  - Icon is always yellow.
  
### Camouflage
  - Shaders completely reworked to ensure camo is competitive with other upgrades.
  - Cloaking reveal range, and rate depend more heavily on veil amount.
  - Onos are silent when crouching with cloak.
  - UI icon only appears when fully cloaked.

### Support Structures
  - Reduced cost to 8 tres from 13 tres.
  - Base speed increased by 25%.
  - eHP changed to better unify TTK
  - eHP for Shift/Crag/Shade/Whip is now 600/600/600/750 at 0% maturity.
  - eHP for Shift/Crag/Shade/Whip is now 1100/1100/1100/1100 at 100% maturity.
  - GUIs updated to accommodate new passives.
  - Crag
    - Healwave replaced with Shieldwave.
    - Shieldwave applies full overshield to aliens over duration.
  - Whip
	- Fully matured whips attack without infestation.
	- Increased turning speed before moving.
  - Shift
    - Reduced energy regenerate rate by 50%

### Fortress Structures
  - Starting eHP reduced to 1400/1400/1400/2800 at 0% maturity and 1 biomass.
  - Starting eHP reduced to 2000/2000/2000/3400 at 100% maturity and 1 biomass.
  - Fotress whip gains 50 HP per biomass and has a max of 200 armor.
  - Fortress structures move 25% slower than regular PvE on infestation (2.9 m/s).
    - Fortress structures gradually slow to 1.45/1.45/1.45/2.175 m/s off infestation.
	- Fortress abilities do not work while moving.
  - New passives when specific hive tech is researched.
  - Fortress structure passives are only active when structure is stationary.
  - New UI element for passives and updated tooltips.
  - Fortress upgrade costs 20 tres
  - Fortress Shift:
    - Stormcloud now auto-casts every 5s.
	- Stormcloud's buff now lasts 5s outside of Fortress Shift range.
	- Stormcloud gives a flat speed buff (+1.5/1.5/1.25/0.75 m/s) depending on spur level (0/1/2/3). 
	- The max possible net speed depending on spur level (0/1/2/3) with stormcloud is 1.5/2.0/2.25/2.25 m/s.
	  - Fade, skulks, and lerks capped at +1.5 m/s.
	- Spawns eggs around Fortress Shift when Shift Hive is researched.
	- Will only spawn eggs if less than 3 FShift eggs exist.
  - Fortress Crag:
    - Applies douse every 2s which grants immunity to fire debuffs on alien players and structures.
	- Douse applies a 5% structure damage reduction and lasts 3s.
	- Douse is applied in inner fortress crag radius.
	- Douse has custom magenta shader and stacks with umbra.
  - Fortress Shade:
    - Hallucinations ability is now free (does not auto-cast) and has a 60s cooldown.
	- Hallucinations no longer provide vision and move slowly.
    - Blights (reveals eHP and location) marines in range for 6s every 5s when Shade Hive is researched.
    - Highlight is colored blue, magenta, or red depending on number of PRIMARY attacks (accounts for focus and crush) or eHP.
    - For players: >2 blue, 2 to 1 magenta, <=1 red
    - For structures: >66% blue, 66% to 33% magenta, <33% red
  - Fortress Whip:
    - Bile frenzy spawns three bile bombs and temporarily increases whip movement speed.
    - Crag Hive: Siphoning Slaps (75 eHP gained on player slap hit)
    - Shift Hive: Whip Webbing (bile splash, slaps, and bombard slows targets for 3.0s duration - works on exos too!)
    - Shade Hive: Ocular Parasite (all attacks parasite targets and whippy will self-camo)
    - Bile splash made free and only avaliable on fortress whip.

### Gorges
  - Babblers
    - Babblers will now detach around the gorge instead of everyone at same location above the gorge.
    - Babblers will stay out for at least the duration of the babbler ball.
	- Babblers are now affected by crush upgrade.
  - Babblerbomb
    - Bio 7 gorge ability researchable on hive (15 tres).
    - Gorge spews out babbler filled egg that explodes on impact.
    - Egg filled with 6 independent babblers that die after 5s.
    - Limited to 3 charges that fill over 10s each.
  - Hydras and Bilemine cost 30% less energy
  - Bile damage accelerates weapon expiration
    - 1 Bile ~ 5 seconds

### Stomp
  - No longer knocks marines.
  - Applies web debuff.
  - Damage increased from 40 to 50 heavy damage.
  - Improved terrain pathing.
  - Added proper check for marine jumping.
 
### Focus
  - Properly affects Stab ability now.
  - Fixed bug which slowed Gore by 57% instead of 33%.
  - Gorges now get a 1.5x damage buff instead of a 1.33x buff.

### Stab
  - Stab research cost reduced from 25 to 20 tres.
  - Stab energy cost reduced by 16%.
 
### Swapping Trait Cost
  - Swapping to another trait from the same chamber costs less:  
    - Skulk: 0 (Same as vanilla)
    - Gorge: 1 (Same as vanilla)
    - Lerk: 2 (Changed)
    - Fade: 3 (Changed)
    - Onos: 4 (Changed)

### Bonewall
  - Buffed eHP per biomass from 115 to 140 (~25% increase).

### Drifter
  - Increased mucous area of effect to the same size as enzymes.
  - Doesn't follow echoed unfinished structures over the entire map anymore.
  - Doesn't autobuild hydras or bilemines anymore (khammander QoL).
  - Cloaking Haze (Replaced Hallucination Cloud)
    - Cloaks players, eggs and drifters (including those in combat) for up to 5 seconds.
 
## QoL / General Improvements
  - Player and structure highlight shader made more pronounced to improve visual acuity.
  - Changed point rewards for building structures from 4 points to be tied to the buildtime.
  - Removed point reward for building hydras.
  - Rerouted techs to illustrate proper tech and structure requirements.
  - Replaced babblertech and webs with nutrientmist at bio 1.
  - Improved nanoshield surface shader so that it more clearly appears on all entities.
  
### Minimap
  - Players are able to see if a hive is at <34%, <67% or <=100% maturity
  - Added Icon for occupied Hive/Chair
  - Added Icon for Jetpackers
  - Added Icon for matured Whips
  - Added Icon for Drifter Eggs
  - Added Icon for deployed ARCS
  - Added Icon for Advanced Armory
  - Added Icons for Fortress PvE
  - Alien Commander is able to see parasited mines

## Vanilla Bugfixes
  - Web variant nil value console spam should no longer occur.
  - Electrify no longer applies energy regeneration debuff.
  - ARC trigger effect triggering on EVERY live entity in the game instead of just applicable damage targets.
  - Fixed ARC error / crash when manually targeting clogs.
  - Armslabs while researching will show a rotating hologram.
  - Fixed various visual bugs with updating tech.
  - Jetpackers will no longer be affected by stomp when slightly above the ground.
  - Alien PvE bounces/glitches less during and after moving.
  - Flying flamethrowers in rare cases should not crash the server anymore (vanilla bug).
  - Rollout crash fixed.
  - Fix to cinematics of projectiles desyncing.
  - Fix to pistol shot queuing not registering inputs.

<br />
<br />

# Revision 2.0.3 (2023/12/23)
## ALIEN
### Hives
  - Reduced the additional 10% HP buff for maturity hives to 5%

### Stab
  - Stab research cost reduced from 25 to 20 tres
  - Stab energy cost reduced by 16%

### Fortress Shade
  - Hallucinations time duration removed
  - Able to transform into a random different structure
  - Added HP bars on hallucinations

### Whips
  - Increased turning speed before moving
  - Decreased rooting, unrooting time under frenzy
  - Reduced the cost of bile splash from 3 to 2 tres

### Fortress Structures
  - Converted 50% of their armor into HP (nerf to healing)
  - Increased cooldown for all fortress abilities from 10 to 15 seconds
  - Reduced the cost of all fortress abilities from 3 to 2 tres
  - Fixed a bug which allowed abilities to being cast while under fire
  - No longer take 3x the damage off infestation in comparison to normal structures

### Drifter
  - Increased mucous area of effect to the same size as enzymes
  - Doesnt follow echoed unfinished structures over the entire map anymore
  
## MARINE
### Bugfixes 
  - Flying flamethrowers in rare cases should not crash the server anymore (vanilla bug)
  - Bot Commanders will research Exos, Weapon 3, Armor 3 again (balance mod bug)

# Revision 2.0.2 (2023/11/28)

## ALIEN
### Crag/Shift/Shade/Whip
  - Changed fortress PvE upgrade time to 25 seconds, up from 10
  - Shift energy regen nerf is now 50% the vanilla value (from 66% nerf)

### Onos
  - Onos with camoflague will be silent while crouch walking
  - Stomp particles reduced (this should improve performance)

### Heatplating 
  - Changed heatplating description in evolve menu to "Reduced damage from mines, grenades, flames and railguns"
  - Gas grenades now deal reduced damage with heatplating to match other hand grenades

### Hallucinations
  - Increased lifetime from 120 seconds to 600 seconds
  - Added ability to change hallucination into a copy of a valid target

## MARINE
### Advanced Support
  - Advanced support to 15 tres
  - Catpacked marines now build and weld 12.5% faster as well
  - Nanoshield cost reduced to 2 (from 3)

### MACs
  - Increased the MAC Playchatsound cooldown - MACs will talk less when selected (from 2 to 10 seconds) 
  - Allow MACs to be welded while taking damage

### Hand Grenades
  - Cluster grenade range and fragment range reduced by 20%

# Revision 2.0.1 (2023/10/21)
## ALIEN
### Crag/Shift/Shade/Whip
  - Reduced cost to 8 tres from 13 tres
  - Reduced modelsize by 20%
  - Reduced HP by 20%
  - Changed Whip/Shade movement speed to be in line with Crag/Shift
  - Increased Speed by 25%

### Fortress Crag/Shift/Shade/Whip
  - Upgradeable version for 24 tres research cost
  - Normal modelsize
  - Increased HP to 300%
  - Reduced Speed by 25%
  - Cannot be echo'd
  - Restricted to max 1 of each kind
  - Are able to use ink, echo and healwave without a hivetype
  - Access to a new ability with the corresponding hive type (3 tres, 10 sec cooldown)
    - Umbra(Crag): Cast Umbra for 5 seconds on all Structures in healrange
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
  - Veils: Cloaked
  - Spurs: Moveable (50% movement speed)
  - Shells: Selfheal (1% each healing cycle)

### Focus
  - affects Stab ability now
  - fixed bug which slowed Gore by 57% instead of 33%

### Gorge
  - Hydras and Bilemine cost 30% less energy

## Marine
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

### Equipment Balance Changes
  - Dropping mines cost 5 tres (from 7 tres)
  - Dropping welders cost 2 tres (from 3 tres)
  - Autopickup for welders reduced from 5 to 1 second
  - ARCs dont deal damage to other ARCS anymore
  - Selfdamage reduced by 66% (grenades/mines)
  - Bile damage accelerates weapon expiration
    - 1 Bile ~ 5 seconds
  - Macs move 20% faster and have half the line of sight as a drifter
  - Pulse gernade debuff range increased by 50%

## QoL 
  - Marines start with 2 IPs at 7+ players instead of 9+ players
  - Alien PvE bounces/glitches less during and after moving
  - Jetpackers will no longer be affected by stomp when slightly above the ground

### HUD
  - New Advanced Option (HUD) "STATUS ICONS"
    - Display status icons even with minimal hud elements

### Minimap rework
  - Players are able to see if a hive is at <34%, <67% or <=100% maturity
  - Added Icon for occupied Hive/Chair
  - Added Icon for Jetpackers
  - Added Icon for matured Whips
  - Added Icon for Drifter Eggs
  - Added Icon for deployed ARCS
  - Added Icon for Advanced Armory
  - Added Icons for Fortress PvE
  - Alien Commander is able to see parasited mines

# Revision 1.5.2 - (2023/08/05)
## ALIEN
### Cloak
  - Cloaked units' minimap and model visibility based upon proximity corresponding to amount of veils (8m/6m/4m)
  - Player and drifter eggs are now invisible while under the effect of cloak
  - Cloaking-in rate is now fixed at 3 (over 0.33s)
  - Cloaking at 40.1% effectiveness is considered Fully Cloaked, no longer show on enemy minimap and evade AI targetting
  - Combat-passive alien units partially decloak, and have shorter cloaking delay (1.5s instead of 2.5) after taking damage, scanned or touched
  - Cloaking effect is applied normally again
  - Cyst uncloak proximity radius change reverted
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
  - Cloaking at 40.6% effectiveness is considered Fully Cloaked, and sneaking aliens longer show blips on enemy minimap, and evade AI targetting
  - Moving Alien players drop below Fully Cloaked threshold when their default max speed is reached
  - (UI) Changed alien cloak status icon to show only when Fully cloaked
  - Combat-passive alien units partially decloak, and have shorter cloaking delay (1.5s instead of 2.5) after taking damage, scanned or touched
  - Cloaking effect is applied faster, and fades slower
  - Camouflage upgrade slows decloaking rate per level
  - Cloaking shader tweaked to be more consistent across different backgrounds. It now darkens as it decloaks and includes high frequency distortions to visually camouflage better over distance.
  - Cyst uncloak proximity radius reduced from 8 to 6
  - Lerk speed scalar (used to scale cloaking and sound) tweaked
- Swapping Trait Cost
  - Swapping to another trait from the same chamber costs less:
    - Skulk: 0 (Same as vanilla)
    - Gorge: 1 (Same as vanilla)
    - Lerk: 2 (Changed)
    - Fade: 3 (Changed)
    - Onos: 4 (Changed)


### Shade Hive
- Hallucination Cloud
  - Replaced Hallucination Cloud with Cloaking Haze, cloaks players, eggs and drifters (including those in combat) for up to 5 seconds
  - Hallucinated Hive and Harvester will still spawn in their allocated positions
  - Ink Cloud (& Lesser Ink Cloud) provides enhanced cloaking for 1 second, removes sighted status, and gives improved visual camouflage (minimum 20%) even when in combat
  - Cloaked Whips are more visible (same as players)

## Marines
### Grenades
 - Pulse Grenade
  - Increased damage from 50 to 60

### Protolab
- Exotech
  - Exotech is tied to the specific protolab it was researched on
  - Exotech will be lost when the protolab gets destroyed or recycled

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
  - Positive status effects include umbra, enzyme (drifter ability), and mucous membrane (drifter ability)
  - Positive status effects like umbra will not be removed when players are set on fire with resilience
  - Negative status effects include nerve gas dot, flamer dot, and pulse slow
  - You must have resilience to receive the increased duration of buffs

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
