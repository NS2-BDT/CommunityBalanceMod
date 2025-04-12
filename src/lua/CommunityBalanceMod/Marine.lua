-- ======= Copyright (c) 2003-2012, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Marine.lua
--
--    Created by:   Charlie Cleveland (charlie@unknownworlds.com) and
--                  Max McGuire (max@unknownworlds.com)
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Player.lua")
Script.Load("lua/Mixins/BaseMoveMixin.lua")
Script.Load("lua/Mixins/GroundMoveMixin.lua")
Script.Load("lua/Mixins/JumpMoveMixin.lua")
Script.Load("lua/Mixins/CrouchMoveMixin.lua")
Script.Load("lua/Mixins/LadderMoveMixin.lua")
Script.Load("lua/Mixins/CameraHolderMixin.lua")
Script.Load("lua/OrderSelfMixin.lua")
Script.Load("lua/MarineActionFinderMixin.lua")
Script.Load("lua/StunMixin.lua")
Script.Load("lua/NanoShieldMixin.lua")
Script.Load("lua/FireMixin.lua")
Script.Load("lua/CatPackMixin.lua")
Script.Load("lua/SprintMixin.lua")
Script.Load("lua/InfestationTrackerMixin.lua")
Script.Load("lua/WeldableMixin.lua")
Script.Load("lua/ScoringMixin.lua")
Script.Load("lua/UnitStatusMixin.lua")
Script.Load("lua/DissolveMixin.lua")
Script.Load("lua/MapBlipMixin.lua")
Script.Load("lua/HiveVisionMixin.lua")
Script.Load("lua/DisorientableMixin.lua")
Script.Load("lua/LOSMixin.lua")
Script.Load("lua/CombatMixin.lua")
Script.Load("lua/SelectableMixin.lua")
Script.Load("lua/ParasiteMixin.lua")
Script.Load("lua/OrdersMixin.lua")
Script.Load("lua/RagdollMixin.lua")
Script.Load("lua/WebableMixin.lua")
Script.Load("lua/CorrodeMixin.lua")
Script.Load("lua/TunnelUserMixin.lua")
Script.Load("lua/PhaseGateUserMixin.lua")
Script.Load("lua/Weapons/PredictedProjectile.lua")
Script.Load("lua/MarineVariantMixin.lua")
Script.Load("lua/MarineOutlineMixin.lua")
Script.Load("lua/RegenerationMixin.lua")
Script.Load("lua/Hud/GUINotificationMixin.lua")
Script.Load("lua/PlayerStatusMixin.lua")
Script.Load("lua/CommunityBalanceMod/BlightMixin.lua")

if Client then
    Script.Load("lua/TeamMessageMixin.lua")
end

class 'Marine' (Player)

Marine.kMapName = "marine"

if Server then
    Script.Load("lua/Marine_Server.lua")
elseif Client then
    Script.Load("lua/Marine_Client.lua")
end

local precached1 = PrecacheAsset("models/marine/marine.surface_shader")
local precached2 = PrecacheAsset("models/marine/marine_noemissive.surface_shader")

local kFlashlightSoundName = PrecacheAsset("sound/NS2.fev/common/light")
--Marine.kGunPickupSound = PrecacheAsset("sound/NS2.fev/marine/common/pickup_gun")
local kSpendResourcesSoundName = PrecacheAsset("sound/NS2.fev/marine/common/player_spend_nanites")
local kChatSound = PrecacheAsset("sound/NS2.fev/marine/common/chat")
local kSoldierLostAlertSound = PrecacheAsset("sound/NS2.fev/marine/voiceovers/soldier_lost")
local kFlashlightGoboTexture = PrecacheAsset( "models/marine/male/flashlight.dds")

local kFlinchEffect = PrecacheAsset("cinematics/marine/hit.cinematic")
local kFlinchBigEffect = PrecacheAsset("cinematics/marine/hit_big.cinematic")

local kHitGroundStunnedSound = PrecacheAsset("sound/NS2.fev/marine/common/jump")
local kSprintStart = PrecacheAsset("sound/NS2.fev/marine/common/sprint_start")
local kSprintTiredEnd = PrecacheAsset("sound/NS2.fev/marine/common/sprint_tired")
--The longer running sound, sprint_start, would be ideally the sprint_end sound instead. That is what is done here
local kSprintStartFemale = PrecacheAsset("sound/NS2.fev/marine/common/sprint_tired_female")
local kSprintTiredEndFemale = PrecacheAsset("sound/NS2.fev/marine/common/sprint_start_female")

Marine.kEffectNode = "fxnode_playereffect"
Marine.kHealth = kMarineHealth
Marine.kBaseArmor = kMarineArmor
Marine.kArmorPerUpgradeLevel = kArmorPerUpgradeLevel
Marine.kMaxSprintFov = 95
-- Player phase delay - players can only teleport this often
Marine.kPlayerPhaseDelay = 2

