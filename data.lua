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
        name = "Senpais-remove",
        filename = MODNAME .. "/remove-icon.png",
        priority = "extra-high-no-scale",
        width = 64,
        height = 64,
        scale = 1
    }
}

local s = data.raw["gui-style"].default

--Frames
s["circuitlistboxframe"] =
{
    type = "frame_style",
    padding = 0,
    width = 225,
    height = 280,
    graphical_set =
    {
        base =
        {
            position = { 85, 0 },
            corner_size = 8,
            draw_type = "outer",
            center = { position = { 42, 8 }, size = 1 }
        },
        shadow = default_inner_shadow
    },
    background_graphical_set =
    {
        position = { 282, 17 },
        corner_size = 8,
        overall_tiling_vertical_size = 20,
        overall_tiling_vertical_spacing = 8,
        overall_tiling_vertical_padding = 4,
        overall_tiling_horizontal_padding = 4
    },
    vertically_stretchable = "on"
}

s["circuitstationframe"] =
{
    type = "frame_style",
    parent = "inside_shallow_frame_with_padding",
    minimal_width = 225,
    minimal_height = 280
}

--Flows
s["circuittitlebarflow"] =
{
    type = "horizontal_flow_style",
    horizontally_stretchable = "on",
    vertical_align = "center"
}

s["circuitflowcenterleft8"] =
{
    type = "horizontal_flow_style",
    horizontally_stretchable = "on",
    horizontal_align = "left",
    vertical_align = "center",
    horizontal_spacing = 8,
    top_margin = 8
}

s["circuitflowcenterleft88"] =
{
    type = "horizontal_flow_style",
    parent = "circuitflowcenterleft8",
    bottom_margin = 8
}

s["circuitflow20"] =
{
    type = "horizontal_flow_style",
    horizontal_spacing = 20
}

--Widgets
s["circuitdragwidget"] =
{
    type = "empty_widget_style",
    parent = "draggable_space_header",
    horizontally_stretchable = "on",
    natural_height = 24,
    minimal_width = 24,
}

s["circuitlistwidget"] =
{
    type = "empty_widget_style",
    horizontally_stretchable = "on",
    minimal_width = 30
}

--Buttons
s["circuitchooseelem28"] =
{
    type = "button_style",
    parent = "slot_button",
    size = 28
}

s["circuittoolbutton"] =
{
    type = "button_style",
    parent = "tool_button",
    size = 28
}

s["circuitchooselem"] =
{
	type = "button_style",
	parent = "slot_button",
	size = 28
}

--Listbox
s["circuitlistbox"] =
{
    type = "list_box_style",
    parent = "list_box",
    scroll_pane_style =
    {
        type = "scroll_pane_style",
        parent = "list_box_scroll_pane",
        graphical_set = {},
        background_graphical_set = {},
        vertically_stretchable = "on"
    },
    item_style =
    {
        type = "button_style",
        parent = "list_box_item"
    }
}

--Lines
s["circuitline"] =
{
    type = "line_style",
    top_margin = 4,
    bottom_margin = 4
}

s["circuitstationline"] =
{
    type = "line_style",
    top_margin = 8
}

--ScrollPanes
s["circuitlistscrollpane"] =
{
    type = "scroll_pane_style",
    maximal_height = 280
}

--Labels
s["circuitstationlabel"] =
{
    type = "label_style",
    maximal_width = 400,
    single_line = false
}

--Textfields
s["circuitstationtextfield"] =
{
    type = "textbox_style",
    minimal_width = 0,
    maximal_width = 400
}