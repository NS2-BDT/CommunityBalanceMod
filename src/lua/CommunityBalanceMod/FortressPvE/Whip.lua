
Whip.kfortressWhipMaterial = PrecacheAsset("models/alien/Whip/Whip_adv.material")
Whip.kMoveSpeed = 2.9

local OldWhipOnCreate = Whip.OnCreate
function Whip:OnCreate()

    OldWhipOnCreate(self)

    self.fortressWhipAbilityActive = false
    self.timeOfLastFortressWhipAbility = 0

    self.fortressWhipMaterial = false
end


function Whip:GetMaxSpeed()

    if self:GetTechId() == kTechId.FortressWhip then
        return  Whip.kMoveSpeed * 0.5
    end

    return  Whip.kMoveSpeed * 1.25
end




function Whip:GetTechButtons(techId)

    local techButtons = { kTechId.WhipAbility, kTechId.Move, kTechId.Slap, kTechId.None,
                    kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
    
    if self:GetIsMature() then
        techButtons[3] = kTechId.WhipBombard
    end
    
    if self.moving then
        techButtons[2] = kTechId.Stop
    end
    
        
    if self:GetTechId() == kTechId.Whip and self:GetResearchingId() ~= kTechId.UpgradeToFortressWhip then
        techButtons[5] = kTechId.UpgradeToFortressWhip
    end

    techButtons[6] = kTechId.FortressWhipAbility
        

    return techButtons
    
end

-- not in vanilla file
function Whip:GetMatureMaxHealth()

    if self:GetTechId() == kTechId.FortressWhip then
        return kFortressMatureWhipHealth
    end

    return kMatureWhipHealth
end


function Whip:GetMatureMaxArmor()

    if self:GetTechId() == kTechId.FortressWhip then
        return kFortressMatureWhipArmor
    end

    return kMatureWhipArmor
end    


function Whip:TriggerFortressWhipAbility(commander)
    return true
end

function Whip:TriggerWhipAbility(commander)
    return true
end


function Whip:PerformActivation(techId, position, normal, commander)

    local success = false
    if techId == kTechId.WhipAbility then
        success = self:TriggerWhipAbility()
    end

    if techId == kTechId.FortressWhipAbility then
        success = self:TriggerFortressWhipAbility(commander)
    end

    return success, true
    
end



function Whip:GetTechAllowed(techId, techNode, player)

   
    local allowed, canAfford = AlienStructure.GetTechAllowed(self, techId, techNode, player)
    allowed = allowed and not self:GetIsOnFire()


     -- dont allow upgrading while moving or if something else researches upgrade or another fortress Whip exists.
    if techId == kTechId.UpgradeToFortressWhip then
        allowed = allowed and not self.moving

        allowed = allowed and not GetHasTech(self, kTechId.FortressWhip) and not  GetIsTechResearching(self, techId)
    end

    -- dont allow normal Whip to use the new fortress ability
    if techId == kTechId.FortressWhipAbility then
        allowed = self:GetTechId() == kTechId.FortressWhip
    end

    
    if techId == kTechId.Stop then
        allowed = self:GetCurrentOrder() ~= nil
    end
    
    if techId == kTechId.Attack then
        allowed = self:GetIsBuilt() and self.rooted == true
    end

    return allowed and self:GetIsUnblocked(), canAfford


end


class 'FortressWhip' (Whip)
FortressWhip.kMapName = "fortressWhip"
Shared.LinkClassToMap("FortressWhip", FortressWhip.kMapName, {})

if Server then 
    
    function Whip:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeToFortressWhip then
        
            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Whip) 
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
            
        end

    end


    function Whip:OnResearchCancel(researchId)

        if researchId == kTechId.UpgradeToFortressWhip then
        
            local team = self:GetTeam()
            
            if team then
            
                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.Whip)
                if researchNode then
                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
                end
            end  
        end
    end

    -- Called when research or upgrade complete
    function Whip:OnResearchComplete(researchId)

        if researchId == kTechId.UpgradeToFortressWhip then
        
            --self:SetTechId(kTechId.FortressWhip)
            self:UpgradeToTechId(kTechId.FortressWhip)
            
            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.Whip)
            
            if researchNode then     
    
                researchNode:SetResearchProgress(1)
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.FortressWhip, self)

                

                
            end
            
        end
    end

end


if Client then
    
    function Whip:OnUpdateRender()

           if not self.fortressWhipMaterial and self:GetTechId() == kTechId.FortressWhip then
 
                local model = self:GetRenderModel()

                if model and model:GetReadyForOverrideMaterials() then
                
                    model:ClearOverrideMaterials()
                    --local material = GetPrecachedCosmeticMaterial( "Whip", "Fortress" )
                    local material = Whip.kfortressWhipMaterial
                    assert(material)
                    model:SetOverrideMaterial( 0, material )

                    model:SetMaterialParameter("highlight", 0.91)

                    self.fortressWhipMaterial = true
                end

           end
    end
end


function Whip:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if self:GetTechId() == kTechId.Whip then

        modelCoords.xAxis = modelCoords.xAxis * 0.8
        modelCoords.yAxis = modelCoords.yAxis * 0.8
        modelCoords.zAxis = modelCoords.zAxis * 0.8
    end

    return modelCoords
end


function Whip:GetCanTeleportOverride()
    return not ( self:GetTechId() == kTechId.FortressWhip )
end