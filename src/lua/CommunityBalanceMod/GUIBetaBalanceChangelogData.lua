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

#TLDR (v2.6.0 to v2.7.0): (?/?/2025)
  - Sentries reworked to independent supporting fire structure.
  - Sentry Battery reworked to Power Battery.
  - Electrify (pulse/plasma/D-ARC) debuff extended to structures.
  - New commander unit added: D-ARC.
  - New exosuit arm added: Blowtorch.
  - Healwave reworked to Shieldwave.
  
#TLDR (v2.5.2 to v2.6.0): (3/2/2025)
  - Full codebase refactored. More than 100 excess files removed.
  - All alien PvE health and armor rebalanced and unified.
  - Fortress structures faster on infestation and slow down off infestation.
  - Hive and fortress structure biomass health scaling added (less up to current eHP)
  - Fade and skulk movement with stormcloud nerfed/fixed.
  - Fortress shade passive sonar ability revamped with blight (reveal health and location of marine players and structures) and larger outer radius.
  - Aura no longer reveals health information.
  - Fortress crag douse now has new graphics and a proper mixin.
  - Fortress whip reworked with new hive based passives. 
  - Fortress whip frenzy and bile splash ability merged with attack speed buff removed and speed buff nerfed.
  - Babblerbomb (late game gorge ability) added.
  - Plasma launcher bugs fixed and simplified (bomb is only mode now).
  - Electrify buffed from a 20% to 30% animation slow (plasma/pulse debuff).
  - Cluster grenade correctly buffed to match previous structure damage rebalance.
  - Single arm exos now require the advanced prototypelab (exosuit research).

#TLDR (v2.5.1 to v2.5.2): (9/7/2024)
  - Fortress structure abilities swapped to auto-cast, rebalanced, and given new unique passives.
  - Pulse damage reverted to 50.
  - Exos given speed cap of 7.25 m/s (same as base skulk ground speed).
  - Changed plasma bomb direct damage to mini-AoE to improve consistency.
  - Fixed bug for plasma launcher where DoT was applied but pulse debuff was not.
  - Fixed bug for exosuit purchase saying insufficient pres when you could buy an exo.

#TLDR (v2.5.0 to v2.5.1): (8/13/2024)
  - Plasma Launcher (big) buff (damage increase, hitbox increase, and dual projectile controller added).
  - Railgun nerf (charge time and damage nerf)
  - Nano-repair core nerf (minimum activation energy increased).
  - Thruster core nerf (minimum activation energy increased and energy cost increased).

# TLDR (v2.0.3 to v2.5.0): (7/11/2024)
  - Exosuits have been made Modular (selectable arms and cores).
  - Railgun arm has been reworked.
  - Claw arm has been reintroduced.
  - New Plasma Launcher exo weapon.
  - New Core upgrades for exosuits.
  - New upgrade replacement for heatplating (rage).

# Changes between Revision v2.7.0 and v2.0.3: (?/?/2025)
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
	- Nano Repair: Increase self-weld speed at the cost of energy (+0.025 Weight). Min 50% activation energy required.
	- Thruster: Increases movement speed and allows for flight at the cost of energy (+0.05 Weight). Min 25% activation energy required.

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
  - Target highlighting now works on all lifeforms and alien structures.
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
	- Direct (30) and DoT Damage (25) in size 4 AoE.
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
  
### Prototype Lab
  - Advanced prototype lab upgrade required to unlock modular exosuits and cores.
  
### D-ARC
  - Commander unit built from the ARC Factory.
  - Has same health and movement stats as ARC.
  - Does NOT deal damage.
  - Has higher range (30 vs. 26).
  - Can see through fog of war and ink to target alien structures.
  - Applies electrify to alien structures in small AoE.
  - Has custom cinematics and materials.

### Sentry
  - Attack cone increased to 360 degrees from 135 degrees.
  - Requires room power instead of sentry battery.
  - Cannot overlap range with another sentry.
  - Sentry supply cost reduced from 15 to 10.

### Power (formerly Sentry) Battery
  - Provides power to nearby marine structures.
  - Provided power does not require room power.
  - Can be upgraded into “Shielding Power Battery.”
  - Power battery supply cost changed from 25 to 20.
  - Power lines drawn to all potentially powered structures before placement.

### Shielding Power Battery
  - 10 tres cost upgrade to Power Battery.
  - Upgrade has 20s research time.
  - Health/Armor: 1000/400 (up from 600/200)
  - Functionality WIP

### Electrify Debuff (pulse/plasma/D-ARC)
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