Marine.kWalkMaxSpeed = 5                -- Four miles an hour = 6,437 meters/hour = 1.8 meters/second (increase for FPS tastes)
--Marine.kRunMaxSpeed = 6.0               -- 10 miles an hour = 16,093 meters/hour = 4.4 meters/second (increase for FPS tastes)
--Marine.kRunInfestationMaxSpeed = 5.2    -- 10 miles an hour = 16,093 meters/hour = 4.4 meters/second (increase for FPS tastes)
Marine.kRunMaxSpeed = 5.75
Marine.kRunInfestationMaxSpeed = 5

-- How fast does our armor get repaired by welders
Marine.kArmorWeldRate = kMarineArmorWeldRate
Marine.kWeldedEffectsInterval = 0.5

Marine.kSpitSlowDuration = 3

Marine.kWalkBackwardSpeedScalar = 0.4

-- start the get up animation after stun before giving back control
Marine.kGetUpAnimationLength = 0

-- tracked per techId
Marine.kMarineAlertTimeout = 4

Marine.kDropWeaponTimeLimit = kWeaponDropRateLimit
Marine.kFindWeaponRange = 2
Marine.kPickupWeaponTimeLimit = 1
Marine.kPickupPriority = { [kTechId.Flamethrower] = 1, [kTechId.GrenadeLauncher] = 2, [kTechId.HeavyMachineGun] = 3, [kTechId.Shotgun] = 4 }
	
Marine.kAcceleration = 100
Marine.kSprintAcceleration = 120 -- 70
Marine.kSprintInfestationAcceleration = 60

Marine.kGroundFrictionForce = 16

Marine.kAirStrafeWeight = 2

Marine.kMarineBuyAutopickupDelayTime = 5 -- Time for a marine player to delay before autopickuping a weapon after buying something. (Buying a GL when having a SG, for example)

local precached3 = PrecacheAsset("models/marine/rifle/rifle_shell_01.dds")
local precached4 = PrecacheAsset("models/marine/rifle/rifle_shell_01_normal.dds")
local precached5 = PrecacheAsset("models/marine/rifle/rifle_shell_01_spec.dds")
local precached6 = PrecacheAsset("models/marine/rifle/rifle_view_shell.model")
local precached7 = PrecacheAsset("models/marine/rifle/rifle_shell.model")
local precached8 = PrecacheAsset("models/marine/arms_lab/arms_lab_holo.model")
local precached9 = PrecacheAsset("models/effects/frag_metal_01.model")
local precached10 = PrecacheAsset("cinematics/vfx_materials/vfx_circuit_01.dds")
local precached11 = PrecacheAsset("materials/effects/nanoclone.dds")
local precached12 = PrecacheAsset("cinematics/vfx_materials/bugs.dds")
local precached13 = PrecacheAsset("cinematics/vfx_materials/refract_water_01_normal.dds")

local networkVars =
{      
    flashlightOn = "boolean",
    
    timeOfLastDrop = "private time",
    timeOfLastPickUpWeapon = "private time",
    
    flashlightLastFrame = "private boolean",
    
    timeLastSpitHit = "private time",
    lastSpitDirection = "private vector",
    
    ruptured = "boolean",
    interruptAim = "private boolean",
    poisoned = "boolean",
    weaponUpgradeLevel = "integer (0 to 3)",
    
    unitStatusPercentage = "private integer (0 to 100)",
    
    strafeJumped = "private compensated boolean",
    
    timeLastBeacon = "private time",
    
    weaponBeforeUseId = "private compensated entityid"
}

AddMixinNetworkVars(OrdersMixin, networkVars)
AddMixinNetworkVars(BaseMoveMixin, networkVars)
AddMixinNetworkVars(GroundMoveMixin, networkVars)
AddMixinNetworkVars(JumpMoveMixin, networkVars)
AddMixinNetworkVars(CrouchMoveMixin, networkVars)
AddMixinNetworkVars(LadderMoveMixin, networkVars)
AddMixinNetworkVars(CameraHolderMixin, networkVars)
AddMixinNetworkVars(SelectableMixin, networkVars)
AddMixinNetworkVars(StunMixin, networkVars)
AddMixinNetworkVars(NanoShieldMixin, networkVars)
AddMixinNetworkVars(FireMixin, networkVars)
AddMixinNetworkVars(CatPackMixin, networkVars)
AddMixinNetworkVars(SprintMixin, networkVars)
AddMixinNetworkVars(OrderSelfMixin, networkVars)
AddMixinNetworkVars(DissolveMixin, networkVars)
AddMixinNetworkVars(LOSMixin, networkVars)
AddMixinNetworkVars(CombatMixin, networkVars)
AddMixinNetworkVars(ParasiteMixin, networkVars)
AddMixinNetworkVars(WebableMixin, networkVars)
AddMixinNetworkVars(CorrodeMixin, networkVars)
AddMixinNetworkVars(TunnelUserMixin, networkVars)
AddMixinNetworkVars(PhaseGateUserMixin, networkVars)
AddMixinNetworkVars(MarineVariantMixin, networkVars)
AddMixinNetworkVars(ScoringMixin, networkVars)
AddMixinNetworkVars(RegenerationMixin, networkVars)
AddMixinNetworkVars(GUINotificationMixin, networkVars)
AddMixinNetworkVars(PlayerStatusMixin, networkVars)
AddMixinNetworkVars(BlightMixin, networkVars)

