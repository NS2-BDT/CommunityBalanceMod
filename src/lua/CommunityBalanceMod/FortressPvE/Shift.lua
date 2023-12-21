
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/storm.surface_shader")

Shift.kfortressShiftMaterial = PrecacheAsset("models/alien/Shift/Shift_adv.material")
Shift.kMoveSpeed = 2.9

Shift.kModelScale = 0.8
local networkVars =
{
    fortressShiftAbilityActive = "boolean"
}

local OldShiftOnCreate = Shift.OnCreate
function Shift:OnCreate()

    OldShiftOnCreate(self)

    self.fortressShiftAbilityActive = false

    self.fortressShiftMaterial = false
end


function Shift:GetMaxSpeed()

    if self:GetTechId() == kTechId.FortressShift then
        return  Shift.kMoveSpeed * 0.75
    end

    return  Shift.kMoveSpeed * 1.25
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


         -- remove fortress ability button for normal Shift if there is a fortress Shift somewhere
         if not ( self:GetTechId() == kTechId.Shift and GetHasTech(self, kTechId.FortressShift) ) then 
            techButtons[6] = kTechId.FortressShiftAbility
        end       
        
        

        if self.moving then
            techButtons[2] = kTechId.Stop
        end

    end

    return techButtons
    
end


-- new
function Shift:TriggerFortressShiftAbility(commander)

    --[[local targets = self:GetStormTargets()

    for _, target in ipairs(targets) do
        if  HasMixin(target, "Storm") and target:isa("Player") then 
            target:TriggerStorm(kStormCloudDuration) 
            target:TriggerEffects("shockwave_trail")
        end
    end
    self:TriggerEffects("whip_trigger_fury")--]]
    
    CreateEntity(StormCloud.kMapName, self:GetOrigin() + Vector(0, 0.5, 0), self:GetTeamNumber())
    
    self.fortressShiftAbilityActive = true
    self:StartStormCloud()
    return true
end

function Shift:StartStormCloud()
    self.stormCloudEndTime = Shared.GetTime() + StormCloud.kLifeSpan
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

    local GetTeleportClassname = debug.getupvaluex( Shift.TriggerEcho, "GetTeleportClassname")
    -- we have to add an exception for fortress pve after the entity search.
    function Shift:TriggerEcho(techId, position)
    
        local teleportClassname = GetTeleportClassname(techId)
        local teleportCost = LookupTechData(techId, kTechDataCostKey, 0)
        
        local success = false
        
        local validPos = GetIsBuildLegal(techId, position, 0, kStructureSnapRadius, self:GetOwner(), self)
        
        local builtStructures = {} 
        local matureStructures = {} 
        
        if validPos then
        
            local teleportAbles = GetEntitiesForTeamWithinXZRange(teleportClassname, self:GetTeamNumber(), self:GetOrigin(), kEchoRange)
            
                for index, entity in ipairs(teleportAbles) do
                    if HasMixin(entity, "Construct") and entity:GetIsBuilt() then

                        -- fortress pve cannot teleport due to GetCanTeleportOverride()
                        if entity:GetCanTeleport() then
                            Log("%s added to built Structures", entity)
                            table.insert(builtStructures, entity)
                        end
                        
                        if HasMixin(entity, "Maturity") and entity:GetIsMature() then


                            -- fortress pve cannot teleport due to GetCanTeleportOverride()
                            if entity:GetCanTeleport() then
                                Log("%s added to mature Structures", entity)
                                table.insert(matureStructures, entity)
                            end
                        end
                    end
                end

                if #matureStructures > 0 then
                    teleportAbles = matureStructures
                elseif #builtStructures > 0 then
                    teleportAbles = builtStructures
                end
                
                Shared.SortEntitiesByDistance(self:GetOrigin(), teleportAbles)
                
            for _, teleportAble in ipairs(teleportAbles) do
            
                if teleportAble:GetCanTeleport() then
                
                    teleportAble:TriggerTeleport(5, self:GetId(), position, teleportCost)
                        
                    if HasMixin(teleportAble, "Orders") then
                        teleportAble:ClearCurrentOrder()
                    end
                    
                    self:TriggerEffects("shift_echo")
                    success = true
                    self.echoActive = true
                    self.timeLastEcho = Shared.GetTime()
                    break
                    
                end
            
            end
        
        end
        
        return success
        
    end












    
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


function Shift:GetShouldRepositionDuringMove()
    return false
end

function Shift:OverrideRepositioningDistance()
    return 0.8
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

local oldShiftOnUpdate = Shift.OnUpdate
function Shift:OnUpdate(deltaTime)
    oldShiftOnUpdate(self, deltaTime)
    if Server then
        if self.stormCloudEndTime then
            local isActive = Shared.GetTime() < self.stormCloudEndTime
            self.fortressShiftAbilityActive = isActive
            self.stormCloudEndTime = isActive and self.stormCloudEndTime or nil
        end
    end
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
            allowed = allowed and ( self:GetTechId() == kTechId.FortressShift ) and GetHasTech(self, kTechId.ShiftHive)
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

            self:MarkBlipDirty()
            
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
    
           local model = self:GetRenderModel()
           local showStorm = not HasMixin(self, "Cloakable") or not self:GetIsCloaked() or not GetAreEnemies(self, Client.GetLocalPlayer())
           
           if model and self.fortressShiftAbilityActive and showStorm then -- and self.stormCloudEndTime then
               if not self.stormedMaterial then
                   self.stormedMaterial = AddMaterial(model, Alien.kStormedThirdpersonMaterialName)

                   self.stormedMaterial:SetParameter("startTime", Shared.GetTime())
                   self.stormedMaterial:SetParameter("offset", 2)
                   self.stormedMaterial:SetParameter("intensity", 3)
               end
           else
               if model and RemoveMaterial(model, self.stormedMaterial) then
                   self.stormedMaterial = nil
               end
           end
           
           if not self.fortressShiftMaterial and self:GetTechId() == kTechId.FortressShift then
 
                --local model = self:GetRenderModel()

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
    return Shift.kMoveSpeed
end


function Shift:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if self:GetTechId() == kTechId.Shift then
        modelCoords.xAxis = modelCoords.xAxis * Shift.kModelScale
        modelCoords.yAxis = modelCoords.yAxis * Shift.kModelScale
        modelCoords.zAxis = modelCoords.zAxis * Shift.kModelScale
    end

    return modelCoords
end


function Shift:GetCanTeleportOverride()
    return not ( self:GetTechId() == kTechId.FortressShift )
end

Shared.LinkClassToMap("Shift", Shift.kMapName, networkVars)