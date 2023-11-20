
local kLocales = {
    HALLUCINATION_CLOUD = "Cloaking Haze",
    HALLUCINATION_CLOUD_TOOLTIP = "Creates a cloud which cloaks players, eggs and drifters in target area.",
}        

local oldResolveString = Locale.ResolveString
function Locale.ResolveString( Key )
    return kLocales[Key] or oldResolveString( Key )
end
