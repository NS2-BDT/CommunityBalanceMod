-- ====**** Scripts\GUIBetaBalanceChangelogData.lua ****====
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

#TLDR of v2.7.0 Changes: (?/?/2025)
  - Sentries reworked to independent supporting fire structure.
  - Sentry Battery reworked to Power Battery.
  - Electrify (pulse/plasma/SPARC) debuff extended to structures.
	- Pulse and plasma AoE damage scales per player.
  - New commander units added: SPARC and A-MAC.
  - MAC QoL changes
  - New exosuit arm added: Blowtorch.
  - New marine weapon added: Sub Machine Gun.
  - Healwave reworked to Shieldwave.
  - Fortress structure balance adjustments.
    - FShade sonar ability damage indicator cutoffs set based on lifeform damage and accounts for focus and crush.
	- FShift spawns eggs slowly over time.
  
#TLDR of v2.7.0 and Vanilla: (?/?/2025)
  - Reworks to marines structures (sentry and sentry battery)
  - New commander units (SPARC and A-MAC) and infantry weapons (SMG).
  - Modular exosuits with new exo arms (plasma launcher and blowtorch) and upgrades.
  - Scaling structure damage with weapon upgrades.
  - Reworks and balance of some alien traits (carapace and aura) and trait swapping.
  - New khammander units (Fortress crag, shift, shade, and whip) with powerful abilites.
  - Major rebalance of alien PvE.
  - Massive improvements to MACs and drifters.
  - New map icons for alien and marine structures and units.
  - Various QoL, game improvements, and bugfixes.
  - Custom skins and cinematics for new content.
  
# Changes between v2.7.0 and Vanilla: (?/?/2025)
## MARINE
### Modular Exosuits
  - Exosuits changed to have swappable arms and cores (pres refunds disabled when swapping arms/cores).
  - Base kit thruster replaced with jump (exos can no longer sprint by default).
  - Base Armor is 200 (+30 per armor level) and base speed is 6 m/s.
  - Additional armor/weight(inverse of speed)/pres cost is dependent on selected arms:
	- Railgun: 25/0.1/20
	- Minigun: 100/0.2/25
	- Plasma Launcher: 50/0.125/15
	- Blowtorch: 25/0.1/15
	- Claw: 0/0.0/5
  - Cores - Optional Upgrade: (cost 10 additional pres)
	- Armor: Adds +50 Armor (+0.075 Weight).
	- Nano Repair: Increase self-weld speed at the cost of energy (+0.025 Weight).
	  - Min 50% activation energy required.
	- Thruster: Increases movement speed and allows for flight at the cost of energy (+0.05 Weight). 
	  - Min 25% activation energy required.

### Railgun 
  - Railgun reworked to be more forgiving and less "bursty".
  - Firing cooldown set to 1s from 1.4s.
  - Charge time to 1s from 2s.
  - Shots can be stored for 2s.
  - Base damage range is now 30 (0% charge) to 60 (100% charge) from 10/150.
	- Maximum burst is 120 (240 for structures) at W0. Down from ~170 (340) in vanilla.
	- Maximum DPS is 60 (120 for structures) at W0. Down from ~88 (176) in vanilla.
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
	- Damage scales by 2.5 per player hit, down to 30. 
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
  - Welds at 1.5x weld rate.
	- 135 eHP/s for structures.
	- 30 eHP/s for marines.
	- Provides minimal self-welding.
  - Base damage is 12 eHP/s.
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

### SPARC (ARC Variant)
  - Commander unit built from the ARC Factory.
  - Has purple map icon, custom cinematics, and custom skin.
  - Has same health and movement stats as ARC.
  - Does NOT deal damage.
  - Has higher range (30 vs. 26).
  - Can see through fog of war and ink to target alien structures.
  - Applies electrify to alien structures in small AoE.

### MACS
  - Macs move 20% faster and have half the line of sight as a drifter.
  - Allow MACs to be welded while taking damage.
  - MACs are 25% smaller (model size).
  - Rollout speed multiplier increased from 2 to 5.
  - MACs can be recycled.

### A-MAC (MAC Variant)
  - Commander unit built from the ARC factory.
  - Has purple map icon and custom skin.
  - 500 Health.
  - 250 Armor.
  - Cost 10 tres.
  - 20 Supply.
  - Has Three Commander Abilities:
    - Healing Field: Heals players in AoE over duration (~50 HP total).
	- Catalyst Field: Catpacks players in AoE.
	- Shield Field: Nanoshields players in AoE.
  - Healing Field: (Green Cinematic)
    - Cost 3 tres.
	- 10 sec cooldown.
	- Lasts 5s.
  - Catalyst Field: (Red Cinematic)
    - Cost 7 tres.
	- 10 sec cooldown.
	- Lasts 5s.
	- Requires Advanced Assistance.
  - Shield Field: (Blue Cinematic)
    - Cost 7 tres
	- 10 sec cooldown
	- Lasts 5s
	- Requires Advanced Assistance.

