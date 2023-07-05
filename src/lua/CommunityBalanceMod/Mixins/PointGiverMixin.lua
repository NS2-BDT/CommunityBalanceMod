

if Server then 
    oldPointGiverMixinOnConstruct = PointGiverMixin.OnConstruct
    function PointGiverMixin:OnConstruct(builder, newFraction, oldFraction)
        if self:GetClassName() == "Hydra" then
            return
        end
        oldPointGiverMixinOnConstruct(self, builder, newFraction, oldFraction )
    end


    function PointGiverMixin:OnConstructionComplete()

        if self.constructer then

            for _, builderId in ipairs(self.constructer) do

                local builder = Shared.GetEntity(builderId)
                if builder and builder:isa("Player") and HasMixin(builder, "Scoring") then

  

                    local buildtime = LookupTechData(self:GetTechId(), kTechDataBuildTime, kBuildPointValue)
                    local buildPointValue

                    local constructionFraction = self.constructPoints[builderId]

                    if builder:isa("Alien") and buildtime then 
                        buildPointValue = math.max(math.ceil( (buildtime / kAlienBuildPointDivider ) * Clamp(constructionFraction + 0.01 , 0, 1) ), 1)
    
                    elseif builder:isa("Marine") and buildtime then 
                        buildPointValue = math.max(math.ceil( (buildtime / kMarineBuildPointDivider ) * Clamp(constructionFraction + 0.01 , 0, 1) ), 1)
                        
                    else 
                        buildPointValue = math.max(math.floor(kBuildPointValue * Clamp(constructionFraction, 0, 1)), 1)
                    end

                    builder:AddScore(buildPointValue)

                end

            end

        end

        self.constructPoints = nil
        self.constructer = nil

    end

end

