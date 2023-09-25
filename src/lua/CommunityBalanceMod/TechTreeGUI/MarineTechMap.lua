-- ======= Copyright (c) 2003-2013, Unknown Worlds Entertainment, Inc. All rights reserved. =======
--
-- lua\MarineTechMap.lua
--
-- Created by: Andreas Urwalek (and@unknownworlds.com)
--
-- Formatted marine tech tree.
--
-- ========= For more information, visit us at http://www.unknownworlds.com =====================

Script.Load("lua/GUIUtility.lua")

kMarineTechMapYStart = 2
kMarineTechMap =
{

        { kTechId.Extractor, 5, 2 },{ kTechId.CommandStation, 7, 2 },{ kTechId.InfantryPortal, 9, 2 },
        
        { kTechId.RoboticsFactory, 9, 4 },{ kTechId.ARCRoboticsFactory, 10, 3 },{ kTechId.ARC, 11, 3 },
                                          { kTechId.MAC, 10, 4 },
                                          { kTechId.SentryBattery, 10, 5 },{ kTechId.Sentry, 11, 5 },
                                          
                                          
        { kTechId.GrenadeTech, 2, 3 },{ kTechId.MinesTech, 3, 3 },{ kTechId.ShotgunTech, 4, 3 },{ kTechId.Welder, 5, 3 },
        
        { kTechId.Armory, 3.5, 4 }, 
         
        { kTechId.AdvancedWeaponry, 2.5, 5.5 }, { kTechId.AdvancedArmory, 3.5, 5.5 },

        --{ kTechId.HeavyMachineGunTech, 4.5, 5.5 },
        
        { kTechId.PrototypeLab, 3.5, 7 },

        { kTechId.ExosuitTech, 3, 8 },{ kTechId.JetpackTech, 4, 8 },
        
        
        { kTechId.ArmsLab, 9, 7 },{ kTechId.Weapons1, 10, 6.5 },{ kTechId.Weapons2, 11, 6.5 },{ kTechId.Weapons3, 12, 6.5 },
                                  { kTechId.Armor1, 10, 7.5 },{ kTechId.Armor2, 11, 7.5 },{ kTechId.Armor3, 12, 7.5 },
                                  
                                  
        { kTechId.AdvancedMarineSupport, 7, 1 },

        { kTechId.Observatory, 5.5, 5 },{ kTechId.PhaseTech, 5.5, 6 },{ kTechId.PhaseGate, 5.5, 7 },
                 

}

kMarineLines = 
{
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.Extractor),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.InfantryPortal),
    
    { 7, 1, 7, 7 },
    { 7, 4, 3.5, 4 },
    
    -- observatory:
    --{ 6, 5, 7, 5 },
    { 7, 7, 9, 7 },

    -- AdvancedMarineSupport:
    --{ 7, 4.5, 8, 4.5},

    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.GrenadeTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.MinesTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.ShotgunTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.Welder),

    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.AdvancedArmory),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.AdvancedWeaponry),
    --GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.HeavyMachineGunTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.PrototypeLab),
    
    GetLinePositionForTechMap(kMarineTechMap, kTechId.PrototypeLab, kTechId.ExosuitTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.PrototypeLab, kTechId.JetpackTech),
    
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.Observatory),

    GetLinePositionForTechMap(kMarineTechMap, kTechId.Observatory, kTechId.PhaseTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.PhaseTech, kTechId.PhaseGate),
    
    GetLinePositionForTechMap(kMarineTechMap, kTechId.ArmsLab, kTechId.Weapons1),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Weapons1, kTechId.Weapons2),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Weapons2, kTechId.Weapons3),
    
    GetLinePositionForTechMap(kMarineTechMap, kTechId.ArmsLab, kTechId.Armor1),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armor1, kTechId.Armor2),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armor2, kTechId.Armor3),
    
    --{ 7, 3, 9, 3 },
    { 7, 4, 9, 4 },
   
    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.ARCRoboticsFactory, kTechId.ARC),

    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.MAC),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.SentryBattery),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SentryBattery, kTechId.Sentry),
    
}