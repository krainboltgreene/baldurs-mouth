defmodule Core.Gameplay.Level do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "levels" do
    field(:position, :integer, default: 1)
    embeds_one(:choices, Core.Gameplay.Choices)
    belongs_to(:character, Core.Gameplay.Character)
    belongs_to(:class, Core.Gameplay.Class)
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preloaded_relationships =
      Core.Repo.preload(record, [
        :character,
        :class
      ])

    record_with_preloaded_relationships
    |> Ecto.Changeset.cast(attributes, [:position])
    |> Ecto.Changeset.put_assoc(
      :character,
      attributes[:character] || record_with_preloaded_relationships.character
    )
    |> Ecto.Changeset.put_assoc(
      :class,
      attributes[:class] || record_with_preloaded_relationships.class
    )
    |> Ecto.Changeset.cast_embed(:choices, required: true)
    |> Ecto.Changeset.validate_required([:class, :character, :position, :choices])
    |> Ecto.Changeset.foreign_key_constraint(:character_id)
    |> Ecto.Changeset.foreign_key_constraint(:class_id)
  end
end
