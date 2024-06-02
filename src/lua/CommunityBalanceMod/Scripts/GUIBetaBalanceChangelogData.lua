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

# TLDR (v2.0.3 to v2.5.0):
  - Exosuits have been made Modular (selectable arms and cores).
  - Railgun arm has been reworked.
  - Claw arm has been reintroduced.
  - New Plasma Launcher exo weapon.
  - New Core upgrades for exosuits.
  - New upgrade replacement for heatplating (rage).
  - New biomass 7 upgrade for gorges (babbler bomb).

# Changes between Revision 2.5.0 and 2.0.3: (2024/5/24)
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
	- Nano Repair: Increase self-weld speed at the cost of energy (+0.025 Weight).
	- Thruster: Increases movement speed and allows for flight at the cost of energy (+0.05 Weight).

### Railgun 
  - Railgun reworked to be more forgiving and less "bursty".
  - Firing cooldown set to 1s from 1.4s.
  - Charge time to 0.5s from 2s.
  - Shots can be stored for 2s.
  - Base damage range is now 45 (0% charge) to 60 (100% charge) from 10/150.
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
  - Charge based weapon with two distinct shotting modes.
	- Multi-Shot: Direct damage in size 2 AoE. More charge equals more shots up to 5.
	- Bomb: Direct damage on impact and DoT Damage in size 4 AoE. 
  - Each mode of shot has custom cinematics and materials.
  - Each mode has a unique hitbox size (0.33/0.495) and shot speed (45/15).
  - Each tier applies the pulse effect to aliens (reduces primary attack speed).
	- Pulse effect does not apply to structures.
  - Direct damage range is 50 (0% charge) to 70 (100% charge).
  - DoT damage range is 75 (bomb mode only) applied over 5s.
  
### Prototype Lab
  - Single arm exotech is unlocked with prototype lab.
  - Advanced prototype lab upgrade required to unlock dual arm exosuits and cores.

## ALIEN
### Rage
  - Replaces Heat Plating
  - Increases energy regeneration rate for 2s after taking damage (+16.67% per shell).

### Gorge
  - New biomass 7 ability (Babbler Bomb)
    - Ability allows gorges to throw babbler bombs that spawn babblers (bombblers).
	- Bombblers are independent to regular babblers.
	- A max of 12 bombblers can exist at a time.
	- Bombblers despawn after 5s.

]]
