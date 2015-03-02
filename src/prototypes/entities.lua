data:extend(
{
	{
		type = "tree",
		name = "termite-detonation",
		icon = "__Explosive Termites__/graphics/null.png",
		flags = {"placeable-neutral", "not-on-map", "placeable-off-grid"},
		subgroup = "remnants",
		order = "a[remnants]",
		max_health = 1,
		selection_box = {{-0.5, 0.5}, {0.5, .05}},
		collision_box = {{-0.49, -0.49}, {0.49, 0.49}},
		collision_mask = {"object-layer"},
		pictures = 
		{
			{
				filename = "__Explosive Termites__/graphics/null.png",
				width = 32,
				height = 32,
			}
		}
	}
}
)