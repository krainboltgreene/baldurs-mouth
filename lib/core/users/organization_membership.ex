defmodule Core.Users.OrganizationMembership do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "organization_memberships" do
    belongs_to(:organization, Core.Users.Organization)
    belongs_to(:account, Core.Users.Account)
    has_many(:organization_permissions, Core.Users.OrganizationPermission)
    has_many(:permissions, through: [:organization_permissions, :permission])

    timestamps()
  end

  @type t :: %__MODULE__{}

  @spec changeset(struct, map) ::
          Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [])
    |> Ecto.Changeset.validate_required([])
    |> Ecto.Changeset.put_assoc(:account, attributes.account)
    |> Ecto.Changeset.put_assoc(:organization, attributes.organization)
    |> Ecto.Changeset.foreign_key_constraint(:account_id)
    |> Ecto.Changeset.foreign_key_constraint(:organization_id)
    |> Ecto.Changeset.assoc_constraint(:account)
    |> Ecto.Changeset.assoc_constraint(:organization)
  end
end
