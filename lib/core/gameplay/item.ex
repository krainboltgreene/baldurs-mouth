defmodule Core.Gameplay.Item do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "items" do
    field(:name, :string)
    field(:slug, :string)
    field(:description, :string, default: "")
    field(:weight, :integer, default: 0)
    many_to_many(:tags, Core.Content.Tag, join_through: "item_tags")
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload = Core.Repo.preload(record, [
      :tags
    ])

    record_with_preload
    |> Ecto.Changeset.cast(attributes, [:name, :description, :weight])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.put_assoc(:tags, Enum.concat(record_with_preload.tags, attributes[:tags]))
    |> Ecto.Changeset.validate_required([:name, :slug, :weight])
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
