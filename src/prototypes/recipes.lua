data:extend(
{
  {
    type = "recipe",
    name = "explosive-termites",
    enabled = true,
    ingredients =
    {
      {type = "item", name = "wood", amount = 10},
      {type = "item", name = "coal", amount = 20}
    },
    results =
    {
      {type = "item", name = "explosive-termites", amount = 1}
    }
  },
  {
    type = "recipe",
    name = "alien-explosive-termites",
    enabled = true,
    ingredients =
    {
      {type = "item", name = "wood", amount = 50},
      {type = "item",name = "coal", amount = 50},
      {type = "item", name = "explosive-termites", amount = 5}
    },
    results =
    {
      {type = "item", name = "alien-explosive-termites", amount = 1}
    }
  }
}
)