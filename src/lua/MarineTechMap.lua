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

		{ kTechId.Observatory, 3.25, 3.0 }, { kTechId.AdvancedObservatory, 3.25, 5.0}, { kTechId.CargoTech, 3.25, 7.0 },
		{ kTechId.PhaseTech, 2.25, 3.0 },{ kTechId.PhaseGate, 2.25, 4.0 }, { kTechId.CargoGate, 2.25, 7.0 },
  
		{ kTechId.Armory, 5.75, 3.0 }, { kTechId.SubmachinegunTech, 5.75, 5.0 }, { kTechId.AdvancedArmory, 5.75, 7.0 }, { kTechId.InfantryPrototypeLab, 5.75, 9.0 }, 	
		{ kTechId.Welder, 6.75, 3.0 }, { kTechId.MinesTech, 4.75, 3.0 }, { kTechId.GrenadeTech, 4.75, 4.0 }, { kTechId.ScanGrenadeTech, 4.75, 5.0 }, { kTechId.ShotgunTech, 6.75, 5.0 }, { kTechId.AdvancedWeaponry, 4.75, 7.0 },
		{ kTechId.JetpackTech, 4.75, 9.0 },			
		
		{ kTechId.PrototypeLab, 8.25, 3.0 }, { kTechId.ExoPrototypeLab, 8.25, 5.0 }, { kTechId.DualMinigunTech, 7.75, 7.0 }, { kTechId.CoresExosuitTech, 8.75, 7.0 },
		{ kTechId.ExosuitTech, 9.25, 5.0 },
		
		{ kTechId.RoboticsFactory, 10.75, 3.0 }, { kTechId.ARCRoboticsFactory, 10.75, 5.0 }, { kTechId.BattleMAC, 10.25, 7.0 }, { kTechId.DIS, 11.25, 7.0 },	
        { kTechId.MAC, 9.75, 3.0}, { kTechId.SentryBattery, 11.75, 3.0 },{ kTechId.Sentry, 11.75, 4.0 }, { kTechId.ARC, 11.75, 5.0 }, 		      
        
        --[[{ kTechId.ArmsLab, 1.25, 11.5},                
		{ kTechId.SyncTechOne, 2, 11.5},
		{ kTechId.SyncTechTwo, 2.5, 11.5},
		{ kTechId.SyncTechThree, 3, 11.5},
		{ kTechId.SyncTechFour, 3.5, 11.5},
		{ kTechId.SyncTechFive, 4, 11.5}, { kTechId.Armor1, 4, 12.25 },
		{ kTechId.SyncTechSix, 4.5, 11.5},
		{ kTechId.SyncTechSeven, 5, 11.5},{ kTechId.Weapons1, 5, 10.75 },
		{ kTechId.SyncTechEight, 5.5, 11.5},
		{ kTechId.SyncTechNine, 6, 11.5},
		{ kTechId.SyncTechTen, 6.5, 11.5},{ kTechId.Armor2, 6.5, 12.25 },
		{ kTechId.SyncTechEleven, 7, 11.5},
		{ kTechId.SyncTechTwelve, 7.5, 11.5},{ kTechId.Weapons2, 7.5, 10.75 },
		{ kTechId.SyncTechThirteen, 8, 11.5},
		{ kTechId.SyncTechFourteen, 8.5, 11.5},
		{ kTechId.SyncTechFifteen, 9, 11.5},{ kTechId.Armor3, 9, 12.25 },
		{ kTechId.SyncTechSixteen, 9.5, 11.5},
		{ kTechId.SyncTechSeventeen, 10, 11.5},{ kTechId.Weapons3, 10, 10.75 },
		{ kTechId.SyncTechEighteen, 10.5, 11.5},
		{ kTechId.SyncTechNineteen, 11, 11.5},
		{ kTechId.SyncTechTwenty, 11.5, 11.5},
		{ kTechId.SyncTechTwentyone, 12, 11.5},]]

		{ kTechId.ArmsLab, 5.5, 11.5}, 
		{ kTechId.Armor1, 6.5, 12.0 }, { kTechId.Weapons1, 6.5, 11.0 },
		{ kTechId.Armor2, 7.5, 12.0 }, { kTechId.Weapons2, 7.5, 11.0 },
		{ kTechId.Armor3, 8.5, 12.0 }, { kTechId.Weapons3, 8.5, 11.0 },

		--{ kTechId.PuriProtocol, 8, 5 },
	
		}

kMarineLines = 
{
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.Extractor),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.InfantryPortal),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.AdvancedMarineSupport),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.Observatory),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.Armory),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.PrototypeLab),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.RoboticsFactory),	
	
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.GrenadeTech),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.GrenadeTech, kTechId.ScanGrenadeTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.MinesTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.Welder),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.SubmachinegunTech),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.SubmachinegunTech, kTechId.ShotgunTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SubmachinegunTech, kTechId.AdvancedArmory),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.AdvancedWeaponry),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedArmory, kTechId.InfantryPrototypeLab),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.InfantryPrototypeLab, kTechId.JetpackTech),
	
    GetLinePositionForTechMap(kMarineTechMap, kTechId.PrototypeLab, kTechId.InfantryPrototypeLab),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.PrototypeLab, kTechId.ExoPrototypeLab),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.ExoPrototypeLab, kTechId.ExosuitTech),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.ExoPrototypeLab, kTechId.DualMinigunTech),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.ExoPrototypeLab, kTechId.CoresExosuitTech),

    GetLinePositionForTechMap(kMarineTechMap, kTechId.Observatory, kTechId.PhaseTech),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.PhaseTech, kTechId.PhaseGate),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.Observatory, kTechId.AdvancedObservatory),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedObservatory, kTechId.CargoTech),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.AdvancedObservatory, kTechId.ScanGrenadeTech),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.CargoTech, kTechId.CargoGate),
	
    --[[GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechSeven, kTechId.Weapons1),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechTwelve, kTechId.Weapons2),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechSeventeen, kTechId.Weapons3),
	
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechFive, kTechId.Armor1),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechTen, kTechId.Armor2),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.SyncTechFifteen, kTechId.Armor3),]]
	
	GetLinePositionForTechMap(kMarineTechMap, kTechId.ArmsLab, kTechId.Weapons1),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Weapons1, kTechId.Weapons2),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Weapons2, kTechId.Weapons3),
	
	GetLinePositionForTechMap(kMarineTechMap, kTechId.ArmsLab, kTechId.Armor1),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armor1, kTechId.Armor2),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armor2, kTechId.Armor3),
	
    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.ARCRoboticsFactory),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.ARCRoboticsFactory, kTechId.ARC),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.ARCRoboticsFactory, kTechId.DIS),

    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.MAC),
	GetLinePositionForTechMap(kMarineTechMap, kTechId.ARCRoboticsFactory, kTechId.BattleMAC),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.SentryBattery),
	--GetLinePositionForTechMap(kMarineTechMap, kTechId.SentryBattery, kTechId.PuriProtocol),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.RoboticsFactory, kTechId.Sentry),
	
	
    
}