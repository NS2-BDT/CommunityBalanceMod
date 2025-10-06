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

kMarineTechMapYStart = 1
kMarineTechMap =
{

        { kTechId.CommandStation, 7, 1 }, { kTechId.Extractor, 5, 1 },{ kTechId.InfantryPortal, 9, 1 }, { kTechId.AdvancedMarineSupport, 7, 0 },
        
		{ kTechId.Armory, 4, 3.5 }, { kTechId.AdvancedArmory, 6, 3.5 }, { kTechId.JetpackTech, 8, 3.5 },		
		{ kTechId.GrenadeTech, 3.5, 4.5 },{ kTechId.MinesTech, 4.5, 4.5 },{ kTechId.ShotgunTech, 3.5, 2.5 },{ kTechId.Welder, 4.5, 2.5 }, { kTechId.AdvancedWeaponry, 6, 4.5 }, 
		
		{ kTechId.Observatory, 4, 6 }, { kTechId.AdvancedObservatory, 6, 6 }, { kTechId.CargoGate, 8, 6 },
		{ kTechId.PhaseTech, 4, 7 },{ kTechId.PhaseGate, 5, 7 },
		
		{ kTechId.RoboticsFactory, 4, 8.5 }, { kTechId.ARCRoboticsFactory, 6, 8.5 },	
        { kTechId.MAC, 3, 9.5}, { kTechId.SentryBattery, 4, 9.5 },{ kTechId.Sentry, 5, 9.5 }, { kTechId.ARC, 6, 9.5 }, { kTechId.BattleMAC, 8, 9 }, { kTechId.DIS, 8, 8 },		
		
		{ kTechId.PrototypeLab, 4, 11 }, { kTechId.ExosuitTech, 6, 11 },
		
        --{ kTechId.HeavyMachineGunTech, 4.5, 5.5 },

        
        
        
        { kTechId.ArmsLab, 12, 0.25 },                
		{ kTechId.SyncTechOne, 12, 1},
		{ kTechId.SyncTechTwo, 12, 1.5},
		{ kTechId.SyncTechThree, 12, 2},
		{ kTechId.SyncTechFour, 12, 2.5},
		{ kTechId.SyncTechFive, 12, 3}, { kTechId.Armor1, 12.75, 3 },
		{ kTechId.SyncTechSix, 12, 3.5},
		{ kTechId.SyncTechSeven, 12, 4},{ kTechId.Weapons1, 11.25, 4 },
		{ kTechId.SyncTechEight, 12, 4.5},
		{ kTechId.SyncTechNine, 12, 5},
		{ kTechId.SyncTechTen, 12, 5.5},{ kTechId.Armor2, 12.75, 5.5 },
		{ kTechId.SyncTechEleven, 12, 6},
		{ kTechId.SyncTechTwelve, 12, 6.5},{ kTechId.Weapons2, 11.25, 6.5 },
		{ kTechId.SyncTechThirteen, 12, 7},
		{ kTechId.SyncTechFourteen, 12, 7.5},
		{ kTechId.SyncTechFifteen, 12, 8},{ kTechId.Armor3, 12.75, 8 },
		{ kTechId.SyncTechSixteen, 12, 8.5},
		{ kTechId.SyncTechSeventeen, 12, 9},{ kTechId.Weapons3, 11.25, 9 },
		{ kTechId.SyncTechEighteen, 12, 9.5},
		{ kTechId.SyncTechNineteen, 12, 10},
		{ kTechId.SyncTechTwenty, 12, 10.5},
		{ kTechId.SyncTechTwentyone, 12, 11},

		
		--{ kTechId.PuriProtocol, 8, 5 },
		
		}

kMarineLines = 
{
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.Extractor),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.InfantryPortal),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.AdvancedMarineSupport),
	
    --{ 7, 1, 7, 7 },
    --{ 7, 4, 3.5, 4 },
    
    -- observatory:
    --{ 6, 5, 7, 5 },
    --{ 7, 7, 9, 7 },

    --{ 7, 4.5, 8, 4.5},

    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.GrenadeTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.MinesTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.ShotgunTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.Welder),

    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.AdvancedArmory),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.AdvancedWeaponry),
    --GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.HeavyMachineGunTech),
    --GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.PrototypeLab),
    
    GetLinePositionForTechMap(kMarineTechMap, kTechId.PrototypeLab, kTechId.ExosuitTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.JetpackTech),
    
    --GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.Observatory),

    GetLinePositionForTechMap(kMarineTechMap, kTechId.Observatory, kTechId.PhaseTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.PhaseTech, kTechId.PhaseGate),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.Observatory, kTechId.AdvancedObservatory),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedObservatory, kTechId.CargoGate),
	
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechSeven, kTechId.Weapons1),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechTwelve, kTechId.Weapons2),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechSeventeen, kTechId.Weapons3),
	
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechFive, kTechId.Armor1),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechTen, kTechId.Armor2),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechFifteen, kTechId.Armor3),
    
    --{ 7, 3, 9, 3 },
    --{ 7, 4, 9, 4 },
   
    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.ARCRoboticsFactory, kTechId.ARC),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.ARCRoboticsFactory, kTechId.DIS),

    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.MAC),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.ARCRoboticsFactory, kTechId.BattleMAC),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.SentryBattery),
	--GetLinePositionForTechMap(kMarineTechMap, kTechId.SentryBattery, kTechId.PuriProtocol),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.Sentry),
	
	--GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.SubmachinegunTech),
    
}