function Marine:OnCreate()

    InitMixin(self, BaseMoveMixin, { kGravity = Player.kGravity })
    InitMixin(self, GroundMoveMixin)
    InitMixin(self, JumpMoveMixin)
    InitMixin(self, CrouchMoveMixin)
    InitMixin(self, LadderMoveMixin)
    InitMixin(self, CameraHolderMixin, { kFov = kDefaultFov })
    InitMixin(self, MarineActionFinderMixin)
    InitMixin(self, ScoringMixin, { kMaxScore = kMaxScore })
    InitMixin(self, CombatMixin)
    InitMixin(self, SelectableMixin)
    
    Player.OnCreate(self)
    
    InitMixin(self, DissolveMixin)
    InitMixin(self, LOSMixin)
    InitMixin(self, ParasiteMixin)
    InitMixin(self, RagdollMixin)
    InitMixin(self, WebableMixin)
    InitMixin(self, CorrodeMixin)
    InitMixin(self, TunnelUserMixin)
    InitMixin(self, PhaseGateUserMixin)
    InitMixin(self, PredictedProjectileShooterMixin)
    InitMixin(self, MarineVariantMixin)

    InitMixin(self, RegenerationMixin)
    InitMixin(self, GUINotificationMixin)
    InitMixin(self, PlayerStatusMixin)
	InitMixin(self, BlightMixin)

    if Server then
    
        self.timePoisoned = 0
        self.poisoned = false
        
        -- stores welder / builder progress
        self.unitStatusPercentage = 0
        self.timeLastUnitPercentageUpdate = 0
        
        self.grenadesLeft = 0
        self.grenadeType = nil
        
        self.minesLeft = 0

    elseif Client then
    
        self.flashlight = Client.CreateRenderLight()
        
        self.flashlight:SetType( RenderLight.Type_Spot )
        self.flashlight:SetColor( kDefaultMarineFlashlightColor )
        self.flashlight:SetInnerCone( math.rad(20) )
        self.flashlight:SetOuterCone( math.rad(45) )
        self.flashlight:SetIntensity( 8 )
        self.flashlight:SetRadius( 28 )
        self.flashlight:SetAtmosphericDensity( kDefaultMarineFlashlightAtmoDensity )
        self.flashlight:SetSpecular( true )
        self.flashlight:SetGoboTexture( kFlashlightGoboTexture )

        --Shadows are too expensive, avg 2.7Fps drop, PER flashlight.
        self.flashlight:SetCastsShadows( false )
        
        self.flashlight:SetIsVisible(false)
        
        InitMixin(self, TeamMessageMixin, { kGUIScriptName = "GUIMarineTeamMessage" })

        InitMixin(self, DisorientableMixin)
        
    end
    
    self.weaponDropTime = 0
    self.timeLastSpitHit = 0
    self.lastSpitDirection = Vector(0, 0, 0)
    self.timeOfLastDrop = 0
    self.timeOfLastPickUpWeapon = 0
    self.ruptured = false
    self.interruptAim = false

    self.flashlightLastFrame = false
    self.weaponBeforeUseId = Entity.invalidId
    self.tertiaryAttackLastFrame = false

end

local function UpdateNanoArmor(self)
    self.hasNanoArmor = false -- self:GetWeapon(Welder.kMapName)
    return true
end

function Marine:GetCanJump()
    return ( self:GetIsOnGround() or self:GetIsOnLadder() )
end

