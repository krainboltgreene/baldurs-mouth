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
  use Scaffolding, [Core.Gameplay.Feature, :features, :feature]
  use Scaffolding.Read.Slug, [Core.Gameplay.Feature, :feature]

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
  @proficiency_bonus_table [
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
  @abilities [
    :strength,
    :dexterity,
    :constitution,
    :intelligence,
    :wisdom,
    :charisma
  ]
  @skills [
    :athletics,
    :acrobatics,
    :sleight_of_hand,
    :stealth,
    :arcana,
    :history,
    :investigation,
    :nature,
    :religion,
    :animal_handling,
    :insight,
    :medicine,
    :perception,
    :survival,
    :deception,
    :intimidation,
    :performance,
    :persuasion
  ]

  @spec abilities() :: list(atom())
  def abilities(), do: @abilities

  @spec skills() :: list(atom())
  def skills(), do: @skills

  @spec sum(list(Core.Gameplay.Level.t())) :: map()
  def sum(levels) when is_list(levels) do
    levels
    |> Enum.map(
      &Map.take(&1, [
        :hitpoints,
        :strength,
        :dexterity,
        :constitution,
        :intelligence,
        :wisdom,
        :charisma,
        :features,
        :weapon_proficiencies,
        :armor_proficiencies,
        :skill_proficiencies,
        :skill_expertises,
        :tool_proficiencies,
        :tool_expertises,
        :cantrips
      ])
    )
    |> Enum.reduce(%{}, fn level, accumulation ->
      Map.merge(accumulation, level, fn
        _key, left, right when is_integer(left) and is_integer(right) ->
          left + right

        _key, left, right when is_list(left) and is_list(right) ->
          Enum.concat(left, right)
      end)
    end)
  end

  # character = Core.Gameplay.get_character_by_slug!("james")
  # selected_class = Core.Gameplay.get_class_by_slug!("paladin")
  # Core.Gameplay.level_up(character, selected_class, 2, %{})
  @spec level_up(
          Core.Gameplay.Character.t(),
          Core.Gameplay.Class.t() | Core.Gameplay.Lineage.t() | Core.Gameplay.Background.t(),
          integer(),
          Core.Gameplay.Level.new_t()
        ) ::
          {:error, Ecto.Changeset.t()}
          | {:ok, Core.Gameplay.Level.t()}

  def level_up(
        %Core.Gameplay.Character{levels: levels} = character,
        %Core.Gameplay.Class{hit_dice: hit_dice} = class,
        position,
        choices
      )
      when length(levels) > 2 do
    create_level!(
      Map.merge(
        choices,
        %{
          character: character,
          class: class,
          position: position,
          hitpoints: Enum.random(1..hit_dice) + hitpoints_modifier(levels)
        }
      )
    )
  end

  def level_up(
        %Core.Gameplay.Character{levels: levels} = character,
        %Core.Gameplay.Class{hit_dice: hit_dice} = class,
        position,
        choices
      )
      when length(levels) == 2 do
    create_level!(
      Map.merge(
        choices,
        %{
          character: character,
          class: class,
          position: position,
          hitpoints: hit_dice + hitpoints_modifier(levels)
        }
      )
    )
  end

  @spec level_up(
          Core.Gameplay.Character.t(),
          atom(),
          Core.Gameplay.Level.new_t()
        ) ::
          {:error, Ecto.Changeset.t()}
          | {:ok, Core.Gameplay.Level.t()}
  def level_up(
        %Core.Gameplay.Character{levels: levels} = character,
        :background,
        choices
      )
      when length(levels) == 1 do
    create_level!(
      Map.merge(
        choices,
        %{
          character: character,
          position: -1
        }
      )
    )
  end

  def level_up(
        %Core.Gameplay.Character{levels: levels} = character,
        :lineage,
        choices
      )
      when length(levels) == 0 do
    create_level!(
      Map.merge(
        choices,
        %{
          character: character,
          position: -2
        }
      )
    )
  end

  @spec ability_modifier(number()) :: integer()
  def ability_modifier(value) do
    floor((value - 10) / 2.0)
  end

  @spec level(list(Core.Gameplay.Level.t())) :: integer()
  def level(levels) when is_list(levels) do
    levels
    |> last_level_in_classes()
    |> Map.values()
    |> Enum.sum()
  end

  @spec xp(list(Core.Gameplay.Level.t())) :: integer()
  def xp(levels) when is_list(levels) do
    Enum.at(@experience_table, level(levels) - 1)
  end

  @spec proficiency_bonus(list(Core.Gameplay.Level.t())) :: integer()
  def proficiency_bonus(levels) when is_list(levels) do
    Enum.at(@proficiency_bonus_table, level(levels) - 1)
  end

  @spec last_level_in_classes(list(Core.Gameplay.Level.t())) :: %{
          Core.Gameplay.Class.t() => integer()
        }
  def last_level_in_classes(levels) when is_list(levels) do
    levels
    |> Enum.filter(fn %{position: position} -> position > 2 end)
    |> Enum.group_by(&Map.get(&1, :class))
    |> Enum.map(fn {class, sublevels} ->
      {class, Enum.max_by(sublevels, &Map.get(&1, :position))}
    end)
    |> Enum.map(fn {class, %Core.Gameplay.Level{position: position}} -> {class, position} end)
    |> Map.new()
  end

  # TODO: Fill in with more logic like Durable
  @spec hitpoints_modifier(list(Core.Gameplay.Level.t())) :: integer()
  def hitpoints_modifier(levels) when is_list(levels) do
    levels
    |> sum()
    |> Map.get(:constitution)
    |> ability_modifier()
  end
end
