Script.Load("lua/Fog.lua")

--
-- Intercept calls to Client.SetRenderSetting to allow us to detect settings changes.
--
local temporalAOHistoryClearFramesRemain = 2 -- start at 2, just in case... doesn't hurt.
local old_Client_SetRenderSetting = Client.SetRenderSetting
function Client.SetRenderSetting(key, value)
    
    -- Whenever we enable any ambient occlusion setting that uses a history buffer, we need be sure
    -- to clear the history buffer on the first frame to avoid displaying garbage.
    if key == "ambient_occlusion" then
        if value == "new_ao_high" or value == "new_ao_half" then
            old_Client_SetRenderSetting("temporal_ao_clear", "true")
            temporalAOHistoryClearFramesRemain = 2
        end
    end
    
    old_Client_SetRenderSetting(key, value)
    
end

Event.Hook("Console_clear_ao_history", function()
    old_Client_SetRenderSetting("temporal_ao_clear", "true")
    temporalAOHistoryClearFramesRemain = 2
end)

Event.Hook("UpdateRender", function()
    
    -- Disable the render setting that causes the AO history buffer to be cleared.
    if temporalAOHistoryClearFramesRemain > 0 then
        temporalAOHistoryClearFramesRemain = temporalAOHistoryClearFramesRemain - 1
        if temporalAOHistoryClearFramesRemain == 0 then
            old_Client_SetRenderSetting("temporal_ao_clear", "false")
        end
    end
    
end)

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

local function RenderConsoleHandler(name, key)
    return function (enabled)
        if enabled == nil then
            enabled = "true"
        end
        Client.SetRenderSetting(name, ToString(enabled))
        Client.SetOptionBoolean(key, enabled == "true")
    end
end

local function RenderConsoleIntegerHandler(name, key)
    return function (int)
        if int == nil then
            int = 50
        end
        Client.SetRenderSetting(key, tonumber(int))
        Client.SetOptionInteger(key, tonumber(int))
        Render_SyncRenderOptions()
    end
end

local function RenderConsoleGammaHandler()

end

local function OnConsoleRenderMode(mode)
    if Shared.GetCheatsEnabled() or Shared.GetTestsEnabled() then
        if mode == nil then
            mode = "lit"
        end
        Client.SetRenderSetting("mode", mode)
    end
end

Client.ClearTextureLoadRules()
Client.AddTextureLoadRule("ui/*.*", -100)   -- Don't reduce resolution on UI textures
Client.AddTextureLoadRule("fonts/*.*", -100) -- Don't reduce resolution of font textures

Event.Hook("Console_r_mode",            OnConsoleRenderMode )
Event.Hook("Console_r_shadows",         RenderConsoleHandler("shadows", "graphics/display/shadows") )
Event.Hook("Console_r_atmospherics",    RenderConsoleHandler("atmospherics", "graphics/display/atmospherics") )
Event.Hook("Console_r_bloom",           RenderConsoleHandler("bloom", "graphics/display/bloom_new") )
Event.Hook("Console_r_glass",           RenderConsoleHandler("glass", "graphics/display/glass") )

Event.Hook("Console_r_aa",
    function(arg)
        if arg == nil then
            arg = "off"
        end
        Client.SetOptionString(kAntiAliasingOptionsKey, arg)
        Client.SetRenderSetting("anti_aliasing", arg)
        Render_SyncRenderOptions()
    end)

Event.Hook("Console_r_ao",
    function(arg)
        if arg == nil then
            arg = "true"
        elseif arg == "1" or arg == "on" or arg == "true" then
            arg = "true"
        else
            arg = "false"
        end

        Shared.Message(string.format("Ambient Occlusion %s", arg))
        Client.SetOptionString(kAmbientOcclusionOptionsKey, arg)
        Client.SetRenderSetting("ambient_occlusion", arg)
    end)

Event.Hook("Console_r_gamma",
    function (arg)
        if arg == nil then
            arg = Client.DefaultGammaAdjustment
        end

        local num = Clamp(tonumber(arg), Client.MinRenderGamma, Client.MaxRenderGamma)

        Shared.Message(string.format("Gamma changed to %.1f", num))

        Client.SetOptionFloat("graphics/display/gamma", num)
        Client.SetRenderGammaAdjustment(num)
        Render_SyncRenderOptions()
    end )

Event.Hook("Console_r_pq",
    function(arg)
        if arg == "high" then
            Client.SetRenderSetting("particles", "high")
            Client.SetOptionString("graphics/display/particles", "high")
        else
            Client.SetRenderSetting("particles", "low")
            Client.SetOptionString("graphics/display/particles", "low")
        end
    end )