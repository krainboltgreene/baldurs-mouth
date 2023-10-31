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

{:ok, _} =
  Core.Repo.transaction(fn ->
    {:ok, _} =
      Core.Gameplay.create_background(%{
        name: "Folk Hero",
        forced_skills: [
          "Animal Handling",
          "Survival"
        ],
        optional_skills: [],
        skill_choices: 0,
        forced_tools: [],
        tool_choices: 1,
        tool_categories: ["gaming", "musical"]
      })

    {:ok, elf_lineage_category} =
      Core.Gameplay.create_lineage_category(%{
        name: "Elf"
      })

    {:ok, _} =
      Core.Gameplay.create_lineage(%{
        name: "Half-Orc",
        features: [
          "darkvision",
          "relentless_endurance",
          "savage_attacks",
          "menacing"
        ]
      })

    {:ok, _} =
      Core.Gameplay.create_class(%{
        name: "Fighter",
        hit_dice: "10",
        saving_throw_proficiencies: [
          "strength",
          "constitution"
        ],
        levels: [
          %{
            weapon_proficiencies: ["simple weapons", "martial weapon"],
            armor_proficiencies: ["light armour", "medium armour", "heavy armour", "shield"],
            features: [
              "fighting_style",
              "second_wind"
            ],
            optional_skills: [
              "acrobatics",
              "animal_handling",
              "athletics",
              "history",
              "insight",
              "intimidation",
              "perception",
              "survival"
            ],
            skill_choices: 2
          },
          %{
            features: ["action_surge"]
          }
        ]
      })

    {:ok, _} =
      Core.Gameplay.create_item(%{
        name: "Greatsword"
      })
  end)
