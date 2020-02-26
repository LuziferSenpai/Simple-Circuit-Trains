local MODNAME = "__Simple_Circuit_Trains__"

data:extend
{
	{
		type = "sprite",
		name = "Senpais-Smart-Stop-Icon",
		filename = MODNAME .. "/smart-stop-icon.png",
		priority = "extra-high-no-scale",
		width = 32,
		height = 32,
		scale = 1
	},
	{
		type = "sprite",
		name = "Senpais-plus",
		filename = MODNAME .. "/plus.png",
		priority = "extra-high-no-scale",
		width = 32,
		height = 32,
		scale = 1
	},
	{
        type = "sprite",
        name = "Senpais-remove",
        filename = MODNAME .. "/remove-icon.png",
        priority = "extra-high-no-scale",
        width = 64,
        height = 64,
        scale = 1
    }
}

local s = data.raw["gui-style"].default

s["circuittitlebarfow"] =
{
    type = "horizontal_flow_style",
    horizontally_stretchable = "on",
    vertical_align = "center"
}

s["circuitclosebutton"] =
{
	type = "button_style",
	parent = "close_button",
	size = 28
}

s["circuitchooselem"] =
{
	type = "button_style",
	parent = "slot_button",
	size = 28
}

s["circuitlistflow"] =
{
	type = "horizontal_flow_style",
	horizontally_stretchable = "on",
	horizontal_spacing = 8
}