local networkVars = {
    techActiveMaskHIGH = "integer",
    techActiveMaskLOW = "integer",

    techOwnedMaskHIGH = "integer",
    techOwnedMaskLOW = "integer",
}
Shared.LinkClassToMap("TeamInfo", TeamInfo.kMapName, networkVars)

-- Relevant techs must be ordered with children techs coming after their parents
TeamInfo.kRelevantTechIdsMarine =
{

    kTechId.ShotgunTech,
    --kTechId.HeavyMachineGunTech,
    kTechId.MinesTech,
    kTechId.WelderTech,
    kTechId.GrenadeTech,
    
    kTechId.AdvancedArmory,
    kTechId.AdvancedArmoryUpgrade,
    kTechId.AdvancedWeaponry,

    kTechId.Weapons1,
    kTechId.Weapons2,
    kTechId.Weapons3,
    kTechId.Armor1,
    kTechId.Armor2,
    kTechId.Armor3,

    kTechId.PrototypeLab,
    kTechId.UpgradeToAdvancedPrototypeLab, -- CommunityBalanceMod 
    kTechId.JetpackTech,
    kTechId.ExosuitTech,
    kTechId.DualMinigunTech,

    kTechId.ARCRoboticsFactory,
    kTechId.UpgradeRoboticsFactory,
    kTechId.MACEMPTech,
    kTechId.MACSpeedTech,
    
    kTechId.Observatory,
    kTechId.PhaseTech,

    kTechId.AdvancedMarineSupport,
}

--FortressPvE
TeamInfo.kRelevantTechIdsAlien =
{

    kTechId.CragHive,
    kTechId.UpgradeToCragHive,
    kTechId.Shell,
    kTechId.TwoShells,
    kTechId.ThreeShells,
    
    kTechId.ShadeHive,
    kTechId.UpgradeToShadeHive,
    kTechId.Veil,
    kTechId.TwoVeils,
    kTechId.ThreeVeils,
    
    kTechId.ShiftHive,
    kTechId.UpgradeToShiftHive,
    kTechId.Spur,
    kTechId.TwoSpurs,
    kTechId.ThreeSpurs,

    -- CommunityBalanceMod
    -- limited to 32 due to bitmasking overflow, see utility: CreateBitMask
    --[[
   kTechId.FortressCrag,
    kTechId.UpgradeToFortressCrag,
    kTechId.FortressShift,
    kTechId.UpgradeToFortressShift,
    kTechId.FortressShade,
   kTechId.UpgradeToFortressShade,
     kTechId.FortressWhip,
    kTechId.UpgradeToFortressWhip,]]

    
    kTechId.ResearchBioMassOne,
    kTechId.ResearchBioMassTwo,
    kTechId.ResearchBioMassThree,

    kTechId.Leap,
    kTechId.Xenocide,
    kTechId.BileBomb,
    kTechId.WebTech,
    kTechId.Umbra,
    kTechId.Spores,
    kTechId.MetabolizeEnergy,
    kTechId.MetabolizeHealth,
    kTechId.Stab,
    kTechId.Charge,
    kTechId.BoneShield,
    kTechId.Stomp,
    
}

local function CreateRelevantIdMaskMarine()
    local t = {}

    for i, techId in ipairs(TeamInfo.kRelevantTechIdsMarine) do
        local s = EnumToString(kTechId, techId)
        t[i] = s
    end
    
    TeamInfo.kRelevantIdMaskMarine = BitMask64_CreateTable(t)
end

local function CreateRelevantIdMaskAlien()
    local t = {}

    for i,techId in ipairs(TeamInfo.kRelevantTechIdsAlien) do
        local s = EnumToString(kTechId, techId)
        t[i] = s
    end

    TeamInfo.kRelevantIdMaskAlien = BitMask64_CreateTable(t)
end

debug.setupvaluex(TeamInfo.OnCreate, "CreateRelevantIdMaskMarine", CreateRelevantIdMaskMarine)
debug.setupvaluex(TeamInfo.OnCreate, "CreateRelevantIdMaskAlien", CreateRelevantIdMaskAlien)


if Server then
    local oldReset = TeamInfo.Reset
    function TeamInfo:Reset()
        oldReset(self)

        self.techActiveMaskHIGH = 0
        self.techActiveMaskLOW = 0

        self.techOwnedMaskHIGH = 0
        self.techOwnedMaskLOW = 0
        -- BitMask64_InitNetVars(self, "techActiveMask")
        -- BitMask64_InitNetVars(self, "techOwnedMask")
    end    
end


