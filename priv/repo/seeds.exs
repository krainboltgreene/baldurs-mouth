# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Core.Repo.insert!(%Core.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.


{:ok, svet} = Core.Gameplay.create_character(%{
  name: "Svet the Happy",
  lineage: Core.Gameplay.get_lineage_by_slug("half-orc"),
  background: Core.Gameplay.get_background_by_slug("folk-hero"),
  lineage_choices: %{},
  background_choices: %{
    tool_proficiences: [
      "dice",
      "flute"
    ]
  }
})

Core.Gameplay.level_up(%{
  character: svet,
  class: Core.Gameplay.get_class_by_slug("fighter"),
  choices: %{
    fighting_style: "great-weapon-fighting",
    skill_proficiencies: [
      "athletics",
      "survival"
    ]
  }
})

Core.Gameplay.level_up(%{
  character: svet,
  class: Core.Gameplay.get_class_by_slug("fighter"),
  choices: %{
    skill_proficiencies: [
      "athletics",
      "survival"
    ]
  }
})
