defmodule Core.Gameplay do
  use Scaffolding, [Core.Gameplay.Lineage, :lineages, :lineage]
  use Scaffolding, [Core.Gameplay.Item, :items, :item]
  use Scaffolding, [Core.Gameplay.Inventory, :inventories, :inventory]
  use Scaffolding, [Core.Gameplay.Class, :classes, :class]
  use Scaffolding, [Core.Gameplay.Character, :characters, :character]
  use Scaffolding, [Core.Gameplay.Background, :backgrounds, :background]
  # character = Core.Gameplay.get_character!("James")
  # selected_class = Core.Gameplay.get_class!("paladin")
  # Core.Gameplay.level_up(character, selected_class, 2)
  def level_up(
        %Core.Gameplay.Character{} = character,
        %Core.Gameplay.Class{slug: "fighter"} = class,
        1 = index
      ) do
    create_level(character, class, index, %{
      hp: 10,
      fighting_style: "archery",
      actions: [
        "second-wind"
      ],
      armor_proficiencies: ["light armour", "medium armour", "heavy armour", "shield"],
      weapons: ["simple weapons", "martial weapon"],
      saving_throw_proficiencies: ["strength", "constitution"],
      skill_proficiencies: [
        nil,
        nil,
        "acrobatics",
        "animal handling",
        "athletics",
        "history",
        "insight",
        "intimidation",
        "perception",
        "survival"
      ]
    })
  end

  def level_up(
        %Core.Gameplay.Character{} = character,
        class,
        index
      ) do
    create_level(character, class, index, %{
      hp: class.hp / 2 + 1
    })
  end

  defp create_level(character, class, index, data) do
    %Core.Gameplay.Level{}
    |> Core.Gameplay.Level.changeset(%{
      character: character,
      class: class,
      index: index,
      data: data
    })
    |> Core.Repo.insert()
  end
end
