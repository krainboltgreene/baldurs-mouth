defmodule Core.Gameplay.Lineage do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lineages" do
    field(:name, :string)
    field(:slug, :string)
    belongs_to(:lineage_category, Core.Gameplay.LineageCategory)
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:name])
    |> Ecto.Changeset.put_assoc(
      :lineage_category,
      attributes[:lineage_category] ||
        Core.Repo.preload(record, :lineage_category).lineage_category
    )
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug])
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
