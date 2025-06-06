local menu =
{
    categoryName = "IMPROVED STR. PLACEMENT",
    entryConfig =
    {
        name = "ispEntry",
        class = GUIMenuCategoryDisplayBoxEntry,
        params =
        {
            label = "IMPROVED STR. PLACEMENT",
        },
    },
    contentsConfig = ModsMenuUtils.CreateBasicModsMenuContents
    {
        layoutName = "ISP_Options",
        contents =
        {

			{
				name = "IPS_info",
				class = GUIMenuText,
				params = {
                    text = "Various Client-Side enhancements to help commander placing structure blueprints"
				},
			},
            {
                name = "alienstructures",
                class = OP_TT_Checkbox,
                params =
                {
                    optionPath = "isp_alien_enabled",
                    optionType = "bool",
                    default = true,
                    tooltip = "Disable for slightly better performance when placing structures",
                },
            
                properties =
                {
                    {"Label", "Search valid positions for Alien Structures"},
                },
            },
            {
                name = "marinestructures",
                class = OP_TT_Checkbox,
                params =
                {
                    optionPath = "isp_marine_enabled_2",
                    optionType = "bool",
                    default = true,
                    tooltip = "Disable for slightly better performance when placing structures",
                },
            
                properties =
                {
                    {"Label", "Search valid positions for Marine Structures"},
                },
            },
            {
                name = "marinerotations",
                class = OP_TT_Checkbox,
                params =
                {
                    optionPath = "isp_orientation_enabled",
                    optionType = "bool",
                    default = true,
                    tooltip = "Snap to the closed valid rotation up to 29 Degrees",
                },
            
                properties =
                {
                    {"Label", "Improved Rotation Placement"},
                },
            },
            {
                name = "shiftkey",
                class = OP_TT_Checkbox,
                params =
                {
                    optionPath = "isp_shift_enabled",
                    optionType = "bool",
                    default = true,
                    tooltip = "Also allows you to check the exit of the robo-factory while moving",
                },
            
                properties =
                {
                    {"Label", "Shift-Key for rotating Blueprints"},
                },
            }, 
        }
    }
}
table.insert(gModsCategories, menu)
