local baseTermite = 
{
	type = "projectile",
	flags = {"not-on-map"},
	acceleration = 0.005,
	action =
	{
		type = "direct",
		action_delivery =
		{
			type = "instant",
			target_effects =
			{
				{
					type = "create-entity",
					trigger_created_entity = "true"
				},
				{
					type = "create-entity",
				}
			}
		}
	},
	light = {intensity = 0.5, size = 4},
	animation =
	{
		frame_count = 1,
		width = 32,
		height = 32,
		priority = "high"
	},
	shadow =
	{
		filename = "__base__/graphics/entity/poison-capsule/poison-capsule-shadow.png",
		frame_count = 1,
		width = 32,
		height = 32,
		priority = "high"
	},
	smoke = capsule_smoke,
}

local ExplosiveTermite = util.table.deepcopy(baseTermite)
ExplosiveTermite.name = "explosive-termites"
ExplosiveTermite.action.action_delivery.target_effects[1].entity_name = "termite-detonation"
ExplosiveTermite.action.action_delivery.target_effects[2].entity_name = "explosion"
ExplosiveTermite.animation.filename = "__Explosive Termites__/graphics/Termite.png"

local AlienExplosiveTermite = util.table.deepcopy(baseTermite)
AlienExplosiveTermite.name = "alien-explosive-termites"
AlienExplosiveTermite.action.action_delivery.target_effects[1].entity_name = "alien-termite-detonation"
AlienExplosiveTermite.action.action_delivery.target_effects[2].entity_name = "medium-explosion"
AlienExplosiveTermite.animation.filename = "__Explosive Termites__/graphics/Alien-Termite.png"

data:extend({ExplosiveTermite, AlienExplosiveTermite})