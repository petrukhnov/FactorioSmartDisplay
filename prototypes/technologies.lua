data:extend(
{
  
	---------------------------------------------------------------------------------
	{
		type = "technology",
		name = "smart-display",
		icon = "__SmartDisplay__/graphics/smart-displaying.png",
		icon_size = 128,
		effects =
		{
			{
				type = "unlock-recipe",
				recipe = "smart-display-visible",
			},
		},
		prerequisites = {"circuit-network"},
		unit =
		{
			count = 50,
			ingredients =
			{
				{"science-pack-1", 1},
				{"science-pack-2", 1}
			},
			time = 30
		},
    order = "a-d-e",
	},

  
  
}
)

