


Shift.kfortressShiftMaterial = PrecacheAsset("models/alien/Shift/Shift_adv.material")
Shift.kMoveSpeed = 2.9


local OldShiftOnCreate = Shift.OnCreate
function Shift:OnCreate()

    OldShiftOnCreate(self)

    self.fortressShiftAbilityActive = false

    self.fortressShiftMaterial = false
end


function Shift:GetMaxSpeed()

    if self:GetTechId() == kTechId.FortressShift then
        return  Shift.kMoveSpeed * 0.5
    end

    return  Shift.kMoveSpeed * 1.5
end


function Shift:GetTechButtons(techId)


    local techButtons
                
    if techId == kTechId.ShiftEcho then

        techButtons = { kTechId.TeleportEgg, kTechId.TeleportWhip, kTechId.TeleportHarvester, kTechId.TeleportShift, 
                        kTechId.TeleportCrag, kTechId.TeleportShade, kTechId.None, kTechId.RootMenu }
                        

        if self.veilInRange then
            techButtons[7] = kTechId.TeleportVeil
        elseif self.shellInRange then
            techButtons[7] = kTechId.TeleportShell
        elseif self.spurInRange then
            techButtons[7] = kTechId.TeleportSpur
        end

    else

        techButtons = { kTechId.ShiftEcho, kTechId.Move, kTechId.ShiftEnergize, kTechId.None, 
                        kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
                        

        if self:GetTechId() == kTechId.Shift and self:GetResearchingId() ~= kTechId.UpgradeToFortressShift then
            techButtons[5] = kTechId.UpgradeToFortressShift
        end


        techButtons[6] = kTechId.FortressShiftAbility
       
        
        if self.moving then
            techButtons[2] = kTechId.Stop
        end

    end

    return techButtons
    
end


-- new
function Shift:TriggerFortressShiftAbility(commander)

    local targets = self:GetStormTargets()

    for _, target in ipairs(targets) do
        if  HasMixin(target, "Storm") and target:isa("Player") then 
            target:TriggerStorm(kStormCloudDuration) 
        end
    end
    return true
end


function Shift:GetStormTargets()

    local targets = {}

    for _, stormable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), kEnergizeRange)) do
        if stormable:GetIsAlive() then
            table.insert(targets, stormable)
        end
    end

    return targets

end



if Server then 

    
    local OldShiftPerformActivation = Shift.PerformActivation
    function Shift:PerformActivation(techId, position, normal, commander)

        
        local success = OldShiftPerformActivation(self, techId, position, normal, commander)
        
            -- new 
        if techId == kTechId.FortressShiftAbility then
            success = self:TriggerFortressShiftAbility(commander)
        end

        return success, true
        
    end
end


function Shift:GetMatureMaxHealth()

    if self:GetTechId() == kTechId.FortressShift then
        return kFortressMatureShiftHealth
    end

    return kMatureShiftHealth
end


function Shift:GetMatureMaxArmor()

    if self:GetTechId() == kTechId.FortressShift then
        return kFortressMatureShiftArmor
    end

    return kMatureShiftArmor
end    



function Shift:GetTechAllowed(techId, techNode, player)

    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player) 
    allowed = allowed and not self:GetIsOnFire()


    if techId == kTechId.ShiftEcho then
        allowed = allowed and (GetHasTech(self, kTechId.ShiftHive) or self:GetTechId() == kTechId.FortressShift)
    end
    
     -- dont allow upgrading while moving or if something else researches upgrade or another fortress Shift exists.
        if techId == kTechId.UpgradeToFortressShift then
            allowed = allowed and not self.moving
    
            allowed = allowed and not GetHasTech(self, kTechId.FortressShift) and not  GetIsTechResearching(self, techId)
        elseif techId == kTechId.FortressShiftAbility then
            allowed = self:GetTechId() == kTechId.FortressShift and GetHasTech(self, kTechId.ShiftHive)
        else


                allowed = allowed and not self.echoActive
                if allowed then
            
                    if techId == kTechId.TeleportHydra then
                        allowed = self.hydraInRange
                    elseif techId == kTechId.TeleportWhip then
                        allowed = self.whipInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportTunnel then
                        allowed = self.tunnelInRange
                    elseif techId == kTechId.TeleportCrag then
                        allowed = self.cragInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportShade then
                        allowed = self.shadeInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportShift then
                        allowed = self.shiftInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportVeil then
                        allowed = self.veilInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportSpur then 
                        allowed = self.spurInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportShell then
                        allowed = self.shellInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportHive then
                        allowed = self.hiveInRange
                    elseif techId == kTechId.TeleportEgg then
                        allowed = self.eggInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    elseif techId == kTechId.TeleportHarvester then
                        allowed = self.harvesterInRange and not ( self:GetTechId() == kTechId.Shift and not GetHasTech(self, kTechId.ShiftHive) )
                    end
                
                end

        end
    

    
    return allowed, canAfford
    