function Marine:OnInitialized()

    if Client then

        -- work around to prevent the spin effect at the infantry portal spawned from
        -- local player should not see the holo marine model
        if Client.GetIsControllingPlayer() then

            local ips = GetEntitiesForTeamWithinRange("InfantryPortal", self:GetTeamNumber(), self:GetOrigin(), 1)
            if #ips > 0 then
                Shared.SortEntitiesByDistance(self:GetOrigin(), ips)
                ips[1]:PreventSpinEffect(0.2)
            end

        end

        self.autoPickup = GetAdvancedOption("autopickup")
        self.autoPickupBetter = GetAdvancedOption("autopickupbetter")

        Client.SendNetworkMessage("SetAutopickup",
        {
            autoPickup = self.autoPickup,
            autoPickupBetter = self.autoPickupBetter
        }, true)

    elseif Server then

        -- These are or should be the default values.
        self.autoPickup = true
        self.autoPickupBetter = false

    end
    
    -- These mixins must be called before SetModel because SetModel eventually
    -- calls into OnUpdatePoseParameters() which calls into these mixins.
    -- Yay for convoluted class hierarchies!!!
    InitMixin(self, OrdersMixin, { kMoveOrderCompleteDistance = kPlayerMoveOrderCompleteDistance })
    InitMixin(self, OrderSelfMixin, { kPriorityAttackTargets = { "Harvester" } })
    InitMixin(self, StunMixin)
    InitMixin(self, NanoShieldMixin)
    InitMixin(self, FireMixin)
    InitMixin(self, CatPackMixin)
    InitMixin(self, SprintMixin)
    InitMixin(self, WeldableMixin)
    
    -- SetModel must be called before Player.OnInitialized is called so the attach points in
    -- the Marine are valid to attach weapons to. This is far too subtle...
    self:SetModel(self:GetVariantModel(), MarineVariantMixin.kMarineAnimationGraph)
    
    Player.OnInitialized(self)

    if Server then
    
        self.armor = self:GetArmorAmount()
        self.maxArmor = self.armor
        
        -- This Mixin must be inited inside this OnInitialized() function.
        if not HasMixin(self, "MapBlip") then
            InitMixin(self, MapBlipMixin)
        end
        
        InitMixin(self, InfestationTrackerMixin)
        self.timeRuptured = 0
        self.interruptStartTime = 0
        self.timeLastPoisonDamage = 0
        
        self.lastPoisonAttackerId = Entity.invalidId
        
        self:AddTimedCallback(UpdateNanoArmor, 1)
       
    elseif Client then
    
        InitMixin(self, HiveVisionMixin)
        InitMixin(self, MarineOutlineMixin)
        
        self:AddHelpWidget("GUIMarineHealthRequestHelp", 2)
        self:AddHelpWidget("GUIMarineFlashlightHelp", 2)
        self:AddHelpWidget("GUIBuyShotgunHelp", 2)
        -- No more auto weld orders.
        --self:AddHelpWidget("GUIMarineWeldHelp", 2)
        self:AddHelpWidget("GUIMapHelp", 1)
        self:AddHelpWidget("GUITunnelEntranceHelp", 1)
        
        self.timeLastSpitHitEffect = 0
        
    end

    local viewAngles = self:GetViewAngles()
    self.lastYaw = viewAngles.yaw
    self.lastPitch = viewAngles.pitch
    
    -- -1 = leftmost, +1 = right-most
    self.horizontalSwing = 0
    -- -1 = up, +1 = down
        
end

function Marine:GetArmorLevel()

    local armorLevel = 0
    local techTree = self:GetTechTree()

    if techTree then
    
        local armor3Node = techTree:GetTechNode(kTechId.Armor3)
        local armor2Node = techTree:GetTechNode(kTechId.Armor2)
        local armor1Node = techTree:GetTechNode(kTechId.Armor1)
    
        if armor3Node and armor3Node:GetResearched() then
            armorLevel = 3
        elseif armor2Node and armor2Node:GetResearched()  then
            armorLevel = 2
        elseif armor1Node and armor1Node:GetResearched()  then
            armorLevel = 1
        end
        
    end

    return armorLevel

end

function Marine:GetWeaponLevel()

    local weaponLevel = 0
    local techTree = self:GetTechTree()

    if techTree then
        
            local weapon3Node = techTree:GetTechNode(kTechId.Weapons3)
            local weapon2Node = techTree:GetTechNode(kTechId.Weapons2)
            local weapon1Node = techTree:GetTechNode(kTechId.Weapons1)
        
            if weapon3Node and weapon3Node:GetResearched() then
                weaponLevel = 3
            elseif weapon2Node and weapon2Node:GetResearched()  then
                weaponLevel = 2
            elseif weapon1Node and weapon1Node:GetResearched()  then
                weaponLevel = 1
            end
            
    end

    return weaponLevel

end

function Marine:GetCanRepairOverride(target)
    return self:GetWeapon(Welder.kMapName) and HasMixin(target, "Weldable") and ( (target:isa("Marine") and target:GetArmor() < target:GetMaxArmor()) or (not target:isa("Marine") and target:GetHealthScalar() < 0.9) )
end

function Marine:GetSlowOnLand()
    return true
end

function Marine:GetArmorAmount(armorLevels)

    if not armorLevels then
    
        armorLevels = 0
    
        if GetHasTech(self, kTechId.Armor3, true) then
            armorLevels = 3
        elseif GetHasTech(self, kTechId.Armor2, true) then
            armorLevels = 2
        elseif GetHasTech(self, kTechId.Armor1, true) then
            armorLevels = 1
        end
    
    end
    
    return Marine.kBaseArmor + armorLevels * Marine.kArmorPerUpgradeLevel
    
end

function Marine:GetNanoShieldOffset()
    return Vector(0, -0.1, 0)
end

function Marine:OnDestroy()

    Player.OnDestroy(self)
    
    if Client then

        if self.ruptureMaterial then
        
            Client.DestroyRenderMaterial(self.ruptureMaterial)
            self.ruptureMaterial = nil
            
        end
        
        if self.flashlight ~= nil then
            Client.DestroyRenderLight(self.flashlight)
        end

    end
    
end

function Marine:ShouldAutopickupWeapons()
	return self.autoPickup
end

function Marine:ShouldAutopickupBetterWeapons()
	return self.autoPickupBetter
end

function Marine:SetAutopickup( autoPickupEnabled, enablePickupPriorities )

    self.autoPickup = autoPickupEnabled
    self.autoPickupBetter = enablePickupPriorities

