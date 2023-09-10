


Shade.kfortressShadeMaterial = PrecacheAsset("models/alien/Shade/Shade_adv.material")

Shade.kFortressShadeAbilityDuration = 10 -- new



local OldShadeOnCreate = Shade.OnCreate
function Shade:OnCreate()

    OldShadeOnCreate(self)

    self.fortressShadeAbilityActive = false

    self.fortressShadeMaterial = false
    self.reducedSized = false
end


function Shade:GetMaxSpeed()

    if self:GetTechId() == kTechId.FortressShade then
        return kAlienStructureMoveSpeed * 0.5
    end

    return kAlienStructureMoveSpeed * 1.5
end


function Shade:GetTechButtons(techId)


    local techButtons = { kTechId.ShadeInk, kTechId.Move, kTechId.ShadeCloak, kTechId.None, 
                          kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
                          
    if self.moving then
        techButtons[2] = kTechId.Stop
    end
    

    -- new TODO maybe not while moving?
    if self:GetTechId() == kTechId.Shade and self:GetResearchingId() ~= kTechId.UpgradeToFortressShade then
        techButtons[5] = kTechId.UpgradeToFortressShade
      end

    --TODO button should be greyed out instead of disappearing
    if self:GetTechId() == kTechId.FortressShade then
        techButtons[6] = kTechId.FortressShadeAbility
    end

    return techButtons
    
end


-- new
function Shade:TriggerFortressShadeAbility(commander)

    -- call twilite

    self.timeOfLastFortressShadeAbility = Shared.GetTime()
    
    return true
end

local OldShadePerformActivation = Shade.PerformActivation
function Shade:PerformActivation(techId, position, normal, commander)

    
    local success = OldShadePerformActivation(self, techId, position, normal, commander)
    
        -- new 
    if techId == kTechId.FortressShadeAbility then
        success = self:TriggerFortressShadeAbility(commander)
    end

    return success, true
    
end



function Shade:GetTechAllowed(techId, techNode, player)

   
    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    allowed = allowed and not self:GetIsOnFire()


     -- dont allow upgrading while moving or if something else researches upgrade or another fortress Shade exists.
    if techId == kTechId.UpgradeToFortressShade then
        allowed = allowed and not self.moving

        allowed = allowed and not GetHasTech(self, kTechId.FortressShade) and not  GetIsTechResearching(self, techId)
    end

    -- dont allow Shades to use it with a fortress build.
    if techId == kTechId.FortressShadeAbility then
        allowed = self:GetTechId() == kTechId.FortressShade
    end

    -- ShadeInk Shadehive requirement got removed
    if techId == kTechId.ShadeInk and self:GetTechId() == kTechId.Shade then 
        allowed = allowed and GetHasTech(self, kTechId.ShadeHive)
    end



    return allowed, canAfford
    
end

class 'FortressShade' (Shade)
FortressShade.kMapName = "fortressShade"
Shared.LinkClassToMap("FortressShade", FortressShade.kMapName, {})

if Server then 
    
    function Shade:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeToFortressShade then
        
            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Shade)   -- get a progress bar at the Shade in the tech tree. TODO Does this affect spec, comm view?
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
            
        end

    end


    function Shade:OnResearchCancel(researchId)

        if researchId == kTechId.UpgradeToFortressShade then
        
            local team = self:GetTeam()
            
            if team then
            
                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.Shade)
                if researchNode then
                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
                end
            end  
        end
    end

    -- Called when research or upgrade complete
    function Shade:OnResearchComplete(researchId)

        if researchId == kTechId.UpgradeToFortressShade then
        
           -- self:SetTechId(kTechId.FortressShade)
            self:UpgradeToTechId(kTechId.FortressShade)

            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.Shade)
            
            if researchNode then     
    
                researchNode:SetResearchProgress(1)
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.FortressShade, self)

                

                
            end
            
        end
    end

end


function Shade:GetMatureMaxHealth()

    if self:GetTechId() == kTechId.FortressShade then
        return kMatureShadeHealth * kFortressHealthScalar
    end

    return kMatureShadeHealth
end


function Shade:GetMatureMaxArmor()

    if self:GetTechId() == kTechId.FortressShade then
        return kMatureShadeArmor * kFortressHealthScalar
    end

    return kMatureShadeArmor
end    



if Client then
    
    function Shade:OnUpdateRender()

           if not self.fortressShadeMaterial and self:GetTechId() == kTechId.FortressShade then
 
                local model = self:GetRenderModel()

                if model and model:GetReadyForOverrideMaterials() then
                
                    model:ClearOverrideMaterials()
                    --local material = GetPrecachedCosmeticMaterial( "Shade", "Fortress" )
                    local material = Shade.kfortressShadeMaterial
                    assert(material)
                    model:SetOverrideMaterial( 0, material )

                    self.fortressShadeMaterial = true
                end

           end
    end
end


function Shade:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if not self.reduceSized and self:GetTechId() == kTechId.Shade then

        modelCoords.xAxis = modelCoords.xAxis * 0.8
        modelCoords.yAxis = modelCoords.yAxis * 0.8
        modelCoords.zAxis = modelCoords.zAxis * 0.8
        self.reducedSize = true

    elseif self.reducedSized and self:GetTechId() == kTechId.FortressShade then
        modelCoords.xAxis = modelCoords.xAxis * 1.25
        modelCoords.yAxis = modelCoords.yAxis * 1.25
        modelCoords.zAxis = modelCoords.zAxis * 1.25
        self.reducedSize = false
    end

    return modelCoords
end

--TODO cant get echoed, test movement speed, button should be greyed out instead of disappearing