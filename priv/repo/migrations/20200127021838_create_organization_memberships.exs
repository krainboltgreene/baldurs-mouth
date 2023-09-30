defmodule Core.Repo.Migrations.CreateOrganizationMemberships do
  use Ecto.Migration

  def change do
    create table(:organization_memberships) do
      add :account_id,
          references(:accounts, on_delete: :nothing, type: :binary_id),
          null: false

      add :organization_id,
          references(:organizations, on_delete: :nothing, type: :binary_id),
          null: false

      timestamps()
    end

    create index(:organization_memberships, [:account_id])
    create index(:organization_memberships, [:organization_id])
  end
end
