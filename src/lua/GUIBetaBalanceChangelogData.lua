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

if kCBMaddon then 
	gChangelogData =
	[[

	Welcome to the Community Balance Mod, a project built by the community, for the community. 
	Ping me, @Shifter (project lead) or @NexZone30 (dev lead), in any of the NS2 discords, or start a conversation in beta-balance-feedback 
	on the official discord to let us know you think! Below are the changes this mod introduces:

	#TLDR of Community Balance Mod (v3.1.4) vs. Vanilla:
	
	## MARINE
	  - Reworks to existing marines structures (sentry, sentry battery, and prototype lab).
	  - New marine structures: advanced observatory and phase gates.
	  - New marine commander units (SPARC and AMAC).
	  - Full rework and rebalance of exosuits. New exosuit arms (plasma launcher and claw) and upgrades.
	  - Weapon upgrades further increase structure damage.
	  - New infantry weapon (SMG).
	  - Rebalance of pulse grenades and extension to electrify debuff (works on PvE).

	## ALIEN
	  - Rebalance of existing alien support structures (reduced eHP, cost, and size; increased movement speed).
	  - New alien support structure upgrades (fortress crag, shift, shade, and whip) with powerful abilites.
	  - Hive biomass 5 introduced (2 hive xeno).
	  - Rework and bugfixes to onos stomp.
	  - Rework of cloak and carapace replacement (rage).
	  - New gorge ability (babbler bomb).

	## GENERAL
	  - Complete rewrite of MAC and drifter AI with updated command card.
	  - New map icons for structures and units.
	  - Updated locale, new ui elements, and improved tech maps for new (and old) features.
	  - Custom skins and cinematics for new content.
	  - Various QoL, game improvements, and bugfixes.
		  
	# Full Changelog:
	## GENERAL
	### Structure Damage Rework
	  - Buffed clogs, hydras, harvester, tunnels, and upgrade chambers eHP by ~15%.
	  - Balanced hive and support structure eHP (see alien section for details).
	  - Adjusted ARC damage, cluster grenade damage, and gorge healing to be consistent with vanilla.
	  - Every weapon upgrade does +20% structure damage (instead of + 10%)
		- W1 → +20% to structures (costs 20 tres)
		- W2 → +40% to structures (costs 30 tres)
		- W3 → +60% to structures (costs 40 tres)
	  - W0 GL → 65 Player / 260 Structure from 74.4 Player Damage
	  - W0 FT → 9 Player / 18 Structure from 9.9 Player Damage
	
	### Status Icons
	  - New status icon for webbed status (web, stomp, whip webbing).
	  - New status icons for fortress structure passives.
	  - Display status icons even with minimal hud elements.

	### QoL / General Improvements
	  - Player and structure highlight shader made more pronounced to improve visual acuity.
	  - Changed point rewards for building structures from 4 points to be tied to the build time.
	  - Removed point reward for building hydras.
	  - Rerouted techs to illustrate proper tech and structure requirements.
	  - Replaced babblertech and webs with nutrient mist at bio 1.
	  - Improved nanoshield surface shader so that it more clearly appears on all entities.
	  - Updated locale, new ui elements, and improved tech maps for new (and old) features.
	    - Marine tech map rearranged to better delineate tech progression and dependencies (purple lines).
	  - Improved blueprint placement (options -> mods -> CBM: Accessibility Options).
	  - Hotkeyed units are underlined for commanders for better visibility.
	  
	  
	### Minimap Updates
	  - Players are able to see if a hive is at <34%, <67% or <=100% maturity
	  - Added Icon for occupied Hive/Chair
	  - Added Icon for Jetpackers
	  - Added Icon for matured Whips
	  - Added Icon for Drifter Eggs
	  - Added Icon for deployed ARCS
	  - Added Icon for Advanced Armory
	  - Added Icons for Fortress PvE
	  - Alien Commander is able to see parasited mines

	### Vanilla Bugfixes
	  - Web variant nil value console spam should no longer occur.
	  - Electrify no longer applies energy regeneration debuff.
	  - ARC trigger effect triggering on EVERY live entity in the game instead of just applicable damage targets.
	  - Fixed ARC error / crash when manually targeting clogs.
	  - Robotics factory rollout crash fixed.
	  - Armslabs while researching will show a rotating hologram.
	  - Fixed various visual bugs with updating tech.
	  - Jetpackers will no longer be affected by stomp when slightly above the ground.
	  - Jetpackers are able to replenish fuel when empty when holding space bar.
	  - Alien PvE bounces/glitches less during and after moving.
	  - Flying flamethrowers in rare cases should not crash the server anymore (vanilla bug).
	  - Fix to cinematics of projectiles desyncing.
	  - Fixed bug with shotgun that caused bullets to fire out at random spots around the barrel position (caused major server hitching too).
	
	## MARINE - PLAYER
	### Modular Exosuits
	  - Exosuits changed to have swappable arms and cores (pres refunds disabled when swapping arms/cores).
	  - Base kit thruster replaced with jump (exos can no longer sprint by default).
	  - Base Armor is 170 (+40 per armor level) and base speed is 6 m/s (speed capped at 7.5 m/s).
	  - Additional armor/weight(inverse of speed)/pres cost is dependent on selected arms:
		- Railgun: 25/0.1/25
		- Minigun: 75/0.2/25
		- Plasma Launcher: 50/0.125/20
		- Claw: 75/0.0/15
	  - Cores (optional upgrade):
		- Ejection Seat: Auto-ejects marine on exosuit reaching 0 armor (+0.025 Weight / Costs 5 pres).
		  - Requires valid ejection spot.
		  - Empty exosuit will spawn with 50 armor upon automatic ejection (minus overflow damage).
		  - Empty exosuit must have >50 armor to enter exosuit after automatic ejection.	  
		- Thruster: Increases movement speed and allows for flight at the cost of energy (+0.05 Weight / Costs 5 pres). 
		  - Min 25% activation energy required and initial 10% fuel cost when activated.
		  - Vertical boost automatically activates upon holding space bar and stacks with base jump.
		  - Vertical boost has high initial acceleration, but slows down over time.
	  - Settings to make duals fire both arms upon primary attack (options -> mods -> CBM: Accessibility Options)

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
		- Scales with weapon upgrades!
	  - Range is 2.8 (2.2 in vanilla).
	  - Pierces through multiple targets in range.
	  
	### Plasma Launcher
	  - Energy based weapon. Energy regens over time (25%/s).
	  - Plasma bomb projectile:
		- Costs 80% energy per bomb.
		- Direct (35) and DoT Damage (25) in size 4 AoE. 
		- Fires one plasma ball in an arc.
		- Pulse debuff for 5 seconds.
		- Hitbox size of 0.495.
		- Shot speed of 15 m/s.
	  - Has custom cinematics and materials.
	  - Applies the electrify effect to aliens players (reduces animation speed) and structures (disables / debuffs).
	  - Projectiles spawn on each weapon and are fired towards the crosshair target.
	  - Projectiles have dual projectile controller (one for geometry and one for entities) to reduce geo clipping.
	  
	### Jetpack
	  - Min 6% activation energy required (bugfix).
	  - No longer affected by stomp when slightly above the ground (bugfix).

	### Sub Machine Gun
	  - Unlocked with submachinegun tech from armory (10 tres and 30s research time).
	  - Tiered between LMG and HMG (~10% higher DPS at optimal range).
		- Slightly faster fire rate / reloading animation. 
	  - 50 bullet mags.
	  - 6 total mags.
	  - 10.5 (normal) base damage.
		- 1.5x bullet spread of HMG.
	  - 30 damage secondary melee attack (fast).
		- Melee attack can cut webs.
		- Less delay after meleeing than rifle. 
	  - Costs 5 pres.
	  - Weighs 0.05 (~10% faster movement than rifle).
	  
	### Hand Grenades
	  - Self damage reduced by 66% (grenades/mines).
      - Pulse Grenades:
	    - Debuff range increased by 50%.
	    - Base damage set to 10 from 50.
	    - Debuff duration is now 3.5s from 5s.
	    - No longer reduces energy regeneration (bugfix).
	  - Cluster Grenades:
	    - Cluster damage type modifier increased from 2.5 to 2.875 (net neutral with structure eHP changes).
		- Cluster grenade range and fragment range reduced by 20%.

	### Electrify Debuff (pulse/plasma/SPARC)
	  - TLDR: Disables passives, reduces movement speed, and slows alien attacks and abilities.
	  - Electrify slow on players increased to 30% from 20% (vanilla).
	  - Electrify now works on structures (including fortress variants):
		- Whips: Prevents slapping / bombarding, reduces movement speed.
		- Hydra: Prevents spiking.
		- Crag: Prevents healing and douse, reduces movement speed.
		- Shift: Prevents energize and stormcloud, reduces movement speed.
		- Shade: Prevents cloaking and sonar, reduces movement speed.
		- Hive: Reduces healing by 25%.
		- Shell: Prevents healing.
		- Spur: Prevents movement.
		- Veils: Prevents cloaking.
	  - NOTE: Active abilities can still be used if electrified!

	### Mines
	  - Can no longer be placed overlapping.
	  - Will more reliably trigger on valid targets.

	### Axe
	  - Changed to 27.5 damage from 25 (+10% DPS from rifle).

	### Welder
	  - Autopickup for welders reduced from 5 to 1 second.

    ## MARINE - COMMANDER / STRUCTURES
	### Prototype Lab
	  - Exosuit tech changed to upgrade prototype lab into exosuit prototype lab.
	    - The research is tied to the exosuit prototype lab, meaning the research will be lost if the structure is destroyed or recycled.
	  - While exosuit prototype lab is researching, a rotating exo hologram will appear above the prototype lab.
	    - When completed, the hologram will become static and the map icon will become purple.
	  
	### Arc (Robotics) Factory
	  - New skin and is purple on the map.
	  - Has two new units to construct:
		- SPARC
		- A-MAC
	  - Research time increased to 30s from 20s.
	  
	### ARC
	  - Build time is now 12.5s from 10s.
	  - Can no longer damage other ARCS (bugfix).
	  - Can manually target hydras and cysts.
	  - No more than 5 arcs can exist at once (exploit fix).
	  - Buffed damage by 15% (net neutral with structure eHP changes).

	### SPARC (ARC Variant)
	  - Commander unit built from the ARC Factory.
	  - Has purple map icon, custom cinematics, and custom skin.
	  - Has 2600 health and 400 armor (same as ARC).
	  - Moves at 2.5 m/s speed unless in combat (2.25 m/s in combat).
	  - Does NOT deal damage (deals 5 damage for map indicators).
	  - Can see through fog of war and ink to target alien structures.
	  - Has higher range thane ARC (28 vs. 26).
	  - Applies electrify to alien structures in large (9) AoE.
	  - Build time is 10s.
	  - Cost 10 tres.

	### MACS
	  - MACs move 40% faster (7, 5.5 in combat) and have half the line of sight as a drifter.
		- MACs do not turn instantly while in combat.
	  - Allow MACs to be welded while taking damage.
	  - MACs are 25% smaller (model size).
	  - Rollout speed multiplier increased from 2 to 5.
	  - MACs can be recycled.
	  - MAC repair rate reduced from 50/s to 30/s (matches MAC build efficacy).
	  - MAC combat repair rate reduction (90%) removed.
	  - AI Changes: (Applies to AMAC as well!)
		- Taking damage no longer prevents MAC from welding.
		- Marine and Exo can request busy MACs for a weld with "use" key or using the "Need Weld" voice over.
		- MAC won't try to circle behind a Marine who has a welder, or if MAC is far from its leash anchor.
		- MAC stops following marines who phased.
		- Auto search new target to follow if the original died or isn't available.
		- Reduced default order search radius to 12m. Hold position order reduces it to 3m.
		- MAC now prioritizes its closest target first.
		- Reduced follow order secondary job search radius to 6m and snaps to marines with 1.5m.
		- Enabled and ehanced MAC basic order commands such as Move, Stop, Patrol and Hold position.
		- Multiple MACs can now repair PvE targets simultaneously

	### A-MAC (MAC Variant)
	  - Commander unit built from the ARC factory.
	  - Has purple map icon and custom skin.
	  - 400 Health.
	  - 200 Armor.
	  - Cost 15 tres.
	  - 20 Supply.
	  - Has 100 energy cap (starts at 25).
	  - Repair is 60/s and construction efficiency is 60%.
	  - Regenerates 1 energy / sec.
	  - Base speed is 8 (6 in combat).
	  - Has three commander abilities:
		- Healing Field: Heals players in AoE over duration (~50 HP total).
		- Catalyst Field: Catpacks players in AoE.
		- Shield Field: Nanoshields players in AoE.
	  - Healing Field: (Green Cinematic)
		- Cost 20 energy and 1 tres.
		- 10 sec cooldown.
		- Lasts 5s.
	  - Catalyst Field: (Red Cinematic)
		- Cost 50 energy and 3 tres.
		- 10 sec cooldown.
		- Lasts 5s.
		- Requires Advanced Support.
	  - Shield Field: (Blue Cinematic)
		- Cost 85 energy and 3 tres.
		- 10 sec cooldown
		- Lasts 3s
		- Requires Advanced Support.

	### Sentry
	  - Attack cone increased to 360 degrees from 135 degrees.
	  - Requires room power instead of sentry battery.
	  - Sentry supply cost reduced from 15 to 10.
	  - Cost 7 tres.
	  - 8s build time.
	  - Limited to 1.
	  - Removed weld override (welds at same rate as other structures).
	  - Increased spread (3 to 7.5 rad).
	  - Shoots 2x3.5 damage bullets.
	  - Deals light damage (deals half damage against armor).
	  - Increased target aquire time (0.15s to 0.4s) and made cooldown trigger on target swap.
	  - Babblers are now treated as player targets (same priority).

	### Power (formerly sentry) Battery
	  - Provides power to nearby marine structures.
	  - Provided power does not require room power.
	  - Power battery supply cost changed from 25 to 15.
	  - Power lines drawn to all potentially powered structures before placement.
	  - Costs 10 tres.
	  - Requires ARC factory to build.
	  - Power battery limited to one per room and two in total.
	  - Health/Armor changed to 500/250.

	### Observatory
	  - Provides low resolution motion tracking on aliens within range (improved version of vanilla's).

	### Advanced Observatory
	  - Upgraded observatory for 10 tres with 1000 Hp, 500 Armor, and +3 range (25).
		- Takes 45s to upgrade.
	  - Provides high resolution motion tracking on aliens within range (improved version of vanilla's).
	  - Automatically unlocks advanced gates.

	### Advanced Phase Gates
	  - Consecutive phase delay of 1.5s.
	  - Casts catpacks on phasing marines when the gate is recently damaged.
		- Maximum of 2 charges.
		- A charge takes 5s to replenish.

	### Advanced Support
	  - Advanced support is now 15 tres.
	  - Catpacked marines now build and weld faster 12.5%.
	  - Nanoshield cost reduced to 2 from 5.
	  - Nanoshield snap range decreased to 4 from 6.
      - Nanoshield MAC priority put last (AMAC is normal priority).	  

	### Commander Drops
	  - Dropping mines cost 5 tres (from 7 tres).
	  - Dropping welders cost 2 tres (from 3 tres).

	## ALIEN - PLAYER
	### Chamber Trait Reworks / Rebelance
	  - Trait Swapping: (cost reduction)
		- Skulk: 0 (Same as vanilla)
		- Gorge: 1 (Same as vanilla)
		- Lerk: 2 (Changed)
		- Fade: 3 (Changed)
		- Onos: 4 (Changed)
	  - Rage:
	    - Replaces Carapace
	    - Increases energy regeneration rate for 3s after taking damage (+16.67% per shell).
	  - Aura:
	    - No longer reveals health information (moved to Fortress Shade)
	    - Icon is always yellow.
      - Camouflage:
	    - Shaders completely reworked to ensure camo is competitive with other upgrades.
	    - Cloaking reveal range and rate depend more heavily on veil amount.
	    - Onos are silent when crouching with cloak.
	    - UI icon only appears when fully cloaked.	
      - Focus:
	    - Properly affects Stab ability now.
	    - Fixed bug which slowed Gore by 57% instead of 33%.
	    - Gorges now get a 1.5x damage buff instead of a 1.33x buff.

	### Gorges
	  - Babblers
		- Babblers will now detach around the gorge instead of everyone at same location above the gorge.
		- Babblers will stay out for at least the duration of the babbler ball.
		- Babblers are now affected by crush upgrade.
		- Babblers are now 10 eHp.
	  - Babbler Bomb
		- Bio 7 gorge ability researchable on hive (15 tres).
		- Gorge spews out babbler filled egg that explodes on impact.
		- Egg filled with 6 independent babblers that die after 8s.
		- Limited to 2 charge that fills over 10s each.
		- Upgrades babblers to bombblers.
		- Does not spawn additional babblers if more than twelve exist in an area.
	  - Hydras and Bilemine cost 30% less energy
	  - Bile damage accelerates weapon expiration
		- 1 Bile ~ 5 seconds
	  - Buffed Gorge Structure Healing by 15% (net neutral with structure eHP changes).

	### Stomp (onos)
	  - No longer knocks down marines.
	  - Applies web debuff.
	  - Damage increased from 40 to 50 heavy damage.
	  - Improved terrain pathing.
	  - Added proper check for marine jumping.

	### Stab (fade)
	  - Stab research cost reduced from 25 to 20 tres.
	  - Stab energy cost reduced by 16%.
	  
	### Skulk
	  - Improved movement on wall and ceilings by making fall checks more forgiving.
	  
	## ALIEN - COMMANDER / STRUCTURES
	### Hives
	  - Based eHP decreased to be +7.5% of vanilla.
	  - Gains +2.5% eHP per hive biomass returned to current value after 3rd biomass upgrade.
	  - Maturation time increased to 260s from 220s.
	  - Added biomass 5 research to hives (4th upgrade).
		- Costs 190 tres and takes 10 mins to research.
		- During research, a global heartbeat sound will play once every minute.
		- During research, a global status icon will be applied to marines with accurate timer.
		- On complete, the hive will become magenta on the map and a sound will play.

	### Veil/Spur/Shell
	  - Veils: Cloaked
	  - Spurs: Moveable (50% movement speed)
	  - Shells: Selfheal (1% each healingcycle)

	### Base Support Structures
	  - Reduced cost to 8 tres (10 tres for whips) from 13 tres.
	  - Base speed increased by 25%.
	  - eHP changed to unify time to kill.
	    - eHP for Shift/Crag/Shade/Whip is now 600/600/600/750 at 0% maturity.
	    - eHP for Shift/Crag/Shade/Whip is now 1100/1100/1100/1100 at 100% maturity.
	  - GUIs updated to accommodate new passive icons.
	  - Added lag compensation to improve hit registration at higher pings.
	  - Crag:
		- Healwave replaced with Shieldwave.
		- Shieldwave applies full overshield to aliens over duration.
	  - Whip:
		- Fully matured whips attack without infestation.
		- Increased turning speed before moving.
		- Can order to attack a specific structure.
	  - Shift:
		- Reduced energy regenerate rate by 50%

	### Fortress Support Structures
	  - Starting eHP reduced to 1400/1400/1400/2800 at 0% maturity and 1 biomass.
	  - Starting eHP reduced to 2000/2000/2000/3400 at 100% maturity and 1 biomass.
	  - Fotress whip gains 50 HP per biomass and has a max of 200 armor.
	  - Fortress structures move 25% slower than regular PvE on infestation (2.9 m/s).
		- Fortress structures gradually slow to 1.45/1.45/1.45/2.175 m/s off infestation.
		- Fortress abilities do not work while moving.
	  - New passives when specific hive tech is researched.
	  - Fortress structure passives are only active when structure is stationary.
	  - New UI element for passives and updated tooltips.
	  - Fortress upgrade costs 20 tres (18 tres for whip - same total)
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
		- Active ability called bile frenzy that spawns three bile bombs and temporarily increases whip movement speed.
		- Slaps deal 15 damage to secondary targets within 3 m of main target.
		- Crag Hive: Siphoning Slaps (75 eHP gained on player slap hit)
		- Shift Hive: Whip Webbing (all attacks slow targets for 3.0s duration - works on exos too!)
		- Shade Hive: Ocular Parasite (all attacks parasite targets and whippy will self-camo)

	### Bonewall
	  - Buffed eHP per biomass from 115 to 140 (~25% increase).

	### Drifter
	  - Unified AoE size of enymze, mucous, and cloaking haze.
	  - Before casting, a visual will appear denoting the ability and distance for nearby lifeforms.
	  - A lifeform can be selected to gain access to the drifter castables. 
	    - Using the buttons or hotkeys will remotely tell the nearest drifter to cast an ability.
	  - Will return to previous position, patrol path, or targeted lifeform upon using a castable.	  
	  - Will no longer follow echoed unfinished structures over the entire map (bugfix).
	  - Will no longer autobuild hydras or bilemines anymore (QoL).
	  - Can auto-build a cyst chain by holding shift and right clicking on them.
	  - Will attempt check for structures to grow nearby a move order (QoL).
	  - Following a lifeform will no longer result in the drifter standing still (will more closely follow lifeform movement).
	  - Stop order added.
	  - Cloaking Haze: (replaced hallucination cloud)
		- Cloaks players, eggs and drifters (including those in combat) for up to 5 seconds.
	 
	]]
else
	gChangelogData =
	[[

	Welcome to the Community Balance Mod - Core Edition, a project built by the community, for the community.
    This version only enables the balance, QoL, and bugfixes of the CBM suite.
	Ping me, @Shifter (project lead) or @NexZone30 (dev lead), in any of the NS2 discords, or start a conversation in beta-balance-feedback 
	on the official discord to let us know you think! Below are the changes this mod introduces:

	#TLDR of Community Balance Mod (v3.1.4) vs. Vanilla:
	
	## MARINE
	  - Reworks to existing marines structures (sentry, sentry battery, and prototype lab).
	  - Full rework and rebalance of exosuits. New optional exosuit upgrades and claw arm.
	  - Weapon upgrades further increase structure damage.
	  - Rebalance of pulse grenades and extension to electrify debuff (works on PvE).

	## ALIEN
	  - Rebalance of existing alien support structures (reduced eHP, cost, and size; increased movement speed).
	  - Rework and bugfixes to onos stomp.
	  - Rework of cloak and carapace replacement (rage).

	## GENERAL
	  - Complete rewrite of MAC and drifter AI with updated command card.
	  - New map icons for structures and units.
	  - Updated locale, new ui elements, and improved tech maps for new (and old) features.
	  - Custom skins and cinematics for new content.
	  - Various QoL, game improvements, and bugfixes.
		  
	# Full Changelog:
	## GENERAL
	### Structure Damage Rework
	  - Buffed clogs, hydras, harvester, tunnels, and upgrade chambers eHP by ~15%.
	  - Balanced hive and support structure eHP (see alien section for details).
	  - Adjusted ARC damage, cluster grenade damage, and gorge healing to be consistent with vanilla.
	  - Every weapon upgrade does +20% structure damage (instead of + 10%)
		- W1 → +20% to structures (costs 20 tres)
		- W2 → +40% to structures (costs 30 tres)
		- W3 → +60% to structures (costs 40 tres)
	  - W0 GL → 65 Player / 260 Structure from 74.4 Player Damage
	  - W0 FT → 9 Player / 18 Structure from 9.9 Player Damage
	
	### Status Icons
	  - New status icon for webbed status (web, stomp, whip webbing).
	  - New status icons for fortress structure passives.
	  - Display status icons even with minimal hud elements.

	### QoL / General Improvements
	  - Player and structure highlight shader made more pronounced to improve visual acuity.
	  - Changed point rewards for building structures from 4 points to be tied to the build time.
	  - Removed point reward for building hydras.
	  - Rerouted techs to illustrate proper tech and structure requirements.
	  - Replaced babblertech and webs with nutrient mist at bio 1.
	  - Improved nanoshield surface shader so that it more clearly appears on all entities.
	  - Updated locale, new ui elements, and improved tech maps for new (and old) features.
	    - Marine tech map rearranged to better delineate tech progression and dependencies (purple lines).
	  - Improved blueprint placement (options -> mods -> CBM: Accessibility Options).
	  - Hotkeyed units are underlined for commanders for better visibility.
	  
	### Minimap Updates
	  - Players are able to see if a hive is at <34%, <67% or <=100% maturity
	  - Added Icon for occupied Hive/Chair
	  - Added Icon for Jetpackers
	  - Added Icon for matured Whips
	  - Added Icon for Drifter Eggs
	  - Added Icon for deployed ARCS
	  - Added Icon for Advanced Armory
	  - Added Icons for Fortress PvE
	  - Alien Commander is able to see parasited mines

	### Vanilla Bugfixes
	  - Web variant nil value console spam should no longer occur.
	  - Electrify no longer applies energy regeneration debuff.
	  - ARC trigger effect triggering on EVERY live entity in the game instead of just applicable damage targets.
	  - Fixed ARC error / crash when manually targeting clogs.
	  - Robotics factory rollout crash fixed.
	  - Armslabs while researching will show a rotating hologram.
	  - Fixed various visual bugs with updating tech.
	  - Jetpackers will no longer be affected by stomp when slightly above the ground.
	  - Jetpackers are able to replenish fuel when empty when holding space bar.
	  - Alien PvE bounces/glitches less during and after moving.
	  - Flying flamethrowers in rare cases should not crash the server anymore (vanilla bug).
	  - Fix to cinematics of projectiles desyncing.
	  - Fixed bug with shotgun that caused bullets to fire out at random spots around the barrel position (caused major server hitching too).
	
	## MARINE - PLAYER
	### Modular Exosuits
	  - Exosuits changed to have swappable arms and cores (pres refunds disabled when swapping arms/cores).
	  - Base kit thruster replaced with jump (exos can no longer sprint by default).
	  - Base Armor is 170 (+40 per armor level) and base speed is 6 m/s (speed capped at 7.5 m/s).
	  - Additional armor/weight(inverse of speed)/pres cost is dependent on selected arms:
		- Railgun: 25/0.1/25
		- Minigun: 75/0.2/25
		- Plasma Launcher: 50/0.125/20
		- Claw: 75/0.0/15
	  - Cores (optional upgrade):
		- Ejection Seat: Auto-ejects marine on exosuit reaching 0 armor (+0.025 Weight / Costs 5 pres).
		  - Requires valid ejection spot.
		  - Empty exosuit will spawn with 50 armor upon automatic ejection (minus overflow damage).
		  - Empty exosuit must have >50 armor to enter exosuit after automatic ejection.	  
		- Thruster: Increases movement speed and allows for flight at the cost of energy (+0.05 Weight / Costs 5 pres). 
		  - Min 25% activation energy required and initial 10% fuel cost when activated.
		  - Vertical boost automatically activates upon holding space bar and stacks with base jump.
		  - Vertical boost has high initial acceleration, but slows down over time.
	  - Settings to make duals fire both arms upon primary attack (options -> mods -> CBM: Accessibility Options)

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
		- Scales with weapon upgrades!
	  - Range is 2.8 (2.2 in vanilla).
	  - Pierces through multiple targets in range.

	### Jetpack
	  - Min 6% activation energy required (bugfix).
	  - No longer affected by stomp when slightly above the ground (bugfix).

	### Hand Grenades
	  - Self damage reduced by 66% (grenades/mines).
      - Pulse Grenades:
	    - Debuff range increased by 50%.
	    - Base damage set to 10 from 50.
	    - Debuff duration is now 3.5s from 5s.
	    - No longer reduces energy regeneration (bugfix).
	  - Cluster Grenades:
	    - Cluster damage type modifier increased from 2.5 to 2.875 (net neutral with structure eHP changes).
		- Cluster grenade range and fragment range reduced by 20%.

	### Electrify Debuff (pulse/plasma/SPARC)
	  - TLDR: Disables passives, reduces movement speed, and slows alien attacks and abilities.
	  - Electrify slow on players increased to 30% from 20% (vanilla).
	  - Electrify now works on structures (including fortress variants):
		- Whips: Prevents slapping / bombarding, reduces movement speed.
		- Hydra: Prevents spiking.
		- Crag: Prevents healing and douse, reduces movement speed.
		- Shift: Prevents energize and stormcloud, reduces movement speed.
		- Shade: Prevents cloaking and sonar, reduces movement speed.
		- Hive: Reduces healing by 25%.
		- Shell: Prevents healing.
		- Spur: Prevents movement.
		- Veils: Prevents cloaking.
	  - NOTE: Active abilities can still be used if electrified!

	### Mines
	  - Can no longer be placed overlapping.
	  - Will more reliably trigger on valid targets.

	### Axe
	  - Changed to 27.5 damage from 25 (+10% DPS from rifle).

	### Welder
	  - Autopickup for welders reduced from 5 to 1 second.

    ## MARINE - COMMANDER / STRUCTURES
	### Prototype Lab
	  - Exosuit tech changed to upgrade prototype lab into exosuit prototype lab.
	    - The research is tied to the exosuit prototype lab, meaning the research will be lost if the structure is destroyed or recycled.
	  - While exosuit prototype lab is researching, a rotating exo hologram will appear above the prototype lab.
	    - When completed, the hologram will become static and the map icon will become purple.
	  
	### Arc (Robotics) Factory
	  - New skin and is purple on the map.
	  - Research time increased to 30s from 20s.
	  
	### ARC
	  - Build time is now 12.5s from 10s.
	  - Can no longer damage other ARCS (bugfix).
	  - Can manually target hydras and cysts.
	  - No more than 5 arcs can exist at once (exploit fix).
	  - Buffed damage by 15% (net neutral with structure eHP changes).

	### MACS
	  - MACs move 40% faster (7, 5.5 in combat) and have half the line of sight as a drifter.
		- MACs do not turn instantly while in combat.
	  - Allow MACs to be welded while taking damage.
	  - MACs are 25% smaller (model size).
	  - Rollout speed multiplier increased from 2 to 5.
	  - MACs can be recycled.
	  - MAC repair rate reduced from 50/s to 30/s (matches MAC build efficacy).
	  - MAC combat repair rate reduction (90%) removed.
	  - AI Changes:
		- Taking damage no longer prevents MAC from welding.
		- Marine and Exo can request busy MACs for a weld with "use" key or using the "Need Weld" voice over.
		- MAC won't try to circle behind a Marine who has a welder, or if MAC is far from its leash anchor.
		- MAC stops following marines who phased.
		- Auto search new target to follow if the original died or isn't available.
		- Reduced default order search radius to 12m. Hold position order reduces it to 3m.
		- MAC now prioritizes its closest target first.
		- Reduced follow order secondary job search radius to 6m and snaps to marines with 1.5m.
		- Enabled and enhanced MAC basic order commands such as Move, Stop, Patrol and Hold position.
		- Multiple MACs can now repair PvE targets simultaneously

	### Sentry
	  - Attack cone increased to 360 degrees from 135 degrees.
	  - Requires room power instead of sentry battery.
	  - Sentry supply cost reduced from 15 to 10.
	  - Cost 7 tres.
	  - 8s build time.
	  - Limited to 1.
	  - Removed weld override (welds at same rate as other structures).
	  - Increased spread (3 to 7.5 rad).
	  - Shoots 2x3.5 damage bullets.
	  - Deals light damage (deals half damage against armor).
	  - Increased target aquire time (0.15s to 0.4s) and made cooldown trigger on target swap.
	  - Babblers are now treated as player targets (same priority).

	### Observatory
	  - Provides low resolution motion tracking on aliens within range (improved version of vanilla's).

	### Advanced Support
	  - Advanced support is now 15 tres.
	  - Catpacked marines now build and weld faster 12.5%.
	  - Nanoshield cost reduced to 2 from 5.
	  - Nanoshield snap range decreased to 4 from 6.
      - Nanoshield MAC priority put last.  

	### Commander Drops
	  - Dropping mines cost 5 tres (from 7 tres).
	  - Dropping welders cost 2 tres (from 3 tres).

	## ALIEN - PLAYER
	### Chamber Trait Reworks / Rebelance
	  - Trait Swapping: (cost reduction)
		- Skulk: 0 (Same as vanilla)
		- Gorge: 1 (Same as vanilla)
		- Lerk: 2 (Changed)
		- Fade: 3 (Changed)
		- Onos: 4 (Changed)
	  - Rage:
	    - Replaces Carapace
	    - Increases energy regeneration rate for 3s after taking damage (+16.67% per shell).
	  - Aura:
	    - No longer reveals health information (moved to Fortress Shade)
	    - Icon is always yellow.
      - Camouflage:
	    - Shaders completely reworked to ensure camo is competitive with other upgrades.
	    - Cloaking reveal range and rate depend more heavily on veil amount.
	    - Onos are silent when crouching with cloak.
	    - UI icon only appears when fully cloaked.	
      - Focus:
	    - Properly affects Stab ability now.
	    - Fixed bug which slowed Gore by 57% instead of 33%.
	    - Gorges now get a 1.5x damage buff instead of a 1.33x buff.

	### Gorges
	  - Babblers
		- Babblers will now detach around the gorge instead of everyone at same location above the gorge.
		- Babblers will stay out for at least the duration of the babbler ball.
		- Babblers are now affected by crush upgrade.
		- Babblers are now 10 eHp.
	  - Hydras and Bilemine cost 30% less energy
	  - Bile damage accelerates weapon expiration
		- 1 Bile ~ 5 seconds
	  - Buffed Gorge Structure Healing by 15% (net neutral with structure eHP changes).

	### Stomp (onos)
	  - No longer knocks down marines.
	  - Applies web debuff.
	  - Damage increased from 40 to 50 heavy damage.
	  - Improved terrain pathing.
	  - Added proper check for marine jumping.

	### Stab (fade)
	  - Stab research cost reduced from 25 to 20 tres.
	  - Stab energy cost reduced by 16%.
	  
	### Skulk
	  - Improved movement on wall and ceilings by making fall checks more forgiving.
	  
	## ALIEN - COMMANDER / STRUCTURES
	### Hives
	  - Based eHP decreased to be +7.5% of vanilla.
	  - Gains +2.5% eHP per hive biomass returned to current value after 3rd biomass upgrade.
	  - Maturation time increased to 260s from 220s.

	### Veil/Spur/Shell
	  - Veils: Cloaked
	  - Spurs: Moveable (50% movement speed)
	  - Shells: Selfheal (1% each healingcycle)

	### Base Support Structures
	  - Reduced cost to 8 tres (10 tres for whips) from 13 tres.
	  - Base speed increased by 25%.
	  - eHP changed to unify time to kill.
	    - eHP for Shift/Crag/Shade/Whip is now 600/600/600/750 at 0% maturity.
	    - eHP for Shift/Crag/Shade/Whip is now 1100/1100/1100/1100 at 100% maturity.
	  - GUIs updated to accommodate new passive icons.
	  - Added lag compensation to improve hit registration at higher pings.
	  - Crag:
		- Healwave replaced with Shieldwave.
		- Shieldwave applies full overshield to aliens over duration.
	  - Whip:
		- Fully matured whips attack without infestation.
		- Increased turning speed before moving.
		- Can order to attack a specific target.
	  - Shift:
		- Reduced energy regenerate rate by 50%

	### Bonewall
	  - Buffed eHP per biomass from 115 to 140 (~25% increase).

	### Drifter
	  - Unified AoE size of enymze, mucous, and cloaking haze.
	  - Before casting, a visual will appear denoting the ability and distance for nearby lifeforms.
	  - A lifeform can be selected to gain access to the drifter castables. 
	    - Using the buttons or hotkeys will remotely tell the nearest drifter to cast an ability.
	  - Will return to previous position, patrol path, or targeted lifeform upon using a castable.	  
	  - Will no longer follow echoed unfinished structures over the entire map (bugfix).
	  - Will no longer autobuild hydras or bilemines anymore (QoL).
	  - Can auto-build a cyst chain by holding shift and right clicking on them.
	  - Will attempt check for structures to grow nearby a move order (QoL).
	  - Following a lifeform will no longer result in the drifter standing still (will more closely follow lifeform movement).
	  - Stop order added.
	  - Cloaking Haze: (replaced hallucination cloud)
		- Cloaks players, eggs and drifters (including those in combat) for up to 5 seconds.
	]]
end