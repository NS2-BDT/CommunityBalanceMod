


Crag.kfortressCragMaterial = PrecacheAsset("models/alien/crag/crag_adv.material")
Crag.kMoveSpeed = 2.9

Crag.kModelScale = 0.8

local OldCragOnCreate = Crag.OnCreate
function Crag:OnCreate()

    OldCragOnCreate(self)

    self.fortressCragAbilityActive = false

    self.fortressCragMaterial = false
end


function Crag:GetOffInfestationHurtPercentPerSecond()

    if self:GetTechId() == kTechId.FortressCrag then 
        return kBalanceOffInfestationHurtPercentPerSecondFortress
    end

    return kBalanceOffInfestationHurtPercentPerSecond
end


-- new
function Crag:GetUmbraTargets()

    local targets = {}

    for _, healable in ipairs(GetEntitiesWithMixinForTeamWithinRange("Live", self:GetTeamNumber(), self:GetOrigin(), Crag.kHealRadius)) do
        if healable:GetIsAlive() then
            table.insert(targets, healable)
        end
    end

    return targets

end

function Crag:PerformUmbra()

    PROFILE("Crag:PerformUmbra")

    local targets = self:GetUmbraTargets()

    for _, target in ipairs(targets) do
        self:TryUmbra(target)
        
    end
end


function Crag:TryUmbra(target)

    if  HasMixin(target, "Umbra") and not target:isa("Player") then 

        target:TriggerEffects("create_pheromone")
        target:SetHasUmbra(true, kCragUmbra)
    end
    
end




function Crag:GetMaxSpeed()

    if self:GetTechId() == kTechId.FortressCrag then
        return Crag.kMoveSpeed * 0.75
    end

    return Crag.kMoveSpeed * 1.25
end


function Crag:GetTechButtons(techId)

    local techButtons = { kTechId.HealWave, kTechId.Move, kTechId.CragHeal, kTechId.None,
                          kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
    
    if self.moving then
        techButtons[2] = kTechId.Stop
    end

    if self:GetTechId() == kTechId.Crag and self:GetResearchingId() ~= kTechId.UpgradeToFortressCrag then
        techButtons[5] = kTechId.UpgradeToFortressCrag
      end

    -- remove fortress ability button for normal crags if there is a fortress crag somewhere
    if not ( self:GetTechId() == kTechId.Crag and GetHasTech(self, kTechId.FortressCrag) ) then 
        techButtons[6] = kTechId.FortressCragAbility
    end

    return techButtons
    
end


function Crag:GetTechAllowed(techId, techNode, player)


    local allowed, canAfford = ScriptActor.GetTechAllowed(self, techId, techNode, player)
    allowed = allowed and not self:GetIsOnFire()


     -- dont allow upgrading while moving or if something else researches upgrade or another fortress crag exists.
    if techId == kTechId.UpgradeToFortressCrag then
        allowed = allowed and not self.moving

        allowed = allowed and not GetHasTech(self, kTechId.FortressCrag) and not  GetIsTechResearching(self, techId)
    end

    -- dont allow normal crags to use the new fortress ability.
    if techId == kTechId.FortressCragAbility then
        allowed = allowed and ( self:GetTechId() == kTechId.FortressCrag ) and GetHasTech(self, kTechId.CragHive)
    end

    -- Healwave craghive requirement got removed
    if techId == kTechId.HealWave and self:GetTechId() == kTechId.Crag then 
        allowed = allowed and GetHasTech(self, kTechId.CragHive)
    end

    return allowed, canAfford

end



-- new
function Crag:TriggerFortressCragAbility(commander)

    self:PerformUmbra()
    self:TriggerEffects("whip_trigger_fury")

    return true
end

local OldCragPerformActivation = Crag.PerformActivation
function Crag:PerformActivation(techId, position, normal, commander)

   
    local success =  OldCragPerformActivation(self, techId, position, normal, commander)
    
        -- new 
    if techId == kTechId.FortressCragAbility then
        success = self:TriggerFortressCragAbility(commander)
    end

    return success, true
    
end


class 'FortressCrag' (Crag)
FortressCrag.kMapName = "fortresscrag"
Shared.LinkClassToMap("FortressCrag", FortressCrag.kMapName, {})

if Server then 
    
    function Crag:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeToFortressCrag then
        
            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Crag)   -- get a progress bar at the crag in the tech tree. TODO Does this affect spec, comm view?
            researchNode:SetResearchProgress(self.researchProgress)
            techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress)) 
            
        end

    end


    function Crag:OnResearchCancel(researchId)

        if researchId == kTechId.UpgradeToFortressCrag then
        
            local team = self:GetTeam()
            
            if team then
            
                local techTree = team:GetTechTree()
                local researchNode = techTree:GetTechNode(kTechId.Crag)
                if researchNode then
                    researchNode:ClearResearching()
                    techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", 0))   
                end
            end  
        end
    end

    -- Called when research or upgrade complete
    function Crag:OnResearchComplete(researchId)

        if researchId == kTechId.UpgradeToFortressCrag then
        
            self:UpgradeToTechId(kTechId.FortressCrag)
            --UpdateHealthValues(newtechid)
            --self:SetTechId(kTechId.FortressCrag)
            
            self:MarkBlipDirty()

            local techTree = self:GetTeam():GetTechTree()
            local researchNode = techTree:GetTechNode(kTechId.Crag)
            
            if researchNode then     
    
                researchNode:SetResearchProgress(1)
                techTree:SetTechNodeChanged(researchNode, string.format("researchProgress = %.2f", self.researchProgress))
                researchNode:SetResearched(true)
                techTree:QueueOnResearchComplete(kTechId.FortressCrag, self)

                

                
            end
            
        end
    end

end


if Client then
    
    function Crag:OnUpdateRender()

           if not self.fortressCragMaterial and self:GetTechId() == kTechId.FortressCrag then
 
                local model = self:GetRenderModel()

                if model and model:GetReadyForOverrideMaterials() then
                
                    model:ClearOverrideMaterials()
                    --local material = GetPrecachedCosmeticMaterial( "Crag", "Fortress" )
                    local material = Crag.kfortressCragMaterial
                    assert(material)
                    model:SetOverrideMaterial( 0, material )

                    model:SetMaterialParameter("highlight", 0.91)

                    self.fortressCragMaterial = true
                end

           end
    end
end


function Crag:GetMatureMaxHealth()

    if self:GetTechId() == kTechId.FortressCrag then
        return kFortressMatureCragHealth
    end

    return kMatureCragHealth
end


function Crag:GetMatureMaxArmor()

    if self:GetTechId() == kTechId.FortressCrag then
        return kFortressMatureCragArmor
    end

    return kMatureCragArmor
end    

function Crag:OverrideRepositioningSpeed()
    return Crag.kMoveSpeed
end


function Crag:GetShouldRepositionDuringMove()
    return false
end

function Crag:OverrideRepositioningDistance()
    return 0.7
end  



function Crag:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if self:GetTechId() == kTechId.Crag then
        modelCoords.xAxis = modelCoords.xAxis * Crag.kModelScale
        modelCoords.yAxis = modelCoords.yAxis * Crag.kModelScale
        modelCoords.zAxis = modelCoords.zAxis * Crag.kModelScale
    end
    return modelCoords
end




function Crag:GetCanTeleportOverride()
    return not ( self:GetTechId() == kTechId.FortressCrag )
end