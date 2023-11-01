defmodule Core.Gameplay.Inventory do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "inventories" do
    belongs_to(:character, Core.Gameplay.Character)
    belongs_to(:item, Core.Gameplay.Item)
    timestamps()
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preloaded_relationships =
      Core.Repo.preload(record, [
        :character,
        :item
      ])

    record_with_preloaded_relationships
    |> Ecto.Changeset.cast(attributes, [])
    |> Ecto.Changeset.put_assoc(
      :character,
      attributes[:character] || record_with_preloaded_relationships.character
    )
    |> Ecto.Changeset.put_assoc(
      :item,
      attributes[:item] || record_with_preloaded_relationships.item
    )
  end
end
