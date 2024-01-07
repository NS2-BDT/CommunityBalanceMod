

for i, v in ipairs(kMarineTechMap) do 
    if v[1] == kTechId.Extractor then 
        v[3] = 2 -- 1
    elseif v[1] == kTechId.CommandStation then 
        v[3] = 2 -- 1
    elseif v[1] == kTechId.InfantryPortal then 
        v[3] = 2 -- 1
    elseif v[1] == kTechId.RoboticsFactory then 
        v[3] = 4 -- 3
    elseif v[1] == kTechId.ARCRoboticsFactory then 
        v[3] = 3 -- 2
    elseif v[1] == kTechId.ARC then 
        v[3] = 3 -- 2
    elseif v[1] == kTechId.MAC then 
        v[3] = 4 -- 3
    elseif v[1] == kTechId.SentryBattery then 
        v[3] = 5 -- 4
    elseif v[1] == kTechId.Sentry then 
        v[3] = 5 -- 4
    elseif v[1] == kTechId.AdvancedMarineSupport then 
        v[2] = 7 -- 8
        v[3] = 1 -- 4.5
    elseif v[1] == kTechId.Observatory then 
        v[2] = 5.5 -- 6
    elseif v[1] == kTechId.PhaseTech then 
        v[2] = 5.5 -- 6
    elseif v[1] == kTechId.PhaseGate then 
        v[2] = 5.5 -- 6
    end
end


-- has to be replaced completly to use GetLinePositionForTechMap with the updated tech positions
kMarineLines = 
{
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.Extractor),
    GetLinePositionForTechMap(kMarineTechMap, kTechId.CommandStation, kTechId.InfantryPortal),
    
    { 7, 1, 7, 7 },
    { 7, 4, 3.5, 4 },
    
    -- observatory:
    --{ 6, 5, 7, 5 },
    GetLinePositionForTechMap(kMarineTechMap, kTechId.Armory, kTechId.Observatory),

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