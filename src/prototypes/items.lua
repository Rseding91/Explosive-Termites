data:extend(
{
  {
    type = "capsule",
    name = "explosive-termites",
    icon = "__Explosive Termites__/graphics/Termite.png",
    icon_size = 32,
    capsule_action =
    {
      type = "throw",
      attack_parameters =
      {
        type = "projectile",
        ammo_category = "capsule",
        cooldown = 30,
        projectile_creation_distance = 0.6,
        range = 45,
        ammo_type =
        {
          target_type = "position",
          action =
          {
            type = "direct",
            action_delivery =
            {
              type = "projectile",
              projectile = "explosive-termites",
              starting_speed = 0.3
            }
          }
        }
      }
    },
    subgroup = "capsule",
    order = "a[explosive-termites]-b[normal]",
    stack_size = 64
  },
  {
    type = "capsule",
    name = "alien-explosive-termites",
    icon = "__Explosive Termites__/graphics/Alien-Termite.png",
    icon_size = 32,
    capsule_action =
    {
      type = "throw",
      attack_parameters =
      {
        type = "projectile",
        ammo_category = "capsule",
        cooldown = 30,
        projectile_creation_distance = 0.6,
        range = 90,
        ammo_type =
        {
          target_type = "position",
          action =
          {
            type = "direct",
            action_delivery =
            {
              type = "projectile",
              projectile = "alien-explosive-termites",
              starting_speed = 0.6
            }
          }
        }
      }
    },
    subgroup = "capsule",
    order = "a[explosive-termites]-b[alien]",
    stack_size = 64
  }
}
)