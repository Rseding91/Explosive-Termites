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
	},
	{
		type = "tree",
		name = "alien-termite-detonation",
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
	},
	{
    type = "smoke-with-trigger",
    name = "alien-termite-cloud",
    flags = {"not-on-map", "placeable-off-grid"},
    show_when_smoke_off = true,
    animation =
    {
		filename = "__base__/graphics/entity/cloud/cloud-45-frames.png",
		priority = "low",
		width = 256,
		height = 256,
		frame_count = 45,
		animation_speed = 3,
		line_length = 7,
		scale = 3,
    },
    slow_down_factor = 0,
    affected_by_wind = false,
    cyclic = true,
    duration = 60 * 14,
    fade_away_duration = 120,
    spread_duration = 0,
    color = { r = 0.58, g = 0.08, b = 0.64 },
    action_frequency = 30
	}
}
)