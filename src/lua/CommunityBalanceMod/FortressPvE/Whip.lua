
Whip.kAnimationGraph = PrecacheAsset("models/alien/whip/whip_1.animation_graph") -- new
Whip.kfortressWhipMaterial = PrecacheAsset("models/alien/Whip/Whip_adv.material")
Whip.kEnzymedMaterialName = "cinematics/vfx_materials/whip_enzyme.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/whip_enzyme.surface_shader")

Whip.kMoveSpeed = 2.9
Whip.kMaxMoveSpeedParam = 7.25
Whip.kFrenzyDuration = 7.5
Whip.kFrenzyAttackSpeed = 2.0

Whip.kModelScale = 0.8

local kDefaultAttackSpeed = 1.5 -- cooldown remains the same, but faster animation faster response when frenzy activates

local networkVars =
    {
        frenzy = "boolean",
        enervating = "boolean",
    }

local OldWhipOnCreate = Whip.OnCreate
function Whip:OnCreate()

    OldWhipOnCreate(self)

    self.timeOfLastFortressWhipAbility = 0
    self.frenzy = false
    self.enervating = false
    self.attackSpeed = kDefaultAttackSpeed

    self.fortressWhipMaterial = false
    
    if Server then
        self.timeFrenzyEnd = 0
        self.timeEnervateEnd = 0
    end

end


function Whip:GetMaxSpeed()
    -- regular Whip
    if self:GetTechId() ~= kTechId.FortressWhip then            
        return  Whip.kMoveSpeed * 1.25
    end
    
    -- fortress whip movement
    if self.frenzy then
        return  Whip.kMoveSpeed * 2.0  -- = 5.8
    end
    
    return Whip.kMoveSpeed * 0.75
    --return self:GetGameEffectMask(kGameEffect.OnInfestation) and Whip.kMoveSpeed * 0.7 or Whip.kMoveSpeed * 0.5

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

      -- remove fortress ability button for normal Whip if there is a fortress Whip somewhere
    if not ( self:GetTechId() == kTechId.Whip and GetHasTech(self, kTechId.FortressWhip) ) then 
        techButtons[6] = kTechId.FortressWhipAbility
    end   

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

    self:TriggerEffects("whip_trigger_fury")

    if Server then
        self:StartFrenzy()  -- on Whip_Server.lua
    end
    return true
end

function Whip:TriggerWhipAbility(commander)
    if Server then
        self:Enervate()  -- on Whip_Server.lua
    end
    return true
end


function Whip:PerformActivation(techId, position, normal, commander)

    local success = false
    if techId == kTechId.WhipAbility then
        success = self:TriggerWhipAbility(commander)
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
        allowed = allowed and self:GetTechId() == kTechId.FortressWhip
    end

    
    if techId == kTechId.Stop then
        allowed = allowed and self:GetCurrentOrder() ~= nil
    end
    
    if techId == kTechId.Attack then
        allowed = allowed and self:GetIsBuilt() and self.rooted == true
    end

    return allowed and self:GetIsUnblocked(), canAfford


end


function Whip:OnUpdate(deltaTime)

    PROFILE("Whip:OnUpdate")
    AlienStructure.OnUpdate(self, deltaTime)
    
    if Server then 
        
        self:UpdateRootState()           
        self:UpdateOrders(deltaTime)
        
        -- CQ: move_speed is used to animate the whip speed.
        -- As GetMaxSpeed is constant, this just toggles between 0 and fixed value depending on moving
        -- Doing it right should probably involve saving the previous origin and calculate the speed
        -- depending on how fast we move
        self.move_speed = self.moving and ( self:GetMaxSpeed() / Whip.kMaxMoveSpeedParam ) or 0
        self.frenzy = Shared.GetTime() < self.timeFrenzyEnd
        self.enervating = Shared.GetTime() < self.timeEnervateEnd
    end
    self.attackSpeed = self.frenzy and Whip.kFrenzyAttackSpeed or kDefaultAttackSpeed
    
end

function Whip:OnUpdateAnimationInput(modelMixin)

    PROFILE("Whip:OnUpdateAnimationInput")  
    
    local activity = "none"
    local timeFromLastAttack = 0
    local outSyncedBy = Server and 0 or (Shared.GetTime() - self.lastAttackStart)

    -- 0.10s is a good value, you have to set net_lag=700 and net_loss=40 to start seeing
    -- the animation not playing, and even then only once in a while. It's still a permissive.
    -- However, when it plays, it is sync with the hit of the tentacle.
    if outSyncedBy <= 0.10 then
        if self.slapping then
            activity = "primary"
        elseif self.bombarding then
            activity = "secondary"        
        end
    end
    
    if self.enervating then
        activity = "enervate"
    end
        
    -- use the back attack animation (both slap and bombard) for this range of yaw
    local useBack = self.attackYaw > 135 and self.attackYaw < 225

    modelMixin:SetAnimationInput("attack_speed", self.attackSpeed)
    modelMixin:SetAnimationInput("use_back", useBack)    
    modelMixin:SetAnimationInput("activity", activity)
    modelMixin:SetAnimationInput("rooted", self.rooted)
    modelMixin:SetAnimationInput("move", self.moving and "run" or "idle")

end


Shared.LinkClassToMap("Whip", Whip.kMapName, networkVars, true)


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
    
           local model = self:GetRenderModel()
           if not self.fortressWhipMaterial and self:GetTechId() == kTechId.FortressWhip then

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
                     
           
           if model then
                local localPlayer = Client.GetLocalPlayer()
                local isVisible = not (HasMixin(self, "Cloakable") and self:GetIsCloaked() and GetAreEnemies(self, localPlayer))
                
                if self.frenzy and isVisible then
                    if not self.enzymedMaterial then
                        self.enzymedMaterial = AddMaterial(model, Whip.kEnzymedMaterialName)
                    end
                else
                    if RemoveMaterial(model, self.enzymedMaterial) then
                        self.enzymedMaterial = nil
                    end
                end
                
           end
           
    end
end


function Whip:OnAdjustModelCoords(modelCoords)
    --gets called a ton each second

    if self:GetTechId() == kTechId.Whip then

        modelCoords.xAxis = modelCoords.xAxis * Whip.kModelScale 
        modelCoords.yAxis = modelCoords.yAxis * Whip.kModelScale 
        modelCoords.zAxis = modelCoords.zAxis * Whip.kModelScale 
    end

    return modelCoords
end


function Whip:GetCanTeleportOverride()
    return not ( self:GetTechId() == kTechId.FortressWhip )
end


class 'FortressWhip' (Whip)
FortressWhip.kMapName = "fortressWhip"

Shared.LinkClassToMap("FortressWhip", FortressWhip.kMapName, {})