end

local function PickupWeapon(self, weapon, wasAutoPickup)
    
    -- some weapons completely replace other weapons (welder > axe).
    local replacement = weapon.GetReplacementWeaponMapName and weapon:GetReplacementWeaponMapName()
    local obsoleteWep = replacement and self:GetWeapon(replacement) -- Player walked over weapon with higher priority. Handled by weapon pickupable getter func.
    local obsoleteSlot
    local activeWeapon = self:GetActiveWeapon()
    local activeSlot = activeWeapon and activeWeapon:GetHUDSlot()
    local delayPassed = (Shared.GetTime() - self.timeOfLastPickUpWeapon > Marine.kMarineBuyAutopickupDelayTime)



    -- find the weapon that is about to be dropped to make room for this one
    local slot = weapon:GetHUDSlot()
    local oldWep = self:GetWeaponInHUDSlot(slot)


    -- Balance mod
    local WelderAutopickupDelayTime = 1
    local delayPassedWelder = (Shared.GetTime() - self.timeOfLastPickUpWeapon > WelderAutopickupDelayTime )
    if weapon and weapon:isa("Welder") then 
        delayPassed = delayPassedWelder
    end


    -- Delay autopickup if we're replacing/upgrading a weapon (Autopickup Better Weapon).
    -- This way it won't immediately pick up your old weapon when you buy a lower priority one. (Having a shotgun then buying a grenade launcher, for example)
    if wasAutoPickup and oldWep and not delayPassed then
        return
    end


    if obsoleteWep then
        
        -- If we are "using", and the weapon we will switch back to when we're done "using"
        -- is the weapon we're replacing, make sure we also replace this reference.
        local obsoleteWepId = obsoleteWep:GetId()
        if obsoleteWepId == self.weaponBeforeUseId then
            self.weaponBeforeUseId = weapon:GetId()
        end
        
        obsoleteSlot = obsoleteWep:GetHUDSlot()
        self:RemoveWeapon(obsoleteWep)
        DestroyEntity(obsoleteWep)
    end
    
    -- perform the actual weapon pickup (also drops weapon in the slot)
    self:AddWeapon(weapon, not wasAutoPickup or slot == 1)

    self:TriggerEffects("marine_weapon_pickup", { effecthostcoords = self:GetCoords() })
    
    -- switch to the picked up weapon if the player deliberately (non-automatically) picked up the weapon,
    -- or if the weapon they were picking up automatically replaced a weapon they already had, and they
    -- currently have no weapons (this avoids the ghost-axe problem).
    if not wasAutoPickup or
        (replacement and (self:GetActiveWeapon() == nil or obsoleteSlot == activeSlot)) then
        self:SetHUDSlotActive(weapon:GetHUDSlot())
    end

    if HasMixin(weapon, "Live") then
        weapon:SetHealth(weapon:GetMaxHealth())
    end
    
    self.timeOfLastPickUpWeapon = Shared.GetTime()
    if oldWep then -- Ensure the last weapon in that slot actually existed and was dropped so you don't override a valid last weapon
        self.lastDroppedWeapon = oldWep
    end
    
end

function Marine:HandleButtons(input)

    PROFILE("Marine:HandleButtons")
    
    Player.HandleButtons(self, input)
    
    if self:GetCanControl() then
    
        -- Update sprinting state
        self:UpdateSprintingState(input)
        
        local flashlightPressed = bit.band(input.commands, Move.ToggleFlashlight) ~= 0
        if not self.flashlightLastFrame and flashlightPressed then
        
            self:SetFlashlightOn(not self:GetFlashlightOn())
            StartSoundEffectOnEntity(kFlashlightSoundName, self, 1, self)
            
        end
        self.flashlightLastFrame = flashlightPressed
        
        local dropPressed = bit.band(input.commands, Move.Drop) ~= 0
        local usePressed = bit.band(input.commands, Move.Use) ~= 0

        if Server then
            
            -- search for weapons to auto-pickup nearby.
            if self.ShouldAutopickupWeapons and self:ShouldAutopickupWeapons() then

                local autopickupWeapon = self:FindNearbyAutoPickupWeapon()
                if autopickupWeapon then
                    PickupWeapon(self, autopickupWeapon, true)
                end
                
            end
            
            -- search for weapons to manually pickup nearby.
            if dropPressed then

                -- drop the active weapon.
                local activeWeapon = self:GetActiveWeapon()
                if self:Drop() then

                    self.lastDroppedWeapon = activeWeapon
                    self.timeOfLastPickUpWeapon = Shared.GetTime()
                end
            end

            if usePressed then

                local pickupWeapon = self:GetNearbyPickupableWeapon()
                -- see if we have a weapon nearby to pickup.
                if pickupWeapon then
                    self.timeOfLastPickUpWeapon = Shared.GetTime()
                    PickupWeapon(self, pickupWeapon, false)
                end
            end
        end
    end
end

