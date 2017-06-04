local default_gui = data.raw["gui-style"].default

data:extend(
	{
		{
			type = "font",
			name = "smadisp_font",
			from = "default",
			border = false,
			size = 15
		},
		{
			type = "font",
			name = "smadisp_font_small",
			from = "default-bold",
			border = false,
			size = 12
		},
		{
			type = "font",
			name = "smadisp_font_bold",
			from = "default-bold",
			border = false,
			size = 15
		},
	}
)

local spacing_right = 5
local spacing_vertical = 3

default_gui.smadisp_frame_style = 
{
	type="frame_style",
	top_padding = spacing_vertical,
	bottom_padding = spacing_vertical,
	left_padding = spacing_vertical,
	right_padding = spacing_vertical,
	resize_row_to_width = true,
	max_on_row = 1,
	flow_style=
	{
		horizontal_spacing = spacing_right,
		vertical_spacing = spacing_vertical,
		resize_row_to_width = true,
		resize_to_row_height = false
	}
}

default_gui.smadisp_flow_style = 
{
	type = "flow_style",
	
	top_padding = spacing_vertical,
	bottom_padding = spacing_vertical,
	left_padding = 0,
	right_padding = spacing_right,
	
	horizontal_spacing = spacing_right,
	vertical_spacing = spacing_vertical,
	--max_on_row = 1,
	--resize_row_to_width = true,
	max_on_row = 0,
	resize_row_to_width = false,
	resize_to_row_height = false,
	
	graphical_set = { type = "none" },
}

default_gui.smadisp_progressbar_style = 
{
	type="progressbar_style",
	parent="progressbar_style",
	font="smadisp_font_bold",
	top_padding = 0,
	bottom_padding = 0,
	left_padding = spacing_right,
	right_padding = spacing_right,
}

default_gui.smadisp_checkbox_style = 
{
	type="checkbox_style",
	parent="checkbox_style",
	font="smadisp_font_bold",
	top_padding = 0,
	bottom_padding = 0,
	left_padding = spacing_right,
	right_padding = spacing_right,
}

default_gui.smadisp_button_style = 
{
	type="button_style",
	font="smadisp_font_bold",
	align = "center",
	default_font_color={r=1, g=1, b=1},
	hovered_font_color={r=1, g=1, b=1},
	top_padding = 0,
	bottom_padding = 0,
	left_padding = spacing_right,
	right_padding = spacing_right,
	left_click_sound =
	{
		{
		  filename = "__core__/sound/gui-click.ogg",
		  volume = 1
		}
	},
}

default_gui.smadisp_button_color_style = 
{
	type="button_style",
	font="smadisp_font_bold",
	align = "center",
	default_font_color={r=1, g=1, b=1},
	hovered_font_color={r=1, g=1, b=1},
	top_padding = 0,
	bottom_padding = 0,
	left_padding = spacing_right,
	right_padding = spacing_right,
	left_click_sound =
	{
		{
		  filename = "__core__/sound/gui-click.ogg",
		  volume = 1
		}
	},
}

default_gui.smadisp_label_style =
{
	type="label_style",
	font="smadisp_font_bold",
	align = "left",
	default_font_color={r=1, g=1, b=1},
	hovered_font_color={r=1, g=1, b=1},
	top_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	right_padding = spacing_right,
	minimal_width = 100,
	maximal_width = 100,
}

default_gui.smadisp_textfield_style =
{
    type = "textfield_style",
	font="smadisp_font_bold",
	align = "left",
    font_color = {},
	default_font_color={r=1, g=1, b=1},
	hovered_font_color={r=1, g=1, b=1},
    selection_background_color= {r=0.66, g=0.7, b=0.83},
	top_padding = 0,
	bottom_padding = 0,
	left_padding = 0,
	right_padding = spacing_right,
	minimal_width = 200,
	maximal_width = 200,
	graphical_set =
	{
		type = "composition",
		filename = "__core__/graphics/gui.png",
		priority = "extra-high-no-scale",
		corner_size = {3, 3},
		position = {16, 0}
	},
}    
  
