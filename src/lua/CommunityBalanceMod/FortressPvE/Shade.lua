
Script.Load("lua/CommunityBalanceMod/Scripts/ShadeHallucination.lua") -- by twilite

Shade.kfortressShadeMaterial = PrecacheAsset("models/alien/Shade/Shade_adv.material")

Shade.kFortressShadeAbilityDuration = 10 -- new



local OldShadeOnCreate = Shade.OnCreate
function Shade:OnCreate()

    OldShadeOnCreate(self)

    self.fortressShadeAbilityActive = false

    self.fortressShadeMaterial = false
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
    

    if self:GetTechId() == kTechId.Shade and self:GetResearchingId() ~= kTechId.UpgradeToFortressShade then
        techButtons[5] = kTechId.UpgradeToFortressShade
      end


    techButtons[6] = kTechId.ShadeHallucination
 

    return techButtons
    
end




local OldShadePerformActivation = Shade.PerformActivation
function Shade:PerformActivation(techId, position, normal, commander)

    
    local success = OldShadePerformActivation(self, techId, position, normal, commander)
    
        -- new 
    if techId == kTechId.ShadeHallucination then
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

    -- dont allow normal Shades to use the new fortress ability
    if techId == kTechId.ShadeHallucination then
        allowed = self:GetTechId() == kTechId.FortressShade and GetHasTech(self, kTechId.ShadeHive)
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
        return kFortressMatureShadeHealth
    end

    return kMatureShadeHealth
end


function Shade:GetMatureMaxArmor()

    if self:GetTechId() == kTechId.FortressShade then
        return kFortressMatureShadeArmor
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

    if self:GetTechId() == kTechId.Shade then
        modelCoords.xAxis = modelCoords.xAxis * 0.8
        modelCoords.yAxis = modelCoords.yAxis * 0.8
        modelCoords.zAxis = modelCoords.zAxis * 0.8
    end

    return modelCoords
end


function Shade:GetCanTeleportOverride()
    return not ( self:GetTechId() == kTechId.FortressShade )
end



-- twilite
function Shade:TriggerFortressShadeAbility(commander)


    self.timeOfLastFortressShadeAbility = Shared.GetTime()
    
     -- Create ShadeHallucination entity in world at this position with a small offset
     CreateEntity(ShadeHallucination.kMapName, self:GetOrigin() + Vector(0, 0.2, 0), self:GetTeamNumber())

     self.timeOfLastFortressShadeAbility = Shared.GetTime()
     return true

end

if Server then

    function Shade:OnKill(attacker, doer, point, direction)
        
        ScriptActor.OnKill(self, attacker, doer, point, direction)

        if self.hallucinations then
            for _, entId in ipairs(self.hallucinations) do
                if entId ~= Entity.InvalidId then
                    local ent = Shared.GetEntity(entId)
                    if ent then
                        if HasMixin(ent, "Live") and (ent:GetIsAlive()) then
                            ent:Kill()
                        end
                    end
                end
            end
        end

        self.hallucinations = {}

    end
    
end