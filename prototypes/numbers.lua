local decos = {}
local collision_box = {{-0.2, -0.2}, {0.2, 0.2}}
local collision_mask = {}

function add_font_with_scale( font_scale )
	font_scale_tag = tostring( font_scale * 10 )
	--local i = 0
	
	for asc = 32, 126 do
		table.insert( decos,
			{
				type = "simple-entity",
				--type = "optimized-decorative",
				name = prefix_font .. font_scale_tag .. "_" .. asc,
				flags = {"placeable-off-grid", "not-on-map"},
				selectable_in_game = false,
				collision_box = collision_box,
				collision_mask = collision_mask,
				render_layer = "lower-object",
				pictures =
				{
					filename = "__SmartDisplayRedux__/graphics/font-arial.png",
					priority = "low",
					tint = font_tint,
					x = (asc%10) * font_width,
					y = math.floor((asc-30)/10) * font_height,
					scale = font_scale,
					width = font_width,
					height = font_height,
					shift = {font_scale*font_width/2/32, -font_scale*under_height/2/32-y_shift_priority}, -- hand in the left corner
				}
			}
		)
		--i = i + 1
	end

	table.insert( decos,
		{
			type = "simple-entity",
			--type = "optimized-decorative",
			name = prefix_under_g .. font_scale_tag,
			flags = {"placeable-off-grid", "not-on-map"},
			selectable_in_game = false,
			collision_box = collision_box,
			collision_mask = collision_mask,
			render_layer = "lower-object",
			pictures =
			{
				filename = "__SmartDisplayRedux__/graphics/gunder.png",
				priority = "low",
				x = font_width - under_width,
				y = 0,
				scale = font_scale,
				width = under_width,
				height = under_height,
				shift = {font_scale*under_width/2/32, -font_scale*under_height/2/32}, -- hand in the left corner
			}
		}
	)

	table.insert( decos,
		{
			type = "simple-entity",
			--type = "optimized-decorative",
			name = prefix_under_c .. font_scale_tag,
			flags = {"placeable-off-grid", "not-on-map"},
			selectable_in_game = false,
			collision_box = collision_box,
			collision_mask = collision_mask,
			render_layer = "lower-object",
			pictures =
			{
				filename = "__SmartDisplayRedux__/graphics/gunder.png",
				priority = "low",
				x = font_width,
				y = 0,
				scale = font_scale,
				width = font_width,
				height = under_height,
				shift = {font_scale*font_width/2/32, -font_scale*under_height/2/32}, -- hand in the left corner
			}
		}
	)

	table.insert( decos,
		{
			type = "simple-entity",
			--type = "optimized-decorative",
			name = prefix_under_d .. font_scale_tag,
			flags = {"placeable-off-grid", "not-on-map"},
			selectable_in_game = false,
			collision_box = collision_box,
			collision_mask = collision_mask,
			render_layer = "lower-object",
			pictures =
			{
				filename = "__SmartDisplayRedux__/graphics/gunder.png",
				priority = "low",
				x = font_width*2,
				y = 0,
				scale = font_scale,
				width = under_width,
				height = under_height,
				shift = {font_scale*under_width/2/32, -font_scale*under_height/2/32}, -- hand in the left corner
			}
		}
	)
end

for _, scale in pairs( font_scales ) do
	add_font_with_scale( scale )
end

data:extend(decos)


