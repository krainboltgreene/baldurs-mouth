defmodule Core.Content.Save do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "saves" do
    belongs_to(:campaign, Core.Content.Campaign)
    belongs_to(:scene, Core.Theater.Scene)
    belongs_to(:account, Core.Users.Account)

    timestamps()
  end

  @type t :: %__MODULE__{
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preload_relationships = Core.Repo.preload(record, [:campaign, :scene, :account])

    record_with_preload_relationships
    |> Ecto.Changeset.cast(attributes, [:name])
    |> Ecto.Changeset.put_assoc(:scene, attributes[:scene] || record_with_preload_relationships.scene)
    |> Ecto.Changeset.put_assoc(:campaign, attributes[:campaign] || record_with_preload_relationships.campaign)
    |> Ecto.Changeset.put_assoc(:account, attributes[:account] || record_with_preload_relationships.account)
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug, :scene, :campaign])
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
