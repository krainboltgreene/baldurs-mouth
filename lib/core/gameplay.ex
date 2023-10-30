defmodule Core.Gameplay do
  use Scaffolding, [Core.Gameplay.Background, :backgrounds, :background]
  use Scaffolding, [Core.Gameplay.Character, :characters, :character]
  use Scaffolding, [Core.Gameplay.Class, :classes, :class]
  use Scaffolding, [Core.Gameplay.Inventory, :inventories, :inventory]
  use Scaffolding, [Core.Gameplay.Item, :items, :item]
  use Scaffolding, [Core.Gameplay.Lineage, :lineages, :lineage]
  use Scaffolding.Read.Slug, [Core.Gameplay.Background, :background]
  use Scaffolding.Read.Slug, [Core.Gameplay.Class, :class]
  use Scaffolding.Read.Slug, [Core.Gameplay.Item, :item]
  use Scaffolding.Read.Slug, [Core.Gameplay.Lineage, :lineage]
  use Scaffolding.Write, [Core.Gameplay.Level, :level, :changeset, :changeset]

  # character = Core.Gameplay.get_character!("James")
  # selected_class = Core.Gameplay.get_class!("paladin")
  # Core.Gameplay.level_up(character, selected_class, 2)
  @spec level_up(Core.Gameplay.Character.t(), Core.Gameplay.Class.t(), map(), any()) ::
          {:error, Ecto.Changeset.t()} | {:ok, Core.Gameplay.Level.t()}
  def level_up(
        %Core.Gameplay.Character{} = character,
        %Core.Gameplay.Class{slug: "fighter", hit_dice: hit_dice} = class,
        choices,
        1 = index
      ) do
    create_level(%{
      character: character,
      class: class,
      index: index,
      choices:
        Map.merge(choices, %{
          hitpoints: character.hitpoints + attribute_modifier(character.constitution) + hit_dice
        })
    })
  end

  def level_up(
        %Core.Gameplay.Character{} = character,
        %Core.Gameplay.Class{slug: "fighter", hit_dice: hit_dice} = class,
        choices,
        index
      ) do
    create_level(%{
      character: character,
      class: class,
      index: index,
      choices:
        Map.merge(choices, %{
          hitpoints:
            character.hitpoints + attribute_modifier(character.constitution) +
              Enum.random(1..hit_dice)
        })
    })
  end

  @spec attribute_modifier(number()) :: integer()
  def attribute_modifier(value) do
    floor((value - 10) / 2.0)
  end
end
