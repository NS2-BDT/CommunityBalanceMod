

local kStaticBlipsLayer = 2
local kBlipSize = GUIScale(30)
local kBlipColorType = enum( { 'Team', 'Infestation', 'InfestationDying', 'Waypoint', 'PowerPoint', 'DestroyedPowerPoint', 'Scan', 'Drifter', 'MAC', 'EtherealGate', 'HighlightWorld', 'FullColor' } )
local kBlipSizeType = enum( { 'Normal', 'TechPoint', 'Infestation', 'Scan', 'Egg', 'Worker', 'EtherealGate', 'HighlightWorld', 'Waypoint', 'BoneWall', 'UnpoweredPowerPoint', 'Fortress' } )

local kBlipInfo = debug.getupvaluex(GUIMinimap.Initialize, "kBlipInfo" )

kBlipInfo[kMinimapBlipType.FortressWhip] = { kBlipColorType.Team, kBlipSizeType.Fortress, kStaticBlipsLayer, "FortressWhip" }
kBlipInfo[kMinimapBlipType.FortressWhipMature] = { kBlipColorType.Team, kBlipSizeType.Fortress, kStaticBlipsLayer, "FortressWhipMature" }
kBlipInfo[kMinimapBlipType.FortressCrag] = { kBlipColorType.Team, kBlipSizeType.Fortress, kStaticBlipsLayer, "FortressCrag" }
kBlipInfo[kMinimapBlipType.FortressShift] = { kBlipColorType.Team, kBlipSizeType.Fortress, kStaticBlipsLayer, "FortressShift" }
kBlipInfo[kMinimapBlipType.FortressShade] = { kBlipColorType.Team, kBlipSizeType.Fortress, kStaticBlipsLayer, "FortressShade" }

debug.setupvaluex(GUIMinimap.Initialize, "kBlipInfo", kBlipInfo)


function GUIMinimap:SetBlipScale(blipScale)

    if blipScale ~= self.blipScale then

        self.blipScale = blipScale
        self:ResetAll()

        local blipSizeTable = self.blipSizeTable
        local blipSize = Vector(kBlipSize, kBlipSize, 0)
        blipSizeTable[kBlipSizeType.Normal] = blipSize * (0.7 * blipScale)
        blipSizeTable[kBlipSizeType.TechPoint] = blipSize * blipScale
        blipSizeTable[kBlipSizeType.Infestation] = blipSize * (2 * blipScale)
        blipSizeTable[kBlipSizeType.Egg] = blipSize * (0.7 * 0.5 * blipScale)
        blipSizeTable[kBlipSizeType.Worker] = blipSize * (blipScale)
        blipSizeTable[kBlipSizeType.EtherealGate] = blipSize * (1.5 * blipScale)
        blipSizeTable[kBlipSizeType.Waypoint] = blipSize * (1.5 * blipScale)
        blipSizeTable[kBlipSizeType.BoneWall] = blipSize * (1.5 * blipScale)
        blipSizeTable[kBlipSizeType.UnpoweredPowerPoint] = blipSize * (0.45 * blipScale)
        blipSizeTable[kBlipSizeType.Fortress] = blipSize * (0.9 * blipScale)
    end

end
