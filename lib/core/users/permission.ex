defmodule Core.Users.Permission do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "permissions" do
    field(:name, :string)
    field(:slug, :string)
    has_many(:organization_permissions, Core.Users.OrganizationPermission)

    timestamps()
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t()
        }

  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  @doc false
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:name])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug])
    |> Ecto.Changeset.unique_constraint(:name)
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
