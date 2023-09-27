

local kTechStatus = enum({'Available', 'Allowed', 'NotAvailable'})
local kGrey = Color(0.18, 0.18, 0.18, 1)
local kAllowedColor = Color(0.6, 0.6, 0.6, 1)
local kTechMapIconColors =
{
    [kMarineTeamType] = { [kTechStatus.Available] = Color(0.8, 1, 1, 1), [kTechStatus.Allowed] = kAllowedColor,  [kTechStatus.NotAvailable] = kGrey },
    [kAlienTeamType] =  { [kTechStatus.Available] = Color(1, 0.9, 0.4, 1),  [kTechStatus.Allowed] = kAllowedColor,  [kTechStatus.NotAvailable] = kGrey }

}

local CreateProgressMeter = debug.getupvaluex(GUITechMap.Update, "CreateProgressMeter")

local kIconSize = GUIScale(Vector(56, 56, 0))
local kProgressMeterSize = Vector(kIconSize.x, GUIScale(10), 0)



-- color bio 1, mist, rupture, bonewall, contamination, protolab, hives correctly at the techtree

function GUITechMap:Update(deltaTime)

    PROFILE("GUITechMap:Update")
    local teamType = PlayerUI_GetTeamType()
    -- reload the tech map. its possible that the script is not destroyed when changing player class in some cases and would use therefor the incorrect tech map
    if teamType ~= self.teamType then
    
        self:Uninitialize()
        self:Initialize()
        
    end

    self.hoverTechId = nil

    local player = Client.GetLocalPlayer()
    if player and not player:isa("Commander") then
        self.showtechMap = false
    end
    
    if player:isa("Commander") then
    
        if not self.registered then
        
            local script = GetGUIManager():GetGUIScriptSingle("GUICommanderTooltip")
            if script then
                script:Register(self)
                self.registered = true
            end
        
        end
        
    else
        self.registered = false
    end
    
    local showMap = (self.techMapButton or self.showtechMap) and self.visible
    
    self.background:SetIsVisible(showMap)

    if showMap then
    
        local animation = 0.65 + 0.35 * (1 + math.sin(Shared.GetTime() * 5)) * 0.5
    
        local baseColor = kIconColors[self.teamType]
        self.researchingColor = Color(
            baseColor.r * animation,
            baseColor.g * animation,
            baseColor.b * animation, 1)
    
        local techTree = GetTechTree()
        local useColors = kTechMapIconColors[self.teamType]
        local mouseX, mouseY = Client.GetCursorPosScreen()
        
        if techTree then
    
            for i = 1, #self.techIcons do
                
                local techIcon = self.techIcons[i]
                local techId = techIcon.TechId
                local techNode = techTree:GetTechNode(techId)
                local status = kTechStatus.NotAvailable
                local researchProgress = 0

                if techNode then
                
                    researchProgress = techNode:GetResearchProgress()
                
                    if techNode:GetHasTech() then                
                        status = kTechStatus.Available                    
                    elseif techNode:GetAvailable() then
                        status = kTechStatus.Allowed

                         --Community Balance Mod hack
                         if techId == kTechId.BioMassOne and techTree:GetTechNode(kTechId.BioMassOne) then 
                            status = kTechStatus.Available
                        elseif techId == kTechId.Rupture and techTree:GetTechNode(kTechId.BioMassTwo) then 
                            status = kTechStatus.Available
                        elseif techId == kTechId.NutrientMist and techTree:GetTechNode(kTechId.BioMassOne) then 
                            status = kTechStatus.Available
                        elseif techId == kTechId.BoneWall and techTree:GetTechNode(kTechId.BioMassThree) then 
                            status = kTechStatus.Available
                        elseif techId == kTechId.Contamination and techTree:GetTechNode(kTechId.BioMassFour) then 
                            status = kTechStatus.Available
                        end

                    end
                    
                    --if techNode:GetIsPassive() or techNode:GetIsMenu() then
                        -- Community Balance Mod
                    if techNode:GetIsPassive() and techNode:GetAvailable() or techNode:GetIsMenu() then
                        status = kTechStatus.Available

                    elseif techNode:GetIsUpgrade() and techNode:GetAvailable() then    
                        status = kTechStatus.Available
                    elseif techNode:GetIsResearch() then

                        if techNode:GetResearched() and techTree:GetHasTech(techId) then
                            status = kTechStatus.Available
                        elseif techNode:GetAvailable() then
                        
                            status = kTechStatus.Allowed
                            
                        elseif techNode:GetResearching() then
                        
                            status = kTechStatus.Allowed

                        -- Community Balance Mod hack
                        -- color exotech lightgrey when protolab is build
                        elseif techNode:GetTechId() == kTechId.ExosuitTech and techTree:GetTechNode(kTechId.PrototypeLab):GetHasTech() and not techNode:GetAvailable() then
                            status = kTechStatus.Allowed

                            
                        end

                    elseif (techNode:GetIsBuy() or techNode:GetIsActivation()) and techNode:GetAvailable() then
                        status = kTechStatus.Available
                    end
                    
                end
                
                local progressing = false                
                if researchProgress ~= 0 and researchProgress ~= 1 then                
                    progressing = true
                    status = kTechStatus.Available                
                end
                
                local useColor = useColors[status]
                
                if progressing then
                    
                    if not techIcon.ProgressMeter then
                        techIcon.ProgressMeter, techIcon.ProgressMeterBackground = CreateProgressMeter(techIcon.Icon)
                    end
                    
                    techIcon.ProgressMeterBackground:SetIsVisible(self.visible)
                    techIcon.ProgressMeter:SetSize(Vector((kProgressMeterSize.x - 2) * researchProgress, kProgressMeterSize.y - 2, 0))
                    
                    useColor = self.researchingColor
                    
                elseif techIcon.ProgressMeterBackground then
                    techIcon.ProgressMeterBackground:SetIsVisible(false)
                end
                
                if techIcon.ModFunction then
                    techIcon.ModFunction(techIcon.Icon, techIcon.TechId, techIcon.Text)
                end
                
                techIcon.Icon:SetColor(useColor)
                
                if not self.hoveTechId and GUIItemContainsPoint(techIcon.Icon, mouseX, mouseY) then
                    self.hoverTechId = techIcon.TechId
                end
            
            end
        
        end
    
    end

end