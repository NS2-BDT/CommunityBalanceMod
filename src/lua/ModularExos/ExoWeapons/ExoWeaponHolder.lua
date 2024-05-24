local kViewModelNames = {
    ["minigun+minigun"] = PrecacheAsset("models/marine/exosuit/exosuit_mm_view.model"),
    ["railgun+railgun"] = PrecacheAsset("models/marine/exosuit/exosuit_rr_view.model"),
    ["claw+railgun"]    = PrecacheAsset("models/marine/exosuit/exosuit_cr_view.model"),
    ["claw+minigun"]    = PrecacheAsset("models/marine/exosuit/exosuit_cm_view.model"),
}

local kAnimationGraphs = {
    ["minigun+minigun"] = PrecacheAsset("models/marine/exosuit/exosuit_mm_view.animation_graph"),
    ["railgun+railgun"] = PrecacheAsset("models/marine/exosuit/exosuit_rr_view.animation_graph"),
    ["claw+railgun"]    = PrecacheAsset("models/marine/exosuit/exosuit_cr_view.animation_graph"),
    ["claw+minigun"]    = PrecacheAsset("models/marine/exosuit/exosuit_cm_view.animation_graph"),
}

local orig_ExoWeaponHolder_GetViewModelName = ExoWeaponHolder.GetViewModelName
function ExoWeaponHolder:GetViewModelName()
    local player = self:GetParent()
    return player.viewModelName
end

local orig_ExoWeaponHolder_GetAnimationGraphName = ExoWeaponHolder.GetAnimationGraphName
function ExoWeaponHolder:GetAnimationGraphName()
    local player = self:GetParent()
    return player.viewModelGraphName
end

