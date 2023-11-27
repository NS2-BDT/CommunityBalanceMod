
--
-- Syncrhonizes the render settings on the camera with the stored render options
--
function Render_SyncRenderOptions()

    local ambientOcclusion  = Client.GetOptionString(kAmbientOcclusionOptionsKey, "true")
    if ambientOcclusion ~= "off" and ambientOcclusion ~= "false" and ambientOcclusion ~= "" then
        -- Normalize the option to "true" if it has an old value
        if ambientOcclusion ~= "true" then
            Client.SetOptionString(kAmbientOcclusionOptionsKey, "true")
        end
        --make sure we're using the "new" valid value
        ambientOcclusion = "true"
    else
        ambientOcclusion = "false"
    end
    
    local atmospherics      = Client.GetOptionBoolean(kAtmosphericsOptionsKey, true)
    local atmoQuality       = Client.GetOptionString("graphics/atmospheric-quality", "low")
    local bloom             = Client.GetOptionBoolean("graphics/display/bloom_new", true)
    local shadows           = Client.GetOptionBoolean("graphics/display/shadows", true)
    local antiAliasing      = Client.GetOptionString(kAntiAliasingOptionsKey, "off")
    local particleQuality   = Client.GetOptionString("graphics/display/particles", "low")

    -- CommunityBalanceMod:
    if particleQuality ~= "high" and particleQuality ~= "low" then 
        --Option was edited by the user
        Client.SetOptionString("graphics/display/particles", "low")
        particleQuality = "low"
    end


    local reflections       = Client.GetOptionBoolean("graphics/reflections", false)
    local refractionQuality = Client.GetOptionString("graphics/refractionQuality", "high")
    local colorblindMode    = Client.GetOptionFloat(kColorBlindOptionsKey, 0)
    local gammaAdjustment   = Clamp(Client.GetOptionFloat("graphics/display/gamma", Client.DefaultRenderGammaAdjustment), Client.MinRenderGamma , Client.MaxRenderGamma)

    Client.SetRenderSetting("mode", "lit")
    Client.SetRenderSetting("ambient_occlusion", ambientOcclusion)
    Client.SetRenderSetting("atmospherics", ToString(atmospherics))
    Client.SetRenderSetting("atmosphericsQuality", atmoQuality)
    Client.SetRenderSetting("bloom"  , ToString(bloom))
    Client.SetRenderSetting("shadows", ToString(shadows))
    Client.SetRenderSetting("anti_aliasing", ToString(antiAliasing))
    Client.SetRenderSetting("particles", particleQuality)
    Client.SetRenderSetting("reflections", ToString(reflections))
    Client.SetRenderSetting("refraction_quality", refractionQuality)
    Client.SetRenderSetting("colorblind_mode", colorblindMode)
    
    Client.SetRenderGammaAdjustment(gammaAdjustment)

end
