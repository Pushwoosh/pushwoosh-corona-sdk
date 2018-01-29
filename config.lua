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
		iphone =
		{
			types =
			{
				"badge", "sound", "alert"
			}
		}
	}
}
