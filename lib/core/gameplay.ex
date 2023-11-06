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

  @spec preview(
          Core.Gameplay.Character.t(),
          Core.Gameplay.Class.t(),
          integer()
        ) :: Core.Gameplay.Level.options_t()
  def preview(character, %Core.Gameplay.Class{slug: "fighter"}, position) do
    Core.Gameplay.Fighter.preview(character, position)
  end

  def preview(character, %Core.Gameplay.Class{slug: "paladin"}, position) do
    Core.Gameplay.Paladin.preview(character, position)
  end

  def preview(character, %Core.Gameplay.Class{slug: "bard"}, position) do
    Core.Gameplay.Bard.preview(character, position)
  end

  def preview(character, %Core.Gameplay.Class{slug: "wizard"}, position) do
    Core.Gameplay.Wizard.preview(character, position)
  end


  @spec preview(
          Core.Gameplay.Character.t(),
          atom()
        ) :: Core.Gameplay.Level.options_t()
  def preview(
        %Core.Gameplay.Character{lineage: %Core.Gameplay.Lineage{lineage_category: %Core.Gameplay.LineageCategory{slug: "elf"}}} = character,
        :lineage
      ) do
    Core.Gameplay.Elf.preview(character)
  end

  def preview(
        %Core.Gameplay.Character{lineage: %Core.Gameplay.Lineage{slug: "half-orc"}} = character,
        :lineage
      ) do
    Core.Gameplay.HalfOrc.preview(character)
  end

  def preview(
        %Core.Gameplay.Character{lineage: %Core.Gameplay.Lineage{lineage_category: %Core.Gameplay.LineageCategory{slug: "tiefling"}}} = character,
        :lineage
      ) do
    Core.Gameplay.Tiefling.preview(character)
  end

  def preview(
        %Core.Gameplay.Character{background: %Core.Gameplay.Background{slug: "folk-hero"}},
        :background
      ) do
    %{}
  end

  def preview(
        %Core.Gameplay.Character{background: %Core.Gameplay.Background{slug: "failed-merchant"}},
        :background
      ) do
    %{}
  end

  def preview(
        %Core.Gameplay.Character{background: %Core.Gameplay.Background{slug: "acolyte"}},
        :background
      ) do
    %{}
  end

  # character = Core.Gameplay.get_character_by_slug!("james")
  # selected_class = Core.Gameplay.get_class_by_slug!("paladin")
  # Core.Gameplay.level_up(character, selected_class, 2, %{})
  @spec level_up(
          Core.Gameplay.Character.t(),
          Core.Gameplay.Class.t(),
          Core.Gameplay.Choices.new_t()
        ) ::
          {:error, Ecto.Changeset.t()}
          | {:ok, Core.Gameplay.Level.t()}
  def level_up(
        %Core.Gameplay.Character{levels: []} = character,
        %Core.Gameplay.Class{hit_dice: hit_dice} = class,
        position,
        choices
      ) do
    create_level(
      Map.merge(
        choices,
        %{
          character: character,
          class: class,
          position: position,
          hitpoints: ability_modifier(character.constitution) + hit_dice
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
      when length(levels) > 0 do
    create_level(
      Map.merge(
        choices,
        %{
          character: character,
          class: class,
          position: position,
          hitpoints: ability_modifier(character.constitution) + Enum.random(1..hit_dice)
        }
      )
    )
  end

  @spec level_up(
          Core.Gameplay.Character.t(),
          atom(),
          Core.Gameplay.Choices.new_t()
        ) ::
          {:error, Ecto.Changeset.t()}
          | {:ok, Core.Gameplay.Character.t()}
  def level_up(
        %Core.Gameplay.Character{levels: levels} = character,
        :lineage,
        choices
      )
      when length(levels) == 0 do
    update_character(character, %{
      lineage_choices: choices
    })
  end

  def level_up(
        %Core.Gameplay.Character{levels: levels} = character,
        :background,
        choices
      )
      when length(levels) == 0 do
    update_character(character, %{
      background_choices: choices
    })
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
    |> Enum.group_by(&Map.get(&1, :class))
    |> Enum.map(fn {class, sublevels} ->
      {class, Enum.max_by(sublevels, &Map.get(&1, :position))}
    end)
    |> Enum.map(fn {class, %Core.Gameplay.Level{position: position}} -> {class, position} end)
    |> Map.new()
  end
end
