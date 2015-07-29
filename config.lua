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
        google = { projectNumber = "611761906259", },
        iphone =
        {
            types =
            {
                "badge", "sound", "alert"
            }
        }
    }
}
