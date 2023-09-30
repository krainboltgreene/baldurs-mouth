defmodule Core.Repo.Migrations.CreateOrganizationPermissions do
  use Ecto.Migration

  def change do
    create table(:permissions) do
      add :name, :text, null: false
      add :slug, :citext, null: false

      timestamps()
    end

    create unique_index(:permissions, [:slug])
  end
end