function Marine:FindFirstGrenade()
    local weapons = self:GetWeapons()
    if weapons ~= nil then
        for _,v in ipairs(weapons) do
            if v:isa("GrenadeThrower") then
                return v
            end
        end
    end

    return nil
end

function Marine:TertiaryAttack()

    -- Tertiary Attack for a marine for now is the grenade quick throw.
    local weapon = self:GetActiveWeapon()
    if weapon and weapon:isa("GrenadeThrower") then
        weapon:OnTertiaryAttack()
    else

        -- Allow the player to throw a grenade, even when it's not the active weapon.
        local grenadeThrower = self:FindFirstGrenade()
        if grenadeThrower ~= nil and not self.tertiaryAttackLastFrame then
            self:SetActiveWeapon(grenadeThrower.kMapName)
            grenadeThrower:OnTertiaryAttack()
        end
    end
end

function Marine:TertiaryAttackEnd()

    -- Tertiary Attack for a marine for now is the grenade quick throw.
    local activeWeapon = self:GetActiveWeapon()

    if activeWeapon ~= nil and activeWeapon:isa("GrenadeThrower") then
        activeWeapon:OnTertiaryAttackEnd()
    end
end

function Marine:GetFlashlightToggled()
    local edgeOn, edgeOff = self.timeOfLastFlashlightOn, self.timeOfLastFlashlightOff
    if edgeOn and edgeOff then
        local diff = math.abs( edgeOn - edgeOff )
        if diff < 0.75 then
            return true, math.max( edgeOn, edgeOff )
        end
    end

    return false        
end

function Marine:SetFlashlightOn(state)
    local time = Shared.GetTime()
    if state then
        self.timeOfLastFlashlightOn = time
    else
        self.timeOfLastFlashlightOff = time
    end
    self.flashlightOn = state
end

function Marine:GetFlashlightOn()
    return self.flashlightOn
end

function Marine:GetInventorySpeedScalar()
    return 1 - self:GetWeaponsWeight()
end

function Marine:GetCrouchSpeedScalar()
    return Player.kCrouchSpeedScalar
end

function Marine:ModifyGroundFraction(groundFraction)
    return groundFraction > 0 and 1 or 0
end

function Marine:GetMaxSpeed(possible)

    if possible then
        return Marine.kRunMaxSpeed
    end

    local sprintingScalar = self:GetSprintingScalar()
    local maxSprintSpeed = Marine.kWalkMaxSpeed + ( Marine.kRunMaxSpeed - Marine.kWalkMaxSpeed ) * sprintingScalar
    local maxSpeed = ConditionalValue( self:GetIsSprinting(), maxSprintSpeed, Marine.kWalkMaxSpeed )
    
    -- Take into account our weapon inventory and current weapon. Assumes a vanilla marine has a scalar of around .8.
    local inventorySpeedScalar = self:GetInventorySpeedScalar() + .17    
    local useModifier = 1

    local activeWeapon = self:GetActiveWeapon()
    if activeWeapon and self.isUsing and activeWeapon:GetMapName() == Builder.kMapName then
        useModifier = 0.5
    end

    if self:GetHasCatPackBoost() then
        maxSpeed = maxSpeed + kCatPackMoveAddSpeed
    end
    
    return maxSpeed * self:GetSlowSpeedModifier() * inventorySpeedScalar  * useModifier
    
end

function Marine:GetFootstepSpeedScalar()
    return Clamp(self:GetVelocityLength() / (Marine.kRunMaxSpeed * self:GetCatalystMoveSpeedModifier() * self:GetSlowSpeedModifier()), 0, 1)
end

-- Maximum speed a player can move backwards
function Marine:GetMaxBackwardSpeedScalar()
    return Marine.kWalkBackwardSpeedScalar
end

function Marine:GetControllerPhysicsGroup()
    return PhysicsGroup.MarinePlayerGroup
end

function Marine:GetJumpHeight()
    return Player.kJumpHeight - Player.kJumpHeight * self.slowAmount * 0.8
end

function Marine:GetCanBeWeldedOverride()
    return self:GetArmor() < self:GetMaxArmor(), false
end

-- Returns -1 to 1
function Marine:GetWeaponSwing()
    return self.horizontalSwing
end

function Marine:GetWeaponDropTime()
    return self.weaponDropTime
end

local marineTechButtons = { kTechId.Attack, kTechId.Move, kTechId.Defend, kTechId.Construct }
function Marine:GetTechButtons(techId)

    local techButtons
    
    if techId == kTechId.RootMenu then
        techButtons = marineTechButtons
    end
    
    return techButtons
 
end

function Marine:GetChatSound()
    return kChatSound
end

function Marine:GetDeathMapName()
    return MarineSpectator.kMapName
end

