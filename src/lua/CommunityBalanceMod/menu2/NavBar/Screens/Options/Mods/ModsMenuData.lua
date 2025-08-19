local menu =
{
	categoryName = "CBM",
	entryConfig =
	{
		name = "ispEntry",
		class = GUIMenuCategoryDisplayBoxEntry,
		params =
		{
			label = "CBM: ACCESSIBILITY OPTIONS",
		},
	},
	contentsConfig = ModsMenuUtils.CreateBasicModsMenuContents
	{
		layoutName = "CBM_Options",
		contents =
		{
			{
				name = "CBM_info",
				class = GUIMenuText,
				params = {
					text = "Client-side settings to adjust accessibility of CBM"
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
			{
				name = "dualfiringlock",
				class = OP_TT_Checkbox,
				params =
				{
					optionPath = "ExoA_duallock_enabled",
					optionType = "bool",
					default = false,
					tooltip = "When both arms are of the same type, enable to cause firing of the left arm to fire the right arm (updates upon entering an exosuit)",
				},
			
				properties =
				{
					{"Label", "Dual Arm Firing Sync"},
				},
			},
		}
	}
}
table.insert(gModsCategories, menu)