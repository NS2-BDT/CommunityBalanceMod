-- ========= Community Balance Mod ===============================
--
--  "lua\Alien_Client.lua"
--
--    Created by:   Drey (@drey3982)
--
-- ===============================================================


Alien.kStormedViewMaterialName = "cinematics/vfx_materials/storm_view.material"
Alien.kStormedThirdpersonMaterialName = "cinematics/vfx_materials/storm.material"
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/storm_view.surface_shader")
Shared.PrecacheSurfaceShader("cinematics/vfx_materials/storm.surface_shader")

local cinematicCeleDuration = 3.2


function Alien:UpdateStormEffect(isLocal)
  

    if self.stormedClient ~= self.stormed then

        if isLocal then

            local viewModel
            if self:GetViewModelEntity() then
                viewModel = self:GetViewModelEntity():GetRenderModel()
            end

            if viewModel then
               
                if self.stormed then
                    self.stormedViewMaterial = AddMaterial(viewModel, Alien.kStormedViewMaterialName)
 
                    self.cinematicCele = Client.CreateCinematic(RenderScene.Zone_ViewModel)
                    self.cinematicCele:SetCinematic(FilterCinematicName(self:GetSpeedParticles()))
                      --self.cinematicCele:SetRepeatStyle(Cinematic.Repeat_Loop)
                    self.startedCinematicCele = Shared.GetTime()
                else

                    if self.cinematicCele then 
                        Client.DestroyCinematic(self.cinematicCele)
                        self.cinematicCele  = nil
                    end

                    if RemoveMaterial(viewModel, self.stormedViewMaterial) then
                        self.stormedViewMaterial = nil

                    end
                end
            end
        end

        local thirdpersonModel = self:GetRenderModel()
        if thirdpersonModel then

            if self.stormed then
                self.stormedMaterial = AddMaterial(thirdpersonModel, Alien.kStormedThirdpersonMaterialName)
            else

                if RemoveMaterial(thirdpersonModel, self.stormedMaterial) then
                    self.stormedMaterial = nil
                end
            end
        end
        self.stormedClient = self.stormed

    elseif self.stormed and self.startedCinematicCele and self.cinematicCele 
        and self.startedCinematicCele + cinematicCeleDuration < Shared.GetTime() then
            Client.DestroyCinematic(self.cinematicCele)
            self.cinematicCele = Client.CreateCinematic(RenderScene.Zone_ViewModel)
            self.cinematicCele:SetCinematic(FilterCinematicName(self:GetSpeedParticles()))
        self.startedCinematicCele = Shared.GetTime()
    end

end

function Alien:GetSpeedParticles()
    return Alien.kCelerityViewCinematic
end




local oldAlienUpdateClientEffects = Alien.UpdateClientEffects
function Alien:UpdateClientEffects(deltaTime, isLocal)
    oldAlienUpdateClientEffects(self, deltaTime, isLocal)

    self:UpdateStormEffect(isLocal)
end