### Sentry
  - Attack cone increased to 360 degrees from 135 degrees.
  - Requires room power instead of sentry battery.
  - Cannot overlap range with another sentry.
  - Sentry supply cost reduced from 15 to 10.
  - Cost 6 tres.
  - 8s Buildtime.
  - Limited to 3.
  - Locale updated.

### Power (formerly Sentry) Battery
  - Provides power to nearby marine structures.
  - Provided power does not require room power.
  - Can be upgraded into “Shielding Power Battery.”
  - Power battery supply cost changed from 25 to 20.
  - Power lines drawn to all potentially powered structures before placement.

### Sub Machine Gun
  - Alternate machine gun weapon unlocked with shotguns.
  - Tiered between LMG and HMG.
  - 35 bullet mags.
  - 6 total mags.
  - 12 (normal) base damage.
  - 1s reload.
  - Costs 15 pres.
  - Weighs 0.05.
  
### Structure Damage Rework
  - Buffed all Alien Structures HP by ~15% (see alien section for details)
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
    - Hive: Reduces healing.
    - Shell: Prevents healing.
    - Spur: Prevents movement.
    - Veils: Prevents cloaking.
  - NOTE: Active abilities still can be used if electrified!

### Advanced Support
  - Advanced support to 15 tres, nano shield cost reduction to 2
  - Catpacked marines now build and weld faster 12.5% as well
  - Nanoshield cost reduced to 2 (from 5)

### Misc Changes
  - Pulse grenade debuff range increased by 50% and damage scales by 5, down to 30 per player.
  - Cluster grenade range and fragment range reduced by 20%
  - 8v8 starting state now has +10 tres and one IP.
  - 7v7 starting state now has +5 tres and one IP.
  - ARCs dont deal damage to other ARCS anymore
  - Selfdamage reduced by 66% (grenades/mines)
  - Dropping mines cost 5 tres (from 7 tres)
  - Dropping welders cost 2 tres (from 3 tres)
  - Autopickup for welders reduced from 5 to 1 second
  
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

### Regular Structures
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
  - eHP for Fortress Shift/Crag/Shade/Whip scales with biomass (100/100/100/50).
  - Starting eHP reduced to 2400/2400/2400/2800 at 0% maturity and 1 biomass.
  - Starting eHP reduced to 3000/3000/3000/3400 at 100% maturity and 1 biomass.
  - Current values reached at Biomass 7 and full maturity (3600/3600/3600/3700).
  - Fortress structures move at the same speed as regular PvE on infestation (3.625 m/s).
  - Fortress structures gradually slow to 1.45/1.45/1.45/2.175 m/s off infestation.
  - New passives when specific hive tech is researched.
  - Fortress structure passives are only active when structure is stationary.
  - New UI element for passives and updated tooltips.
  - Fortress Shift:
    - Stormcloud now auto-casts every 5s.
	- Stormcloud's buff now lasts 5s outside of Fortress Shift range.
	- Stormcloud gives a flat speed buff (+1.5/1.5/1.25/0.75 m/s) depending on spur level (0/1/2/3). 
	- The max possible net speed depending on spur level (0/1/2/3) with stormcloud is 1.5/2.0/2.25/2.25 m/s.
	  - Fade and lerks capped at +1.75 m/s.
	- Spawns eggs around Fortress Shift when Shift Hive is researched.
	- Will only spawn eggs if less than 3 eggs are present in a room.
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
    - Babblers will now detach around the gorge instead of everyone at same location above the gorge
    - Babblers will stay out for at least the duration of the babbler ball
  - Babblerbomb
    - Bio 7 gorge ability researchable on hive (15 tres).
    - Gorge spews out babbler filled egg that explodes on impact.
    - Egg filled with 6 independent babblers that die after 5s.
    - Limited to 12 babbler bomb babblers at a time.
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

### Stab
  - Stab research cost reduced from 25 to 20 tres.
  - Stab energy cost reduced by 16%.
 
###Swapping Trait Cost
  - Swapping to another trait from the same chamber costs less:  
      Skulk: 0 (Same as vanilla)
      Gorge: 1 (Same as vanilla)
      Lerk: 2 (Changed)
      Fade: 3 (Changed)
      Onos: 4 (Changed)

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
  - Armslabs while researching will show a rotating hologram.
  - Fixed various visual bugs with updating tech.
  - Jetpackers will no longer be affected by stomp when slightly above the ground.
  - Alien PvE bounces/glitches less during and after moving.
  - Flying flamethrowers in rare cases should not crash the server anymore (vanilla bug).
  - Rollout crash fixed.
]]
