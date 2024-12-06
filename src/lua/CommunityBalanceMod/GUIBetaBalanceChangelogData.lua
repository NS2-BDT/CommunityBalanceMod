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

#TLDR (v2.5.2 to v2.6.0): (12/7/2024)
  - Full codebase refactored. More than 100 excess files removed.
  - All alien PvE health and armor rebalanced and unified.
  - Fortress structures faster on infestation and slow down off infestation.
  - Hive and fortress structure biomass health scaling added (less up to current eHP)
  - Fade and skulk movement with stormcloud nerfed/fixed.
  - Fortress shade passive sonar ability revamped with blight (reveal health and location of marine players and structures) and larger outer radius.
  - Aura no longer reveals health information.
  - Fortress whip reworked with new hive based passives. Frenzy removed.
  - Plasma launcher bugs fixed and simplified (bomb is only mode now).
  - Babblerbomb (late game gorge ability) added.

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

# Changes between Revision v2.6.0 and v2.0.3: (12/7/2024)
## MARINE
### Modular Exosuits
  - Exosuits changed to have swappable arms and cores (pres refunds disabled when swapping arms/cores).
  - Base kit thruster replaced with jump (exos can no longer sprint by default).
  - Base Armor is 200 (+30 per armor level) and base speed is 6 m/s.
  - Additional armor/weight(inverse of speed)/pres cost is dependent on selected arms:
	- Railgun: 25/0.1/20
	- Minigun: 100/0.2/25
	- Plasma Launcher: 50/0.125/20
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
	- Costs 60 energy per bomb.
	- Direct damage (35) in size 2.5 AoE and DoT Damage (75 - linear radial) in size 6 AoE.
    - Fires one plasma ball in an arc.
	- Pulse debuff for 5 seconds.
    - Hitbox size of 0.495.
    - Shot speed of 15 m/s.
  - Has custom cinematics and materials.
  - Applies the pulse effect to aliens (reduces animation speed).
	- Pulse effect does not apply to structures.
  - Projectiles spawn on each weapon and are fired towards the crosshair target.
  - Projectiles have dual projectile controller (one for geometry and one for entities) to reduce geo clipping.
  
### Prototype Lab
  - Single arm exotech is unlocked with prototype lab.
  - Advanced prototype lab upgrade required to unlock dual arm exosuits and cores.
  
### Misc Changes
  - Pulse damage reverted to 50.
  - Eletrify (pulse/plasma debuff) increased to 40% from 20%.
  - Cluster damage type modifier properly increased from 2.5 to 2.875 (should prevent fully mature cysts from living).
  
### QoL
  - New status icon for webbed status (web, stomp, whip webbing).

## ALIEN
### Rage
  - Replaces Heat Plating
  - Increases energy regeneration rate for 3s after taking damage (+16.67% per shell).

### Aura
  - No longer reveals health information (moved to Fortress Shade)
  - Icon is white.

### Parasite
  - Highlight is white.

### Hives
  - Based eHP decreased to be +7.5% of vanilla.
  - Gains +2.5% eHP per hive biomass returned to current value after final biomass upgrade.

### Regular Structures
  - eHP changed to better unify TTK
  - eHP for Shift/Crag/Shade/Whip is now 600/600/600/750 at 0% maturity.
  - eHP for Shift/Crag/Shade/Whip is now 1100/1100/1100/1100 at 100% maturity.
  - Whip no longer has bile splash.
  - GUIs updated to display new passives.

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
	- Moves 50% faster off infestation when Shift Hive is researched.
  - Fortress Crag
    - Structural Umbra now auto-casts every 10s.
	- Structural Umbra lasts 5s.
	- Becomes immune and removes fire debuff of nearby structures every 3.5s when Crag Hive is researched.
  - Fortress Shade
    - Hallucinations is now free (does not auto-cast).
    - Blights (reveals eHP and location) marines in range for 5s every 5s when Shade Hive is researched.
    - Highlight is colored blue, yellow, or red depending on eHP.
    - For players: >225 blue, 225 to 150 yellow, <150 red
    - For structures: >66% blue, 66% to 33% yellow, <33% red
  - Fortress Whip
    - Frenzy removed in favor of hive based passives.
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
  - Player and structure highlight shader made more pronouced to improve visual acuity.

]]