-- Returns the name of the primary weapon
function Marine:GetPlayerStatusDesc()

    local status = kPlayerStatus.Void
    
    if (self:GetIsAlive() == false) then
        return kPlayerStatus.Dead
    end
    
    local weapon = self:GetWeaponInHUDSlot(1)
    if (weapon) then
        if (weapon:isa("GrenadeLauncher")) then
            return kPlayerStatus.GrenadeLauncher
        elseif (weapon:isa("Rifle")) then
            return kPlayerStatus.Rifle
        elseif (weapon:isa("Shotgun")) then
            return kPlayerStatus.Shotgun
        elseif (weapon:isa("Flamethrower")) then
            return kPlayerStatus.Flamethrower
        elseif (weapon:isa("HeavyMachineGun")) then
            return kPlayerStatus.HeavyMachineGun
		elseif (weapon:isa("Submachinegun")) then
			return kPlayerStatus.Submachinegun
        end
    end
    
    return status
end

function Marine:GetCanDropWeapon(weapon, ignoreDropTimeLimit)

    if not weapon then
        weapon = self:GetActiveWeapon()
    end
    
    if weapon ~= nil and weapon.GetIsDroppable and weapon:GetIsDroppable() then
    
        -- Don't drop weapons too fast.
        if ignoreDropTimeLimit or (Shared.GetTime() > (self.timeOfLastDrop + Marine.kDropWeaponTimeLimit)) then
            return true
        end
        
    end
    
    return false
    
end

-- Do basic prediction of the weapon drop on the client so that any client
-- effects for the weapon can be dealt with.
function Marine:Drop(weapon, ignoreDropTimeLimit, ignoreReplacementWeapon)

    local activeWeapon = self:GetActiveWeapon()
    
    if not weapon then
        weapon = activeWeapon
    end
    
    if self:GetCanDropWeapon(weapon, ignoreDropTimeLimit) then
    
        if weapon == activeWeapon then
            self:SelectNextWeapon()
        end
        
        weapon:OnPrimaryAttackEnd(self)
        
        if Server then
        
            self:RemoveWeapon(weapon)
            
            local weaponSpawnCoords = self:GetAttachPointCoords(Weapon.kHumanAttachPoint)
            weapon:SetCoords(weaponSpawnCoords)
            
        end

        -- Tell weapon not to be picked up again for a bit
        weapon:Dropped(self)
        
        -- Set activity end so we can't drop like crazy
        self.timeOfLastDrop = Shared.GetTime()
        
        if Server then
        
            if ignoreReplacementWeapon ~= true and weapon.GetReplacementWeaponMapName then
            
                self:GiveItem(weapon:GetReplacementWeaponMapName(), true)
                
            end

            if HasMixin(self, "Team") then
                TeamInfo_SetUserTrackersDirty(self:GetTeamNumber())
            end

        end
        
        return true
        
    end
    
    return false
    
end

function Marine:OnStun()

    local activeWeapon = self:GetActiveWeapon()
    
    if activeWeapon then
        activeWeapon:OnHolster(self)
    end
    
end

function Marine:OnStunEnd()

    local activeWeapon = self:GetActiveWeapon()
    
    if activeWeapon then
        activeWeapon:OnDraw(self)
    end
    
end

function Marine:OnHitGroundStunned()

    if Server then
        StartSoundEffectOnEntity(kHitGroundStunnedSound, self)
    end
    
end

function Marine:GetWeldPercentageOverride()
    return self:GetArmor() / self:GetMaxArmor()
end

function Marine:OnSpitHit(direction)

    if Server then
        self.timeLastSpitHit = Shared.GetTime()
        self.lastSpitDirection = direction  
    end

end

function Marine:GetCanChangeViewAngles()
    return not self:GetIsStunned()
end    

function Marine:OnUseTarget(target)

    local activeWeapon = self:GetActiveWeapon()

    if activeWeapon and target and HasMixin(target, "Construct")
        and ( target:GetCanConstruct(self) or (target.CanBeWeldedByBuilder and target:CanBeWeldedByBuilder()) )
    then
        
        local buildTool = Builder.kMapName
        if self:GetWeapon(Welder.kMapName) ~= nil then
            buildTool = Welder.kMapName
        end

        if not self:GetIsUsing() then
            self.weaponBeforeUseId = activeWeapon:GetId()
            self:SetActiveWeapon(buildTool, true)
        end
        
        activeWeapon = self:GetActiveWeapon()
        if activeWeapon:GetMapName() == Welder.kMapName then
            self:PrimaryAttack()
        end

    else

        self:OnUseEnd()
        
    end

end

function Marine:OnUseEnd()

    local activeWeapon = self:GetActiveWeapon()        

    if activeWeapon and ( activeWeapon:GetMapName() == Builder.kMapName or activeWeapon:GetMapName() == Welder.kMapName ) and self.weaponBeforeUseId ~= Entity.invalidId then

        if activeWeapon:GetMapName() == Welder.kMapName then
            self:PrimaryAttackEnd()
        end

        local weaponBeforeUse = self.weaponBeforeUseId and Shared.GetEntity(self.weaponBeforeUseId)
        if weaponBeforeUse then
            self:SetActiveWeapon(weaponBeforeUse:GetMapName(), true)
        end

    end

end

