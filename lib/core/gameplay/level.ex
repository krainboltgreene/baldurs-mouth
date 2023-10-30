defmodule Core.Gameplay.Level do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "levels" do
    field(:index, :integer, default: 1)
    field(:choices, :map, default: %{})
    belongs_to(:character, Core.Gameplay.Character)
    belongs_to(:class, Core.Gameplay.Class)
    timestamps()
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:index, :choices])
    |> Ecto.Changeset.put_assoc(:character, attributes[:character] || record.character)
    |> Ecto.Changeset.put_assoc(:class, attributes[:class] || record.class)
    |> Ecto.Changeset.validate_required([:class, :character, :index, :choices])
    |> Ecto.Changeset.foreign_key_constraint(:character_id)
    |> Ecto.Changeset.foreign_key_constraint(:class_id)
  end
end
