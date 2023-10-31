defmodule Core.Gameplay.Level do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "levels" do
    field(:position, :integer, default: 1)
    embeds_one(:choices, Choices) do
      field(:hitpoints, :integer, default: 0)
      field(:features, {:array, :string}, default: [])
      field(:skill_proficiencies, {:array, :string}, default: [])
      field(:tool_proficiencies, {:array, :string}, default: [])
      field(:weapon_proficiencies, {:array, :string}, default: [])
      field(:armor_proficiencies, {:array, :string}, default: [])
      field(:languages, {:array, :string}, default: [])
    end
    belongs_to(:character, Core.Gameplay.Character)
    belongs_to(:class, Core.Gameplay.Class)
    timestamps()
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:position])
    |> Ecto.Changeset.put_assoc(:character, attributes[:character] || record.character)
    |> Ecto.Changeset.put_assoc(:class, attributes[:class] || record.class)
    |> Ecto.Changeset.cast_embed(:choices, required: true, with: &choice_changeset/2)
    |> Ecto.Changeset.validate_required([:class, :character, :position, :choices])
    |> Ecto.Changeset.foreign_key_constraint(:character_id)
    |> Ecto.Changeset.foreign_key_constraint(:class_id)
  end

  @spec choice_changeset(struct(), map()) :: Ecto.Changeset.t(t())
  def choice_changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:hitpoints, :features, :skill_proficiencies, :tool_proficiencies, :weapon_proficiencies, :armor_proficiencies, :languages])
  end
end
