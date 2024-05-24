local kAnimationGraphSpawnOnly = PrecacheAsset("models/marine/exosuit/exosuit_spawn_only.animation_graph")
local kAnimationGraphEject = PrecacheAsset("models/marine/exosuit/exosuit_spawn_animated.animation_graph")

--local networkVars = {
--
--}
-- Refactor this 
local kLayoutModels = {
    ["MinigunMinigun"] = PrecacheAsset("models/marine/exosuit/exosuit_mm.model"),
    ["RailgunRailgun"] = PrecacheAsset("models/marine/exosuit/exosuit_rr.model"),
    ["ClawRailgun"]    = PrecacheAsset("models/marine/exosuit/exosuit_cr.model"),
    ["ClawMinigun"]    = PrecacheAsset("models/marine/exosuit/exosuit_cr.model"),
}

function Exosuit:SetLayout(layout)
    local model = kLayoutModels[layout] or Exosuit.kModelName
    self:SetModel(model, kAnimationGraphEject)
    self.layout = layout

end

local orig_Exosuit_OnInitialized = Exosuit.OnInitialized
function Exosuit:OnInitialized()
    orig_Exosuit_OnInitialized(self)
    if Server then
        Exo.InitExoModel(self, kAnimationGraphEject)
    end
end

if Server then
    
    function Exosuit:OnUseDeferred()
        
        local player = self.useRecipient
        self.useRecipient = nil
        
        if player and not player:GetIsDestroyed() and self:GetIsValidRecipient(player) then
            
            local weapons = player:GetWeapons()
            for i = 1, #weapons do
                weapons[i]:SetParent(nil)
            end
            
            local exoPlayer = player:Replace(Exo.kMapName, player:GetTeamNumber(), false, spawnPoint, {
                rightArmModuleType = self.rightArmModuleType,
                leftArmModuleType  = self.leftArmModuleType,
                utilityModuleType  = self.utilityModuleType,
                abilityModuleType  = self.abilityModuleType,
            })
            exoPlayer.prevPlayerMapName = player:GetMapName()
            exoPlayer.prevPlayerHealth = player:GetHealth()
            exoPlayer.prevPlayerMaxArmor = player:GetMaxArmor()
            exoPlayer.prevPlayerArmor = player:GetArmor()
            if exoPlayer then
                for i = 1, #weapons do
                    exoPlayer:StoreWeapon(weapons[i])
                end
                exoPlayer:SetMaxArmor(self:GetMaxArmor())
                exoPlayer:SetArmor(self:GetArmor())
                exoPlayer:SetFlashlightOn(self:GetFlashlightOn())
                exoPlayer:TransferParasite(self)
                exoPlayer:TransferExoVariant(self)
                
                -- Set the auto-weld cooldown of the player exo to match the cooldown of the dropped
                -- exo.
                local now = Shared.GetTime()
                local timeLastDamage = self:GetTimeOfLastDamage() or 0
                local waitEnd = timeLastDamage + kCombatTimeOut
                local cooldownEnd = math.max(waitEnd, self.timeNextWeld)
                local cooldownRemaining = math.max(0, cooldownEnd - now)
                exoPlayer.timeNextWeld = now + cooldownRemaining
                
                local newAngles = player:GetViewAngles()
                newAngles.pitch = 0
                newAngles.roll = 0
                newAngles.yaw = GetYawFromVector(self:GetCoords().zAxis)
                exoPlayer:SetOffsetAngles(newAngles)
                -- the coords of this entity are the same as the players coords when he left the exo, so reuse these coords to prevent getting stuck
                exoPlayer:SetCoords(self:GetCoords())
                
                player:TriggerEffects("pickup", { effectshostcoords = self:GetCoords() })
                
                DestroyEntity(self)
            
            end
        end
    end
    
    function Exosuit:OnUse(player, elapsedTime, useSuccessTable)
        if self:GetIsValidRecipient(player) and (not self.useRecipient or self.useRecipient:GetIsDestroyed()) then
            self.useRecipient = player
            self:AddTimedCallback(self.OnUseDeferred, 0)
        end
    end
    
end