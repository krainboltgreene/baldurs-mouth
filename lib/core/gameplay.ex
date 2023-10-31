defmodule Core.Gameplay do
  use Scaffolding, [Core.Gameplay.Background, :backgrounds, :background]
  use Scaffolding, [Core.Gameplay.Character, :characters, :character]
  use Scaffolding, [Core.Gameplay.Class, :classes, :class]
  use Scaffolding, [Core.Gameplay.Inventory, :inventories, :inventory]
  use Scaffolding, [Core.Gameplay.Item, :items, :item]
  use Scaffolding, [Core.Gameplay.Lineage, :lineages, :lineage]
  use Scaffolding, [Core.Gameplay.LineageCategory, :lineage_categories, :lineage_category]
  use Scaffolding.Read.Slug, [Core.Gameplay.Background, :background]
  use Scaffolding.Read.Slug, [Core.Gameplay.Class, :class]
  use Scaffolding.Read.Slug, [Core.Gameplay.Item, :item]
  use Scaffolding.Read.Slug, [Core.Gameplay.Lineage, :lineage]
  use Scaffolding.Read.Slug, [Core.Gameplay.LineageCategory, :lineage_category]
  use Scaffolding.Write, [Core.Gameplay.Level, :level, :changeset, :changeset]

  # Level, Proficiency Bonus
  @experience_table [
    0,
    300,
    900,
    2_700,
    6_500,
    14_000,
    23_000,
    34_000,
    48_000,
    64_000,
    85_000,
    100_000
  ]
  @proficiency_table [
    2,
    2,
    2,
    2,
    3,
    3,
    3,
    3,
    4,
    4,
    4,
    4
  ]

  # character = Core.Gameplay.get_character!("James")
  # selected_class = Core.Gameplay.get_class!("paladin")
  # Core.Gameplay.level_up(character, selected_class, 2)
  @spec level_up(Core.Gameplay.Character.t(), Core.Gameplay.Class.t(), map(), any()) ::
          {:error, Ecto.Changeset.t()} | {:ok, Core.Gameplay.Level.t()}
  def level_up(
        %Core.Gameplay.Character{} = character,
        %Core.Gameplay.Class{hit_dice: hit_dice} = class,
        choices,
        1 = position
      ) do
    create_level(%{
      character: character,
      class: class,
      position: position,
      choices:
        Map.merge(choices, %{
          hitpoints: ability_modifier(character.constitution) + hit_dice,
          saving_throw_proficiencies: class.saving_throw_proficiencies,
          features: class.levels |> Enum.at(position - 1) |> Map.get(:features),
          weapon_proficiencies:
            class.levels |> Enum.at(position - 1) |> Map.get(:weapon_proficiencies),
          armor_proficiencies:
            class.levels |> Enum.at(position - 1) |> Map.get(:armor_proficiencies),
          skill_proficiencies:
            class.levels |> Enum.at(position - 1) |> Map.get(:skill_proficiencies),
          tool_proficiencies:
            class.levels |> Enum.at(position - 1) |> Map.get(:tool_proficiencies)
        })
    })
  end

  def level_up(
        %Core.Gameplay.Character{} = character,
        %Core.Gameplay.Class{hit_dice: hit_dice} = class,
        choices,
        position
      ) do
    create_level(%{
      character: character,
      class: class,
      position: position,
      choices:
        Map.merge(choices, %{
          hitpoints:
            ability_modifier(character.constitution) +
              Enum.random(1..hit_dice),
          features: class.levels |> Enum.at(position - 1) |> Map.get(:features),
          weapon_proficiencies:
            class.levels |> Enum.at(position - 1) |> Map.get(:weapon_proficiencies),
          armor_proficiencies:
            class.levels |> Enum.at(position - 1) |> Map.get(:armor_proficiencies),
          skill_proficiencies:
            class.levels |> Enum.at(position - 1) |> Map.get(:skill_proficiencies),
          tool_proficiencies:
            class.levels |> Enum.at(position - 1) |> Map.get(:tool_proficiencies)
        })
    })
  end

  @spec ability_modifier(number()) :: integer()
  def ability_modifier(value) do
    floor((value - 10) / 2.0)
  end

  @spec level(list(Core.Gameplay.Level.t())) :: integer()
  def level(levels) when is_list(levels) do
    levels
    |> class_levels()
    |> Map.values()
    |> Enum.sum()
  end

  @spec xp(list(Core.Gameplay.Level.t())) :: integer()
  def xp(levels) when is_list(levels) do
    Enum.at(@experience_table, level(levels) - 1)
  end

  @spec proficiency(list(Core.Gameplay.Level.t())) :: integer()
  def proficiency(levels) when is_list(levels) do
    Enum.at(@proficiency_table, level(levels) - 1)
  end

  @spec class_levels(list(Core.Gameplay.Level.t())) :: %{Core.Gameplay.Class.t() => integer()}
  def class_levels(levels) when is_list(levels) do
    levels
    |> Enum.group_by(&Map.get(&1, :class))
    |> Enum.map(fn {class, sublevels} ->
      {class, Enum.max_by(sublevels, &Map.get(&1, :position))}
    end)
    |> Enum.map(fn {class, %Core.Gameplay.Level{position: position}} -> {class, position} end)
    |> Map.new()
  end
end
