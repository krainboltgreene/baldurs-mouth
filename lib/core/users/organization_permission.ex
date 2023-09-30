defmodule Core.Users.OrganizationPermission do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organization_permissions" do
    belongs_to(:organization_membership, Core.Users.OrganizationMembership)

    belongs_to(:permission, Core.Users.Permission)
    has_one(:account, through: [:organization_membership, :account])
    has_one(:organization, through: [:organization_membership, :organization])

    timestamps()
  end

  @type t :: %__MODULE__{
          organization_membership:
            Core.Users.OrganizationMembership.t() | Ecto.Association.NotLoaded.t(),
          permission: Core.Users.Permission.t() | Ecto.Association.NotLoaded.t()
        }

  @spec changeset(struct, map) ::
          Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [])
    |> Ecto.Changeset.validate_required([])
    |> Ecto.Changeset.put_assoc(:organization_membership, attributes.organization_membership)
    |> Ecto.Changeset.put_assoc(:permission, attributes.permission)
    |> Ecto.Changeset.foreign_key_constraint(:organization_membership_id)
    |> Ecto.Changeset.foreign_key_constraint(:permission_id)
    |> Ecto.Changeset.assoc_constraint(:organization_membership)
    |> Ecto.Changeset.assoc_constraint(:permission)
  end
end
