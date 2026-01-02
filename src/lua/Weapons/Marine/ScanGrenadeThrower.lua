-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\Weapons\Marine\ScanGrenadeThrower.lua
--
--    Created by:   Andreas Urwalek (andi@unknownworlds.com)
--
--    Throws pulse grenades.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/Weapons/Marine/GrenadeThrower.lua")
Script.Load("lua/Weapons/Marine/ScanGrenade.lua")

local networkVars =
{
}

class 'ScanGrenadeThrower' (GrenadeThrower)

ScanGrenadeThrower.kMapName = "scangrenade"

local kModelName = PrecacheAsset("models/marine/grenades/gr_pulse.model")
local kViewModels = GenerateMarineGrenadeViewModelPaths("gr_pulse")
local kAnimationGraph = PrecacheAsset("models/marine/grenades/grenade_view.animation_graph")

function ScanGrenadeThrower:GetThirdPersonModelName()
    return kModelName
end

function ScanGrenadeThrower:GetViewModelName(sex, variant)
    return kViewModels[sex][variant]
end

function ScanGrenadeThrower:GetAnimationGraphName()
    return kAnimationGraph
end

function ScanGrenadeThrower:GetGrenadeClassName()
    return "ScanGrenade"
end

Shared.LinkClassToMap("ScanGrenadeThrower", ScanGrenadeThrower.kMapName, networkVars)