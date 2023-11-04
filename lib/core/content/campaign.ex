defmodule Core.Content.Campaign do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "campaigns" do
    field(:name, :string)
    field(:slug, :string)
    timestamps()
    has_one(:opening_scene, Core.Theater.Scene, where: [opening: true])
    has_many(:scenes, Core.Theater.Scene)
    has_many(:saves, through: [:scenes, :saves])
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload_relationships = Core.Repo.preload(record, [])

    record_with_preload_relationships
    |> Ecto.Changeset.cast(attributes, [:name])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug])
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