function TeamInfo:UpdateInfo()

    if self.team then
    
        self:SetTeamNumber(self.team:GetTeamNumber())
        self.teamResources = self.team:GetTeamResources()
        self.playerCount = Clamp(self.team:GetNumPlayers(), 0, 31)
        self.totalTeamResources = self.team:GetTotalTeamResources()
        self.personalResources = 0
        for index, player in ipairs(self.team:GetPlayers()) do
            self.personalResources = self.personalResources + player:GetResources()
        end
        
        local rtCount = 0
        local rtActiveCount = 0
        local rts = GetEntitiesForTeam("ResourceTower", self:GetTeamNumber())
        for index, rt in ipairs(rts) do
        
            if rt:GetIsAlive() then
                rtCount = rtCount + 1
                if rt:GetIsCollecting() then
                    rtActiveCount = rtActiveCount + 1
                end
            end
            
        end
        
        self.numCapturedResPoints = rtCount
        self.numResourceTowers = rtActiveCount
        self.kills = self.team:GetKills()
        
        if Server then
        
            if self.lastTechTreeUpdate == nil or (Shared.GetTime() > (self.lastTechTreeUpdate + TeamInfo.kTechTreeUpdateInterval)) then
                if not GetGamerules():GetGameStarted() then
                    -- BalanceMod:
                    -- self.techActiveMask = 0
                    -- self.techOwnedMask = 0

                    -- BitMask64_InitNetVars(self, "techActiveMask")
                    -- BitMask64_InitNetVars(self, "techOwnedMask")
                    self.techActiveMaskHIGH = 0
                    self.techActiveMaskLOW = 0

                    self.techOwnedMaskHIGH = 0
                    self.techOwnedMaskLOW = 0
                else
                    self:UpdateTechTreeInfo(self.team:GetTechTree())    
                end
            end
        
            if self.latestResearchId ~= 0 and self.researchDisplayTime < Shared.GetTime() then
            
                self.latestResearchId = 0
                self.researchDisplayTime = 0
                self.lastTechPriority = 0
                
            end
            
            local team = self:GetTeam()
            self.numCapturedTechPoint = team:GetNumCapturedTechPoints()
            
            self.lastCommPingTime = team:GetCommanderPingTime()
            self.lastCommPingPosition = team:GetCommanderPingPosition() or Vector(0,0,0)
            
            self.supplyUsed = team:GetSupplyUsed()
            
            self.spawnQueueTotal = team:GetTotalInRespawnQueue()

            if self.userTrackersDirty then
                self:UpdateUserTrackers()
                self.userTrackersDirty = false
            end
            
        end
        
    end
    
end

function TeamInfo:GetTeamTechTreeInfo()
    -- BalanceMod:
    -- return self.techActiveMask, self.techOwnedMask
    -- return BitMask64_NetVarsToSingleValue(self, "techActiveMask"), BitMask64_NetVarsToSingleValue(self, "techOwnedMask")

    return BitMask64_Combine(self.techActiveMaskHIGH, self.techActiveMaskLOW), BitMask64_Combine(self.techOwnedMaskHIGH, self.techOwnedMaskLOW)
end


function TeamInfo:UpdateBitmasks(techId, techNode)

    local relevantIdMask, relevantTechIds = self:GetRelevantTech()

    local techIdString = EnumToString(kTechId, techId)
    local mask = relevantIdMask[techIdString]
    -- local techActiveMask = BitMask64_NetVarsToSingleValue(self, "techActiveMask")
    -- local techOwnedMask = BitMask64_NetVarsToSingleValue(self, "techOwnedMask")
    local techActiveMask = BitMask64_Combine(self.techActiveMaskHIGH, self.techActiveMaskLOW)
    local techOwnedMask = BitMask64_Combine(self.techOwnedMaskHIGH, self.techOwnedMaskLOW)
    
    -- Tech researching or researched
    if (techNode:GetResearching() and not techNode:GetResearched()) or techNode:GetHasTech() then
        techActiveMask = bit.bor(techActiveMask, mask)
    else
        techActiveMask = bit.band(techActiveMask, bit.bnot(mask))
    end
    
    -- Tech has been owned at some point
    if techNode:GetHasTech() then
        techOwnedMask = bit.bor(techOwnedMask, mask)
    end
    
    -- Hide prerequisite techs when this tech has been researched
    if techNode:GetResearched() or (techNode:GetIsSpecial() and techNode:GetHasTech()) then
        local preq1 = techNode:GetPrereq1()
        local preq2 = techNode:GetPrereq2()
        if preq1 ~= nil then
            local msk = relevantIdMask[EnumToString(kTechId, preq1)]
            if msk then
                techActiveMask = bit.band(techActiveMask, bit.bnot(msk))
                techOwnedMask = bit.band(techOwnedMask, bit.bnot(msk))
            end
        end
        if preq2 ~= nil then
            local msk = relevantIdMask[EnumToString(kTechId, preq2)]
            if msk then
                techActiveMask = bit.band(techActiveMask, bit.bnot(msk))
                techOwnedMask = bit.band(techOwnedMask, bit.bnot(msk))
            end
        end
    end

    -- BitMask64_SingleValueToNetVars(self, "techActiveMask", techActiveMask)
    -- BitMask64_SingleValueToNetVars(self, "techOwnedMask", techOwnedMask)
    self.techActiveMaskHIGH, self.techActiveMaskLOW = BitMask64_Split(techActiveMask)
    self.techOwnedMaskHIGH, self.techOwnedMaskLOW = BitMask64_Split(techOwnedMask)
end