function Marine:OnUpdateAnimationInput(modelMixin)

    PROFILE("Marine:OnUpdateAnimationInput")
    
    Player.OnUpdateAnimationInput(self, modelMixin)
    
    local animationLength = modelMixin:isa("ViewModel") and 0 or 0.5
    
    if not self:GetIsJumping() and self:GetIsSprinting() then
        modelMixin:SetAnimationInput("move", "sprint")
    end

    if self:GetIsStunned() and self:GetRemainingStunTime() > animationLength then
        modelMixin:SetAnimationInput("move", "stun")
    end
    
    local activeWeapon = self:GetActiveWeapon()
    local catalystSpeed = 1
    
    if activeWeapon and activeWeapon.GetCatalystSpeedBase then
        catalystSpeed = activeWeapon:GetCatalystSpeedBase()
    end
    
    if self:GetHasCatPackBoost() then
        catalystSpeed = kCatPackWeaponSpeed * catalystSpeed
    end

    modelMixin:SetAnimationInput("catalyst_speed", catalystSpeed)
    
end

function Marine:GetDeflectMove()
    return true
end    

function Marine:ModifyJumpLandSlowDown(slowdownScalar)

    if self.strafeJumped then
        slowdownScalar = 0.2 + slowdownScalar
    end
    
    return slowdownScalar

end

local kStrafeJumpForce = 1
local kStrafeJumpDelay = 0.7
function Marine:ModifyJump(input, velocity, jumpVelocity)
    --[[
    local isStrafeJump = input.move.z == 0 and input.move.x ~= 0
    if isStrafeJump and self:GetTimeGroundTouched() + kStrafeJumpDelay < Shared.GetTime() then
    
        local strafeJumpDirection = GetNormalizedVector(self:GetViewCoords():TransformVector(input.move))
        jumpVelocity:Add(strafeJumpDirection * kStrafeJumpForce)
        jumpVelocity.y = jumpVelocity.y * 0.8
        self.strafeJumped = true
        
    else
        self.strafeJumped = false
    end
    
    jumpVelocity:Scale(self:GetSlowSpeedModifier())
    --]]
end

function Marine:OnJump()

    --[[
    Removed as sound event was muted during Sweets sounds-update, b323
    if self.strafeJumped then
        self:TriggerEffects("strafe_jump", {surface = self:GetMaterialBelowPlayer()})           
    end
    --]]

    self:TriggerEffects("jump", {surface = self:GetMaterialBelowPlayer()})
    
end    

function Marine:OnProcessMove(input)

    if Server then
        
        self.ruptured = Shared.GetTime() - self.timeRuptured < kRuptureEffectTime
        self.interruptAim  = Shared.GetTime() - self.interruptStartTime < Gore.kAimInterruptDuration
        
        if self.unitStatusPercentage ~= 0 and self.timeLastUnitPercentageUpdate + 2 < Shared.GetTime() then
            self.unitStatusPercentage = 0
        end    

        --TODO: Create poision mixin
        if self.poisoned then
        
            if self:GetIsAlive() and self.timeLastPoisonDamage + 1 < Shared.GetTime() then
            
                local attacker = Shared.GetEntity(self.lastPoisonAttackerId)
            
                local currentHealth = self:GetHealth()
                local poisonDamage = kBitePoisonDamage
                
                -- never kill the marine with poison only
                if currentHealth - poisonDamage < kPoisonDamageThreshhold then
                    poisonDamage = math.max(0, currentHealth - kPoisonDamageThreshhold)
                end
                
                local _, damageDone = self:DeductHealth(poisonDamage, attacker, nil, true)

                if attacker then
                    SendDamageMessage( attacker, self:GetId(), damageDone, self:GetOrigin(), damageDone )
                end
            
                self.timeLastPoisonDamage = Shared.GetTime()   
                
            end
            
            if self.timePoisoned + kPoisonBiteDuration < Shared.GetTime() then
            
                self.timePoisoned = 0
                self.poisoned = false
                
            end
            
        end
        
        -- check nano armor
        if not self:GetIsInCombat() and self.hasNanoArmor then            
            self:SetArmor(self:GetArmor() + input.time * kNanoArmorHealPerSecond, true)            
        end
        
    end
    
    Player.OnProcessMove(self, input)
    
end

function Marine:GetCanSeeDamagedIcon(ofEntity)
    return HasMixin(ofEntity, "Weldable")
end

function Marine:GetIsInterrupted()
    return self.interruptAim
end

function Marine:OnPostUpdateCamera(deltaTime)

    if self:GetIsStunned() then
        self:SetDesiredCameraYOffset(-1.3)
    end
    
end

-- dont allow marines to me chain stomped. this gives them breathing time and the onos needs to time the stomps instead of spamming
-- and being able to permanently disable the marine
function Marine:GetIsStunAllowed()
    return not self.timeLastStun or self.timeLastStun + kDisruptMarineTimeout < Shared.GetTime()
end

function Marine:GetBodyYawTurnThreshold()
    return -Math.Radians(85), Math.Radians(25)
end

-- %%% New CBM Functions %%% --
function Marine:ProcessExoModularBuyAction(message)
    ModularExo_HandleExoModularBuy(self, message)
end



Shared.LinkClassToMap("Marine", Marine.kMapName, networkVars, true)