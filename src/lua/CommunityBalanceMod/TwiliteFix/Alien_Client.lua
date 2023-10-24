function Alien:UpdateElectrified(isLocal)

    local electrified = self:GetShowElectrifyEffect()

    if self.electrifiedClient ~= electrified then

        if isLocal then

            local viewModel
            if self:GetViewModelEntity() then
                viewModel = self:GetViewModelEntity():GetRenderModel()
            end

            if viewModel then

                if electrified then
                    self.electrifiedViewMaterial = AddMaterial(viewModel, Alien.kElectrifiedViewMaterialName)
                    self.electrifiedViewMaterial:SetParameter("elecAmount",  0.3)
                else

                    if RemoveMaterial(viewModel, self.electrifiedViewMaterial) then
                        self.electrifiedViewMaterial = nil
                    end

                end

            end

        end

        local thirdpersonModel = self:GetRenderModel()
        if thirdpersonModel then

            if electrified then
                self.electrifiedMaterial = AddMaterial(thirdpersonModel, Alien.kElectrifiedThirdpersonMaterialName)
                self.electrifiedMaterial:SetParameter("elecAmount",  1.5)
            else

                if RemoveMaterial(thirdpersonModel, self.electrifiedMaterial) then
                    self.electrifiedMaterial = nil
                end

            end

        end

        self.electrifiedClient = electrified
        
    end

end