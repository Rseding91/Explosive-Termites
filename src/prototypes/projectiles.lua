data:extend(
{
	{
    type = "projectile",
    name = "explosive-termites",
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
            entity_name = "termite-detonation"
          },
          {
            type = "nested-result",
            action =
            {
              type = "area",
              perimeter = 0.9,
              action_delivery =
              {
                type = "instant",
                target_effects =
                {
                  {
                    type = "damage",
                    damage = {amount = 1, type = "explosion"}
                  },
                  {
                    type = "create-entity",
                    entity_name = "explosion"
                  }
                }
              }
            },
          }
        }
      }
    },
    light = {intensity = 0.5, size = 4},
    animation =
    {
      filename = "__Explosive Termites__/graphics/Termite.png",
      frame_count = 1,
      frame_width = 32,
      frame_height = 32,
      priority = "high"
    },
    shadow =
    {
      filename = "__base__/graphics/entity/poison-capsule/poison-capsule-shadow.png",
      frame_count = 1,
      frame_width = 32,
      frame_height = 32,
      priority = "high"
    },
    smoke = capsule_smoke,
  }
}
)