defmodule Core.Gameplay.Level do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "levels" do
    field(:position, :integer)
    field(:hitpoints, :integer, default: 1)
    field(:strength, :integer, default: 0)
    field(:dexterity, :integer, default: 0)
    field(:constitution, :integer, default: 0)
    field(:intelligence, :integer, default: 0)
    field(:wisdom, :integer, default: 0)
    field(:charisma, :integer, default: 0)
    field(:features, {:array, :string}, default: [])
    field(:weapon_proficiencies, {:array, :string}, default: [])
    field(:armor_proficiencies, {:array, :string}, default: [])
    field(:skill_proficiencies, {:array, :string}, default: [])
    field(:skill_expertises, {:array, :string}, default: [])
    field(:tool_proficiencies, {:array, :string}, default: [])
    field(:tool_expertises, {:array, :string}, default: [])
    field(:cantrips, {:array, :string}, default: [])
    field(:languages, {:array, :string}, default: [])
    belongs_to(:character, Core.Gameplay.Character)
    belongs_to(:class, Core.Gameplay.Class)
  end

  @type t :: %__MODULE__{
          position: integer(),
          hitpoints: integer(),
          strength: integer(),
          dexterity: integer(),
          constitution: integer(),
          intelligence: integer(),
          wisdom: integer(),
          charisma: integer(),
          features: list(String.t()),
          weapon_proficiencies: list(String.t()),
          armor_proficiencies: list(String.t()),
          skill_proficiencies: list(String.t()),
          skill_expertises: list(String.t()),
          tool_proficiencies: list(String.t()),
          tool_expertises: list(String.t()),
          cantrips: list(String.t())
        }

  @type options_t :: %{
          optional(:hitpoints) => integer(),
          optional(:strength) => integer(),
          optional(:dexterity) => integer(),
          optional(:constitution) => integer(),
          optional(:intelligence) => integer(),
          optional(:wisdom) => integer(),
          optional(:charisma) => integer(),
          optional(:features) => list(String.t()),
          optional(:weapon_proficiencies) => list(String.t()),
          optional(:armor_proficiencies) => list(String.t()),
          optional(:skill_proficiencies) => list(String.t()),
          optional(:skill_expertises) => list(String.t()),
          optional(:tool_proficiencies) => list(String.t()),
          optional(:tool_expertises) => list(String.t()),
          optional(:cantrips) => list(String.t())
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preloaded_relationships =
      Core.Repo.preload(record, [
        :character,
        :class
      ])

    record_with_preloaded_relationships
    |> Ecto.Changeset.cast(attributes, [
      :position,
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
    |> Ecto.Changeset.put_assoc(
      :character,
      attributes[:character] || record_with_preloaded_relationships.character
    )
    |> Ecto.Changeset.put_assoc(
      :class,
      attributes[:class] || record_with_preloaded_relationships.class
    )
    |> Ecto.Changeset.validate_required([:character, :position, :hitpoints])
    |> Ecto.Changeset.foreign_key_constraint(:character_id)
    |> Ecto.Changeset.foreign_key_constraint(:class_id)
  end
end
