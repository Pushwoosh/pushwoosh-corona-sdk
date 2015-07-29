-- config.lua

application =
{
	content =
	{
		width = 512,
		height = 480,
		scale = "letterbox" -- zoom to fill screen, possibly cropping edges
	},

	notification =
	{
		google = { projectNumber = "YOUR_GOOGLE_PROJECT_NUMBER_HERE", },
		iphone =
		{
			types =
			{
				"badge", "sound", "alert"
			}
		}
	}
}
