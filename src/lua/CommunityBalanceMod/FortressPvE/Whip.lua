
Whip.kfortressWhipMaterial = PrecacheAsset("models/alien/Whip/Whip_adv.material")

Whip.kFortressWhipAbilityDuration = 10 -- new



local OldWhipOnCreate = Whip.OnCreate
function Whip:OnCreate()

    OldWhipOnCreate(self)

    self.fortressWhipAbilityActive = false
    self.timeOfLastFortressWhipAbility = 0

    self.fortressWhipMaterial = false
    self.reducedSized = false
end



function Whip:GetMaxSpeed()

    if self:GetTechId() == kTechId.FortressWhip then
        return  Whip.kMoveSpeed * 0.5
    end

    return  Whip.kMoveSpeed * 1.5
end




function Whip:GetTechButtons(techId)

    local techButtons = { kTechId.Slap, kTechId.Move, kTechId.None, kTechId.None,
                    kTechId.None, kTechId.None, kTechId.None, kTechId.Consume }
    
    if self:GetIsMature() then
        techButtons[1] = kTechId.WhipBombard
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


-- new
function Whip:TriggerFortressWhipAbility(commander)

    -- TODO 
   
    --kWhipAttackScanInterval= 0.1


    --[[[
    local now = Shared.GetTime()

    if self.timeOfLastFortressWhipAbility + kFortressAbilityCooldown <= now then 
        self.timeOfLastFortressWhipAbility = Shared.GetTime()

        self.fortressWhipAbilityActive = true

         return true
    end

    Log("ability still on cooldown")
    return false -- ability still on cooldown

    ]]
    return true
end

--[[
function Whip:GetCanStartSlapAttack()
    if not self.rooted or self:GetIsOnFire() then
        return false
    end

    if fortressWhipAbilityActive then 
        return Shared.GetTime() > self.nextSlapStartTime - 3
    end 

    return Shared.GetTime() > self.nextSlapStartTime
end


local oldWhipOnUpdate = Whip.OnUpdate
function Whip:OnUpdate(deltaTime)
    oldWhipOnUpdate(self, deltaTime)

    if  self.fortressWhipAbilityActive == true then
        local now = Shared.GetTime()

        -- wenn genau 10 sekunden vergangen sind
        if self.timeOfLastFortressWhipAbility + kFortressAbilityCooldown <= now then 
            self.fortressWhipAbilityActive = false
            Log("10 second cooldown ran out")
        end

    end
end]]

function Whip:PerformActivation(techId, position, normal, commander)


        -- new 
    if techId == kTechId.FortressWhipAbility then
        success = self:TriggerFortressWhipAbility(commander)
    end

    return success, true
    
end


class 'FortressWhip' (Whip)
FortressWhip.kMapName = "fortressWhip"
Shared.LinkClassToMap("FortressWhip", FortressWhip.kMapName, {})

if Server then 
    
    function Whip:UpdateResearch()

        local researchId = self:GetResearchingId()

        if researchId == kTechId.UpgradeToFortressWhip then
        
            local techTree = self:GetTeam():GetTechTree()    
            local researchNode = techTree:GetTechNode(kTechId.Whip)   -- get a progress bar at the Whip in the tech tree. TODO Does this affect spec, comm view?
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

                    self.fortressWhipMaterial = true
                end

           end
    end
end


function Whip:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if not self.reduceSized and self:GetTechId() == kTechId.Whip then

        modelCoords.xAxis = modelCoords.xAxis * 0.8
        modelCoords.yAxis = modelCoords.yAxis * 0.8
        modelCoords.zAxis = modelCoords.zAxis * 0.8
        self.reducedSize = true

    elseif self.reducedSized and self:GetTechId() == kTechId.FortressWhip then
        modelCoords.xAxis = modelCoords.xAxis * 1.25
        modelCoords.yAxis = modelCoords.yAxis * 1.25
        modelCoords.zAxis = modelCoords.zAxis * 1.25
        self.reducedSize = false
    end

    return modelCoords
end

--TODO cant get echoed, test movement speed, button should be greyed out instead of disappearing