end


local function ResetShiftButtons(self)

    self.hydraInRange = false
    self.whipInRange = false
    self.tunnelInRange = false
    self.cragInRange = false
    self.shadeInRange = false
    self.shiftInRange = false
    self.veilInRange = false
    self.spurInRange = false
    self.shellInRange = false
    self.hiveInRange = false
    self.eggInRange = false
    self.harvesterInRange = false
    
end

local function UpdateShiftButtons(self)

    ResetShiftButtons(self)

    local teleportAbles = GetEntitiesWithMixinForTeamWithinXZRange("TeleportAble", self:GetTeamNumber(), self:GetOrigin(), kEchoRange)    
    for _, teleportable in ipairs(teleportAbles) do
    
        if teleportable:GetCanTeleport() then
        
            if teleportable:isa("Hydra") then
                self.hydraInRange = true
            elseif teleportable:isa("Whip") and not ( teleportable:GetTechId() == kTechId.FortressWhip ) then
                self.whipInRange = true
            elseif teleportable:isa("TunnelEntrance") then
                self.tunnelInRange = true
            elseif teleportable:isa("Crag") and not ( teleportable:GetTechId() == kTechId.FortressCrag ) then
                self.cragInRange = true
            elseif teleportable:isa("Shade") and not ( teleportable:GetTechId() == kTechId.FortressShade ) then
                self.shadeInRange = true
            elseif teleportable:isa("Shift") and not  ( teleportable:GetTechId() == kTechId.FortressShift ) then
                self.shiftInRange = true
            elseif teleportable:isa("Veil") then
                self.veilInRange = true
            elseif teleportable:isa("Spur") then
                self.spurInRange = true
            elseif teleportable:isa("Shell") then
                self.shellInRange = true
            elseif teleportable:isa("Hive") then
                self.hiveInRange = true
            elseif teleportable:isa("Egg") then
                self.eggInRange = true
            elseif teleportable:isa("Harvester") then
                self.harvesterInRange = true
            end
            
        end
    end

end
debug.setupvaluex(Shift.OnUpdate, "UpdateShiftButtons", UpdateShiftButtons)

if Server then 
    debug.setupvaluex(Shift.PerformActivation, "UpdateShiftButtons", UpdateShiftButtons)
end


class 'FortressShift' (Shift)
FortressShift.kMapName = "fortressShift"
Shared.LinkClassToMap("FortressShift", FortressShift.kMapName, {})

if Server then 
    
    function Shift:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeToFortressShift then
        
            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Shift)   -- get a progress bar at the Shift in the tech tree. TODO Does this affect spec, comm view?
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
            
        end

    end


    function Shift:OnResearchCancel(researchId)

        if researchId == kTechId.UpgradeToFortressShift then
        
            local team = self:GetTeam()
            
            if team then
            
                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.Shift)
                if researchNode then
                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
                end
            end  
        end
    end

    -- Called when research or upgrade complete
    function Shift:OnResearchComplete(researchId)

        if researchId == kTechId.UpgradeToFortressShift then
        
           -- self:SetTechId(kTechId.FortressShift)
            self:UpgradeToTechId(kTechId.FortressShift)

            
            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.Shift)
            
            if researchNode then     
    
                researchNode:SetResearchProgress(1)
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.FortressShift, self)

                
            end
        end
    end

end


if Client then
    
    function Shift:OnUpdateRender()

           if not self.fortressShiftMaterial and self:GetTechId() == kTechId.FortressShift then
 
                local model = self:GetRenderModel()

                if model and model:GetReadyForOverrideMaterials() then
                
                    model:ClearOverrideMaterials()
                    --local material = GetPrecachedCosmeticMaterial( "Shift", "Fortress" )
                    local material = Shift.kfortressShiftMaterial
                    assert(material)
                    model:SetOverrideMaterial( 0, material )

                    model:SetMaterialParameter("highlight", 0.91)

                    self.fortressShiftMaterial = true
                end

           end
    end
end

function Shift:OverrideRepositioningSpeed()
    return kAlienStructureMoveSpeed
end


function Shift:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if self:GetTechId() == kTechId.Shift then
        modelCoords.xAxis = modelCoords.xAxis * 0.8
        modelCoords.yAxis = modelCoords.yAxis * 0.8
        modelCoords.zAxis = modelCoords.zAxis * 0.8
    end

    return modelCoords
end


function Shift:GetCanTeleportOverride()
    return not ( self:GetTechId() == kTechId.FortressShift )
end