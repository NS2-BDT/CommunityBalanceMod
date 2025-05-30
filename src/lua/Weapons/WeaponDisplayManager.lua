-- ======= Copyright (c) 2003-2011, Unknown Worlds Entertainment, Inc. All rights reserved. ========
--
-- lua\Weapons\WeaponDisplayManager.lua
--
--    Created by:   Trevor Harris (trevor@naturalselection2.com)
--
--    Manages all of the GUIView objects used to render the in-world weapon GUI displays.  We avoid
--    creating them unnecessarily, and instead just reuse the same display classes for each weapon
--    class.
--
-- ========= For more information, visit us at http://www.unknownworlds.com ========================

class "WeaponDisplayManager"

local manager
function GetWeaponDisplayManager()
    
    if not manager then
        manager = WeaponDisplayManager()
        manager:Initialize()
    end
    
    return manager

end

local function CreateWeaponDisplay(settings, weaponName)
    
    local newDisplay = Client.CreateGUIView(settings.xSize, settings.ySize)
    newDisplay:Load(settings.script)
    newDisplay:SetTargetTexture(string.format("*ammo_display%s", weaponName))
    newDisplay:SetRenderCondition(GUIView.RenderNever) -- don't render yet, wait until we're equipped.
    
    return newDisplay
    
end

local function PreloadWeaponScripts(self)
    
    -- The Weapon:GetUIDisplaySettings() method will often call self:Get____Variant()... since we
    -- have no self, we don't know (or care) what the variant is... but we need the other data in
    -- the settings table... so just ignore the calls to the variant getters.
    local preloadSelfSpoofer = {}
    setmetatable(preloadSelfSpoofer,
    {
        __index = function() return function() end end,
    })
    
    local weaponClasses = self:GetWeaponClassesToPreload()
    for i=1, #weaponClasses do
        
        local weaponClass = weaponClasses[i]
        
        local settings = weaponClass.GetUIDisplaySettings(preloadSelfSpoofer)
        assert(type(settings.xSize) == "number")
        assert(type(settings.ySize) == "number")
        assert(type(settings.script) == "string")
        
        local weaponMapName = weaponClass.kMapName
        assert(type(weaponMapName) == "string")
        
        self:GetWeaponDisplayScript(settings, weaponMapName)
        
    end
    
end

function WeaponDisplayManager:Initialize()

    -- Mapping of scriptPath --> GUIView.
    self.weaponDisplays = {}
    
    PreloadWeaponScripts(self)
    
    self.initialized = true

end

function WeaponDisplayManager:GetWeaponDisplayScript(settings, weaponName)
    
    local scriptPath = settings.script
    local weaponDisplay = self.weaponDisplays[scriptPath]
    if weaponDisplay then
        return weaponDisplay
    end
    
    weaponDisplay = CreateWeaponDisplay(settings, weaponName)
    self.weaponDisplays[scriptPath] = weaponDisplay
    
    if self.initialized then
        Log("WARNING!  Weapon display script '%s' wasn't preloaded!  You may have noticed a small hitch... (See lua/Weapons/WeaponDisplayManager.lua for more info).", scriptPath)
    end
    
    return weaponDisplay
    
end

-- Mods that add extra weapons can extend this method to add extra weapon classes to the table.
function WeaponDisplayManager:GetWeaponClassesToPreload()

    local classList = {}
    
    assert(Flamethrower)        table.insert(classList, Flamethrower)
    assert(GrenadeLauncher)     table.insert(classList, GrenadeLauncher)
    assert(HeavyMachineGun)     table.insert(classList, HeavyMachineGun)
    assert(LayMines)            table.insert(classList, LayMines)
    assert(Pistol)              table.insert(classList, Pistol)
    assert(Rifle)               table.insert(classList, Rifle)
    assert(Shotgun)             table.insert(classList, Shotgun)
    assert(Welder)              table.insert(classList, Welder)
	assert(Submachinegun)       table.insert(classList, Submachinegun)
    
    return classList

end
