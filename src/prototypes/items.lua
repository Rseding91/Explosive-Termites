data:extend(
{
	{
    type = "capsule",
    name = "explosive-termites",
    icon = "__Explosive Termites__/graphics/Termite.png",
    flags = {"goes-to-quickbar"},
    capsule_action =
    {
      type = "throw",
      attack_parameters =
      {
        ammo_category = "capsule",
        cooldown = 30,
        projectile_creation_distance = 0.6,
        range = 45,
        ammo_type =
        {
          category = "capsule",
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
    order = "a[explosive-termites]",
    stack_size = 64}
}
)