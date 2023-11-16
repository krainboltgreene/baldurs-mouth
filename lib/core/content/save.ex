defmodule Core.Content.Save do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "saves" do
    field(:playing_state, Ecto.Enum, values: [:playing, :completed], default: :playing)
    field(:inspiration, :integer, default: 0)
    timestamps()
    belongs_to(:last_scene, Core.Theater.Scene, on_replace: :nilify)
    has_one(:campaign, through: [:last_scene, :campaign])
    many_to_many(:characters, Core.Gameplay.Character, join_through: "parties")
  end

  @type t :: %__MODULE__{
          inspiration: integer(),
          playing_state: atom()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload_relationships =
      Core.Repo.preload(record, [
        :last_scene,
        :characters
      ])

    record_with_preload_relationships
    |> Ecto.Changeset.cast(attributes, [:playing_state, :inspiration])
    |> Ecto.Changeset.put_assoc(
      :last_scene,
      attributes[:last_scene] || record_with_preload_relationships.last_scene
    )
    |> Ecto.Changeset.put_assoc(
      :characters,
      attributes[:characters] || record_with_preload_relationships.characters
    )
    |> Ecto.Changeset.validate_length(:characters, max: 3, min: 1, message: "can't have more than %{count} characters in a party")
    |> Ecto.Changeset.validate_required([:playing_state, :last_scene, :characters])
  end
end
