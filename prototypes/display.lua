data:extend(
{			
	----------------------------------------------------------------------------------
    {
        type = "item",
        name = "smart-display-visible",
		icon = "__SmartDisplay__/graphics/smart-display-icon.png",
        flags = {"goes-to-quickbar"},
		subgroup = "circuit-network",
		order = "b[combinators]-e[smart-display]",
        place_result = "smart-display-visible",
        stack_size = 50
    },
	---------------------------------------------------------------------------------
	{
		type = "recipe",
		name = "smart-display-visible",
		enabled = false,
		ingredients =
		{
			{"copper-cable", 5},
			{"electronic-circuit", 5},
		},
		result = "smart-display-visible"
	},
	----------------------------------------------------------------------------------
	{
		type = "lamp",
		name =  "smart-display-visible",
		icon = "__SmartDisplay__/graphics/smart-display-icon.png",
		flags = {"placeable-neutral", "player-creation", "not-on-map"},
		order = "y",
		minable = {hardness = 0.2, mining_time = 0.5, result = "smart-display-visible"},
		max_health = 55,
		corpse = "small-remnants",
		render_layer = "lower-object",
		collision_box = {{-0.15, -0.15}, {0.15, 0.15}},
		selection_box = {{-0.5, -0.5}, {0.5, 0.5}},
		vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0.65 },
		energy_source =
		{
			type = "electric",
			usage_priority = "secondary-input"
		},
		energy_usage_per_tick = "5KW",
		light = {intensity = 0.0, size = 0, color = colors.white},
		picture_off =
		{
			filename = "__SmartDisplay__/graphics/smart-display.png",
			priority = "high",
			width = 47,
			height = 32,
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			shift = {0.2,0},
		},
		picture_on =
		{
			filename = "__SmartDisplay__/graphics/smart-display.png",
			priority = "high",
			width = 47,
			height = 32,
			frame_count = 1,
			axially_symmetrical = false,
			direction_count = 1,
			shift = {0.2,0},
		},

		circuit_wire_connection_point =
		{
			shadow =
			{
				red = {0.4, 0.4},
				green = {-0.4, 0.4},
			},
			wire =
			{
				red = {0.4, 0.4},
				green = {-0.4, 0.4},
			}
		},

		circuit_wire_max_distance = 7.5
	},
}
)

local invisible = dupli_proto( "lamp", "smart-display-visible", "smart-display" )

if invisible then
	-- invisible.additional_pastable_entities = {"smart-display"}
	invisible.minable.result = "smart-display-visible"
	invisible.picture_off.filename = "__SmartDisplay__/graphics/empty.png"
	invisible.picture_off.width = 0
	invisible.picture_off.height = 0
	invisible.picture_on.filename = "__SmartDisplay__/graphics/empty.png"
	invisible.picture_on.width = 0
	invisible.picture_on.height = 0
end

local mapmark_anim =
{
	filename = "__SmartDisplay__/graphics/empty.png",
	priority = "high",
	width = 0,
	height = 0,
	frame_count = 1,
	shift = {0,0},
}

-- to put a label on the map.
local mapmark = dupli_proto("train-stop","train-stop","smart-display-mapmark")
mapmark.minable.result = "train-stop"
mapmark.collision_box = {{0,0}, {0,0}}
mapmark.selection_box = {{0,0}, {0,0}}
mapmark.drawing_box = {{0,0}, {0,0}}
mapmark.order = "y"
mapmark.selectable_in_game = false
mapmark.tile_width = 1
mapmark.tile_height = 1
mapmark.rail_overlay_animations =
{
	north = mapmark_anim,
	east = mapmark_anim,
	south = mapmark_anim,
	west = mapmark_anim,
}
mapmark.animations =
{
	north = mapmark_anim,
	east = mapmark_anim,
	south = mapmark_anim,
	west = mapmark_anim,
}
mapmark.top_animations =
{
	north = mapmark_anim,
	east = mapmark_anim,
	south = mapmark_anim,
	west = mapmark_anim,
}

-- local mapmark = {
	-- type = "train-stop",
	-- name = "smart-display-mapmark",
	-- icon = "__base__/graphics/icons/train-stop.png",
	-- flags = {"placeable-neutral", "player-creation", "filter-directions"},
	-- order = "y",
	-- selectable_in_game = false,
	-- minable = {mining_time = 1, result = "train-stop"},
	-- max_health = 150,
	-- corpse = "medium-remnants",
	-- collision_box = {{0,0}, {0,0}},
	-- selection_box = {{0,0}, {0,0}},
	-- drawing_box = {{0,0}, {0,0}},
	-- tile_width = 1,
	-- tile_height = 1,
	-- animation_ticks_per_frame = 60,
	-- animations =
	-- {
		-- north = mapmark_anim,
		-- east = mapmark_anim,
		-- south = mapmark_anim,
		-- west = mapmark_anim,
	-- },
	-- vehicle_impact_sound =  { filename = "__base__/sound/car-metal-impact.ogg", volume = 0 },
	-- working_sound =
	-- {
		-- sound = { filename = "__base__/sound/train-stop.ogg", volume = 0 }
	-- },
-- }

-- to disable the fog of war on the map around the display, so that it can refresh even at long distance
local smallradar =   
{
	type = "radar",
	name = "smart-display-radar",
	icon = "__base__/graphics/icons/radar.png",
	flags = {"placeable-player", "player-creation"},
	order = "yz",
	minable = {hardness = 0.2, mining_time = 0.5, result = "radar"},
	selectable_in_game = false,
	max_health = 150,
	corpse = "big-remnants",
	resistances =
	{
		{
			type = "fire",
			percent = 70
		}
	},
	collision_box = {{-0.4, -0.4}, {0.4, 0.4}},
	selection_box = {{-2,-2}, {2,2}},
	energy_per_sector = "1kJ",
	max_distance_of_sector_revealed = 0,
	max_distance_of_nearby_sector_revealed = 0,
	energy_per_nearby_scan = "0.1kJ",
	energy_source =
	{
		type = "electric",
		usage_priority = "secondary-input"
	},
	energy_usage = "0.1kW",
	pictures =
	{
		filename = "__SmartDisplay__/graphics/empty.png",
		width = 0,
		height = 0,
		priority = "low",
		apply_projection = false,
		direction_count = 64,
		line_length = 8,
		shift = {0,0}
	},
	vehicle_impact_sound = nil,
	working_sound = nil,
}
  
data:extend({invisible, mapmark, smallradar})
