

local kStaticBlipsLayer = 2
local kBlipSize = GUIScale(30)
local kBlipColorType = enum( { 'Team', 'Infestation', 'InfestationDying', 'Waypoint', 'PowerPoint', 'DestroyedPowerPoint', 'Scan', 'Drifter', 'MAC', 'EtherealGate', 'HighlightWorld', 'FullColor' } )
local kBlipSizeType = enum( { 'Normal', 'TechPoint', 'Infestation', 'Scan', 'Egg', 'Worker', 'EtherealGate', 'HighlightWorld', 'Waypoint', 'BoneWall', 'UnpoweredPowerPoint', 'Fortress' } )

local kBlipInfo = debug.getupvaluex(GUIMinimap.Initialize, "kBlipInfo" )

kBlipInfo[kMinimapBlipType.Armory] = { kBlipColorType.Team, kBlipSizeType.Normal, kStaticBlipsLayer, "Armory" }
kBlipInfo[kMinimapBlipType.AdvancedArmory] = { kBlipColorType.Team, kBlipSizeType.Normal, kStaticBlipsLayer, "AdvancedArmory" }
kBlipInfo[kMinimapBlipType.ARC] = { kBlipColorType.Team, kBlipSizeType.Normal, kStaticBlipsLayer, "ARC" }
kBlipInfo[kMinimapBlipType.ARCDeployed] = { kBlipColorType.Team, kBlipSizeType.Normal, kStaticBlipsLayer, "ARCDeployed" }
kBlipInfo[kMinimapBlipType.HiveFresh] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer, "HiveFresh" }
kBlipInfo[kMinimapBlipType.HiveFreshOccupied] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer, "HiveFreshOccupied" }
kBlipInfo[kMinimapBlipType.Hive] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer, "Hive" }
kBlipInfo[kMinimapBlipType.HiveOccupied] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer, "HiveOccupied" }
kBlipInfo[kMinimapBlipType.HiveMature] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer, "HiveMature" }
kBlipInfo[kMinimapBlipType.HiveMatureOccupied] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer, "HiveMatureOccupied" }
kBlipInfo[kMinimapBlipType.CommandStationOccupied] = { kBlipColorType.Team, kBlipSizeType.TechPoint, kStaticBlipsLayer , "CommandStationOccupied"}
kBlipInfo[kMinimapBlipType.DrifterEgg] = { kBlipColorType.Drifter, kBlipSizeType.Worker, kStaticBlipsLayer }
kBlipInfo[kMinimapBlipType.WhipMature] = { kBlipColorType.Team, kBlipSizeType.Normal, kStaticBlipsLayer, "WhipMature" }
kBlipInfo[kMinimapBlipType.Whip] = { kBlipColorType.Team, kBlipSizeType.Normal, kStaticBlipsLayer, "Whip" }

debug.setupvaluex(GUIMinimap.Initialize, "kBlipInfo", kBlipInfo)






