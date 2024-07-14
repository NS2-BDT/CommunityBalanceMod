local function _kExoThrusterMinFuel(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Jetpack Energy Min set to: %0.2fs from %0.2fs", value, kExoThrusterMinFuel)
        kExoThrusterMinFuel = value
    else
        Print("Jetpack Energy Min: %0.2fs", kExoThrusterMinFuel)
    end
end
CreateServerAdminCommand("Console_exo_jetpack_min", _kExoThrusterMinFuel, "Jetpack Energy Min", true)

local function _kExoThrusterFuelUsageRate(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Jetpack Energy Cost/s set to: %0.2fs from %0.2fs", value, kExoThrusterFuelUsageRate)
        kExoThrusterFuelUsageRate = value
    else
        Print("Jetpack Energy Cost/s: %0.2fs", kExoThrusterFuelUsageRate)
    end
end
CreateServerAdminCommand("Console_exo_jetpack_rate", _kExoThrusterFuelUsageRate, "Jetpack Energy Cost/s", true)

local function _kExoNanoShieldMinFuel(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Nanoshield Energy Min set to: %0.2fs from %0.2fs", value, kExoNanoShieldMinFuel)
        kExoNanoShieldMinFuel = value
    else
        Print("Nanoshield Energy Min: %0.2fs", kExoNanoShieldMinFuel)
    end
end
CreateServerAdminCommand("Console_exo_nanoshield_min", _kExoNanoShieldMinFuel, "Nanoshield Energy Min", true)

local function _kExoNanoShieldFuelUsageRate(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Nanoshield Energy Cost/s set to: %0.2fs from %0.2fs", value, kExoNanoShieldFuelUsageRate)
        kExoNanoShieldFuelUsageRate = value
    else
        Print("Nanoshield Energy Cost/s: %0.2fs", kExoNanoShieldFuelUsageRate)
    end
end
CreateServerAdminCommand("Console_exo_nanoshield_rate", _kExoNanoShieldFuelUsageRate, "Nanoshield Energy Cost/s", true)

local function _kExoRepairMinFuel(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Nanorepair Energy Min set to: %0.2fs from %0.2fs", value, kExoRepairMinFuel)
        kExoRepairMinFuel = value
    else
        Print("Nanorepair Energy Min: %0.2fs", kExoRepairMinFuel)
    end
end
CreateServerAdminCommand("Console_exo_nanorepair_min", _kExoRepairMinFuel, "Nanorepair Energy Min", true)

local function _kExoRepairFuelUsageRate(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Nanorepair Energy Cost/s set to: %0.2fs from %0.2fs", value, kExoRepairFuelUsageRate)
        kExoRepairFuelUsageRate = value
    else
        Print("Nanorepair Energy Cost/s: %0.2fs", kExoRepairFuelUsageRate)
    end
end
CreateServerAdminCommand("Console_exo_nanorepair_rate", _kExoRepairFuelUsageRate, "Nanorepair Energy Cost/s", true)

local function _kExoCatPackMinFuel(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Catpack Energy Min set to: %0.2fs from %0.2fs", value, kExoCatPackMinFuel)
        kExoCatPackMinFuel = value
    else
        Print("Catpack Energy Min: %0.2fs", kExoCatPackMinFuel)
    end
end
CreateServerAdminCommand("Console_exo_catpack_min", _kExoCatPackMinFuel, "Catpack Energy Min", true)

local function _kExoCatPackFuelUsageRate(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Catpack Energy Cost/s set to: %0.2fs from %0.2fs", value, kExoCatPackFuelUsageRate)
        kExoCatPackFuelUsageRate = value
    else
        Print("Catpack Energy Cost/s: %0.2fs", kExoCatPackFuelUsageRate)
    end
end
CreateServerAdminCommand("Console_exo_catpack_rate", _kExoCatPackFuelUsageRate, "Catpack Energy Cost/s", true)

local function _kRailgunWeight(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Railgun weight set to: %0.2fs from %0.2fs", value, kRailgunWeight)
        kRailgunWeight = value
    else
        Print("Railgun weight: %0.2fs", kRailgunWeight)
    end
end
CreateServerAdminCommand("Console_exo_railgun", _kRailgunWeight, "Railgun Weight", true)

local function _kClawWeight(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Claw weight set to: %0.2fs from %0.2fs", value, kClawWeight)
        kClawWeight = value
    else
        Print("Claw weight: %0.2fs", kClawWeight)
    end
end
CreateServerAdminCommand("Console_exo_claw", _kClawWeight, "Claw Weight", true)

local function _kMinigunWeight(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Minigun weight set to: %0.2fs from %0.2fs", value, kMinigunWeight)
        kMinigunWeight = value
    else
        Print("Minigun weight: %0.2fs", kMinigunWeight)
    end
end
CreateServerAdminCommand("Console_exo_minigun", _kMinigunWeight, "Minigun Weight", true)

local function _kArmorModuleWeight(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Armor weight set to: %0.2fs from %0.2fs", value, kArmorModuleWeight)
        kArmorModuleWeight = value
    else
        Print("Armor weight: %0.2fs", kArmorModuleWeight)
    end
end
CreateServerAdminCommand("Console_exo_armor", _kArmorModuleWeight, "Armor Weight", true)

local function _kThrustersWeight(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Jetpack weight set to: %0.2fs from %0.2fs", value, kThrustersWeight)
        kThrustersWeight = value
    else
        Print("Jetpack weight: %0.2fs", kThrustersWeight)
    end
end
CreateServerAdminCommand("Console_exo_jetpack", _kThrustersWeight, "Jetpack Weight", true)

local function _kNanoRepairWeight(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Nanorepair weight set to: %0.2fs from %0.2fs", value, kNanoRepairWeight)
        kNanoRepairWeight = value
    else
        Print("Nanorepair weight: %0.2fs", kNanoRepairWeight)
    end
end
CreateServerAdminCommand("Console_exo_nanorepair", _kNanoRepairWeight, "Nanorepair Weight", true)

local function _kCatPackWeight(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Catpack weight set to: %0.2fs from %0.2fs", value, kCatPackWeight)
        kCatPackWeight = value
    else
        Print("Catpack weight: %0.2fs", kCatPackWeight)
    end
end
CreateServerAdminCommand("Console_exo_catpack", _kCatPackWeight, "Catpack Weight", true)

local function _kNanoShieldWeight(_, arg)
    if arg then
        local value = tonumber(arg)
        Print("Nanoshield weight set to: %0.2fs from %0.2fs", value, kNanoShieldWeight)
        kNanoShieldWeight = value
    else
        Print("Nanoshield weight: %0.2fs", kNanoShieldWeight)
    end
end
CreateServerAdminCommand("Console_exo_nanoshield", _kNanoShieldWeight, "Nanoshield Weight", true)