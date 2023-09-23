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
    return "»"
end

gChangelogData =
[[

»Balance Playtest Changes between Revision 2.0 and 1.5.2:

»» ALIEN
»»» Crag/Shift/Shade/Whip
  - Reduced cost to 8 tres from 13 tres
  - Reduced hitbox by 20%
  - Reduced HP by 20%
  - Changed Whip/Shade movement speed to be in line with Crag/Shift
  - Increased Speed by 25%

»»» Fortress Crag/Shift/Shade/Whip
  - Upgradeable version for 24 tres research cost
  - Are able to use ink, echo and healwave without a hivetype
  - Normal hitbox
  - Increased HP to 300%
  - Reduced Speed by 50%
  - Cannot be echo'd
  - Restricted to max 1 of each kind
  - Access to 1 new ability each (3 tres, 10 sec cooldown)
    - Umbra(Crag): Cast Umbra on all Structures in healrange
    - Hallucinations(Shade): Create 5 fake moveable Structures for 30 seconds
    - Stormcloud(Shift): Increase aliens movement speed by 30% for 5 seconds
	- Frenzy(Whip): 2x attack speed and 4x movement speed for 7.5 seconds

»»» Whips
  - Fully matured whips attack without infestation

»»» Veil/Spur/Shell
  - Veils: Selfcloak
  - Spurs: Moveable (50% movement speed)
  - Shells: Selfheal (1% each healingcycle)

»»» Gorge
  - Hydras and Bilemine cost 30% less energy

»» MARINE
»» Structure Damage Rework
  - Buffed all Alien Structures HP by 15%
  	- Hives receive an additional HP buff of 10% for a total of +25%
  - Buffed Arc Damage by 15%
  - Buffed Gorge Structure Healing by 15%
  - Every weapon upgrade does +20% structure damage (instead of + 10%)
      W1 → +10% to lifeforms / +20% to structures
      W2 → +20% to lifeforms / +40% to structures
      W3 → +30% to lifeforms / +60% to structures
  - FT and GL scale at 10% (20% structure) instead of 7%
  - W0 GL → 65 Player / 260 Structure from 74.4 Player Damage
  - W0 FT → 9 Player / 18 Structure from 9.9 Player Damage

  - dropping mines cost 5 tres (from 7 tres)
  - dropping welders cost 2 tres (from 3 tres)

»» End of Playtest Changes



  »Changes between Revision 1.5.2 and Vanilla:

  »»Nerfs:
	  »»»Railguns damage drops off over distance with up to 50% reduction at 30m
	  »»»Exos can only be bought on the Prototypelab they got researched on
	  »»»Stomp slows marines instead of knocking them down
	  »»»Carapace got replaced with Heat Plating
  »»Buffs: 
	  »»»Pulse Grenades deal 20% more damage
	  »»»Stomp deals 25% more damage 
	  »»»Cloaked players are less visible from afar
	  »»»Swapping traits costs less for higher lifeforms (eg. Celerity -> Crush)



	»Full Changelog History:

»1.5.2
»»Alien
	»»»Cloak
	- Cloaked units' minimap and model visibility based upon proximity corresponding to amount of veils (8m/6m/4m)
	- Player and drifter eggs are now invisible while under the effect of cloak
	- Cloaking-in rate is now fixed at 3 (over 0.33s)
	- Cloaking at 40.1% effectiveness is considered Fully Cloaked, no longer show on enemy minimap and evade AI targetting.
	- Combat-passive alien units partially decloak, and have shorter cloaking delay (1.5s instead of 2.5) 
		after taking damage, scanned or touched.
	- Cloaking effect is applied normally again.
	- Cyst uncloak proximity radius change reverted.
	- Whips and Harvester no longer turn fully invisible
	
	The new camoflauge enabled playstyles for all lifeforms not previously possible due to the reworked shader. 
	However, the strength of the new shader has led to frustration among players. 
	The aim of these changes is to continue to allow for these new playstyles while reducing the power of 
	camoflauge to a comparable level of other upgrades. Additionally more veils will be needed to unlock the 
	full potential of camoflauge, reducing the frustration of early single veil camoflauge.

	»»»Stomp
	- Marines that are hit by Stomp are able to jump again
	
	The new stomp changes have had a mixed reception due to not eliminating the issue of multi-onos stomp spam. 
	The increased stomp damage only aggrevated this issue.

»1.5.1
»»Fixes
	- Various bugfixes to cloak and UI mistakes.

»1.5.0
»»Alien
	»»»Stomp
    - Marines that are hit by Stomp will not be able to jump for the duration of the debuff
    - Increased damage from 40 to 50 heavy damage 
		This will increase damage against full armor marines from 80 to 100

	»»»Carapace
    - Replaced with Heat Plating

	»»»Heat Plating
    - Reduce damage from flamethrower, grenadelauncher, mines, hand grenades and railguns
        (10% per shell)
    - Decreases duration of fire tick damage from flamethrowers by 33% per shell

	»»»Swapping Trait Cost
    - Swapping to another trait from the same chamber costs less:  
		Skulk: 0 (Same as vanilla)
		Gorge: 1 (Same as vanilla)
		Lerk: 2 (Changed)
		Fade: 3 (Changed)
		Onos: 4 (Changed)

	»»»Hallucination Cloud
    - Replaced Hallucination Cloud with Lesser Ink Cloud, cloaks players, eggs and drifters 
        (including those in combat) for up to 5 seconds.

»»Marine
	»»» Pulse Grenade
    - Increased damage from 50 to 60

	»»» Prototype Lab
    - Exotech is tied to the specific protolab it was researched on.
    - Exotech will be lost when the protolab gets destroyed or recycled.

	»»Fixes & Improvements
	- Fixed various visual techtree bugs
	- Removed point reward for building hydras
	- Changed point rewards for building structures to be tied to the buildtime
	- Armslabs while researching will show a rotating hologram
	- Protolabs while researching exotech will show a rotating exo hologram
	- Protolabs with exotech available will show a static exo inside an orb
	- Changed so if boneshield is broken it will display even if other weapon is active
	- Babblers will now detach around the gorge instead of everyone at same location above the gorge
	- Babblers will stay out for at least the duration of the babbler ball

»1.0.0
»»Alien
	»»»Stomp
    - Stomp will no longer knock Marines over, instead Marines that are hit by a Stomp
    	shockwave will have the full web debuff applied

	»»»Carapace
	- Replaced with Resilience
	
	»»»Resilience
	- Increases duration of positive status effects and decreases duration of negative status effects
	- Positive status effects duration will increase by 33% per shell
	- Negative status effects duration will decrease by 33% per shell
	- Positive status effects include umbra, enzyme (drifter ability), and mucous membrane (drifter ability)
	- Positive status effects like umbra will not be removed when players are set on fire with resilience
	- Negative status effects include nerve gas dot, flamer dot, and pulse slow.
	- You must have resilience to receive the increased duration of buffs.

»»Marine
	»»»Railgun
	- Added falloff to the Railgun
		Railguns will deal full damage to targets 15 meters or closer
		Damage will drop off linearly until a max distance of 30 meters
		The maximum damage reduction is 50%

]]
