local kStatusIconEnabled = GetAdvancedOption("statusicon")

function StatusIconDisplay_SetStatusIconEnabled(enabled)
    kStatusIconEnabled = enabled

    if enabled then 
        setStatusShow()
    else 
        setStatusOld()
    end
end


local oldGUIPlayerStatusInitialize = GUIPlayerStatus.Initialize
function GUIPlayerStatus:Initialize()
    oldGUIPlayerStatusInitialize(self)

    
    function setStatusShow()
        for _, overwrite in ipairs(self.statusIcons) do
            overwrite.Settings.ShowWithHintsOnly = false
            overwrite.Settings.ShowWithLowHUDDetails = true
        end
    end

    if kStatusIconEnabled then 
        setStatusShow()
    end

    function setStatusOld()

        for __, overwrite in ipairs(self.statusIcons) do
            if overwrite.Settings.Name == "Parasite" 
              or overwrite.Settings.Name == "Detected"  then 
                 overwrite.Settings.ShowWithLowHUDDetails = true
            end

            if overwrite.Settings.Name == "CragRange" 
              or overwrite.Settings.Name == "Energize"  then 
                 overwrite.Settings.ShowWithHintsOnly = true
            end
        end
    end
end