### Misc Changes
  - Pulse damage reverted to 50.
  - Cluster damage type modifier properly increased from 2.5 to 2.875 (should prevent fully mature cysts from living).
  - 8v8 starting state now has +10 tres and one IP.
  - 7v7 starting state now has +5 tres and one IP.
  
### QoL
  - New status icon for webbed status (web, stomp, whip webbing).
  - New status icons for fortress structure passives.

## ALIEN
### Rage
  - Replaces Heat Plating
  - Increases energy regeneration rate for 3s after taking damage (+16.67% per shell).

### Aura
  - No longer reveals health information (moved to Fortress Shade)
  - Icon is always yellow.
  
### Camouflage
  - Nerfed to be weaker for single veil.
  - Nerfed on lerks to be more sensitive to flight speed.
  - Nerfed to be more visible during combat.

### Hives
  - Based eHP decreased to be +7.5% of vanilla.
  - Gains +2.5% eHP per hive biomass returned to current value after final biomass upgrade.

### Regular Structures
  - eHP changed to better unify TTK
  - eHP for Shift/Crag/Shade/Whip is now 600/600/600/750 at 0% maturity.
  - eHP for Shift/Crag/Shade/Whip is now 1100/1100/1100/1100 at 100% maturity.
  - GUIs updated to display new passives.
  - Crag
    - Healwave replaced with Shieldwave.
    - Shieldwave applies full overshield to aliens over duration.

### Fortress Structures
  - eHP for Fortress Shift/Crag/Shade/Whip scales with biomass (100/100/100/50).
  - Starting eHP reduced to 2400/2400/2400/2800 at 0% maturity and 1 biomass.
  - Starting eHP reduced to 3000/3000/3000/3400 at 100% maturity and 1 biomass.
  - Current values reached at Biomass 7 and full maturity (3600/3600/3600/3700).
  - Fortress structures move at the same speed as regular PvE on infestation (3.625 m/s).
  - Fortress structures gradually slow to 1.45/1.45/1.45/2.175 m/s off infestation.
  - New passives when specific hive tech is researched.
  - New UI element for passives and updated tooltips.
  - Fortress Shift
    - Stormcloud now auto-casts every 10s.
	- Stormcloud's buff now lasts 5s outside of Fortress Shift range.
	- Stormcloud gives a flat speed buff (+1.5/1.5/1.25/0.75 m/s) depending on spur level (0/1/2/3). 
	- The max possible net speed depending on spur level (0/1/2/3) with stormcloud is 1.5/2.0/2.25/2.25 m/s.
	  - Fade and lerks capped at +1.75 m/s.
	- Moves 50% faster off infestation when Shift Hive is researched.
  - Fortress Crag
    - Applies douse every 2s which grants immunity to fire debuffs on alien players and structures.
	- Douse applies a 5% damage reduction and lasts 3s.
	- Douse is applied in outer fortress crag radius.
	- Douse has custom magenta shader and stacks with umbra.
  - Fortress Shade
    - Hallucinations ability is now free (does not auto-cast) and has a 60s cooldown.
	- Hallucinations no longer provide vision and move slowly.
    - Blights (reveals eHP and location) marines in range for 6s every 5s when Shade Hive is researched.
    - Highlight is colored blue, magenta, or red depending on eHP.
    - For players: >225 blue, 225 to 150 magenta, <150 red
    - For structures: >66% blue, 66% to 33% magenta, <33% red
  - Fortress Whip
    - Bile frenzy spawns three bile bombs and temporarily increases whip movement speed.
    - Crag Hive: Siphoning Slaps (75 eHP gained on player slap hit)
    - Shift Hive: Whip Webbing (bile splash and bombard slows targets for 2.5s duration - works on exos too!)
    - Shade Hive: Ocular Parasite (all attacks parasite targets and whippy will self-camo)
    - Bile splash made free and only avaliable on fortress whip.
	
### Babblerbomb
  - Bio 7 gorge ability researchable on hive (15 tres).
  - Gorge spews out babbler filled egg that explodes on impact.
  - Egg filled with 6 independent babblers that die after 5s.
  - Limited to 12 babbler bomb babblers at a time.
  
### QoL
  - Player and structure highlight shader made more pronounced to improve visual acuity.

## Vanilla Bugfixes
  - Web variant nil value console spam should no longer occur.
  - Electrify no longer applies energy regeneration debuff.
  - ARC trigger effect triggering on EVERY live entity in the game instead of just applicable damage targets.
]]
