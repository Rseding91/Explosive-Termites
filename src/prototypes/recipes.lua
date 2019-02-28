data:extend(
{
  {
    type = "recipe",
    name = "explosive-termites",
    enabled = "true",
    ingredients =
    {
      {"wood", 10},
      {"coal", 20}
    },
    result = "explosive-termites"
  },
  {
    type = "recipe",
    name = "alien-explosive-termites",
    enabled = "true",
    ingredients =
    {
      {"wood", 50},
      {"coal", 50},
      {"explosive-termites", 5}
    },
    result = "alien-explosive-termites"
  }
}
)