defmodule Core.Repo.Migrations.CreateOrganizationAccountPermissions do
  use Ecto.Migration

  def change do
    create table(:organization_permissions) do
      add :permission_id,
          references(:permissions, on_delete: :nothing, type: :binary_id),
          null: false

      add :organization_membership_id,
          references(:organization_memberships, on_delete: :nothing, type: :binary_id),
          null: false

      timestamps()
    end

    create unique_index(:organization_permissions, [:permission_id, :organization_membership_id])
    create index(:organization_permissions, [:organization_membership_id])
  end
end
