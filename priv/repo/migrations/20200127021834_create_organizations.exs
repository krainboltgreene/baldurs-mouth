defmodule Core.Repo.Migrations.CreateOrganizations do
  use Ecto.Migration

  def change do
    create table(:organizations) do
      add :name, :text, null: false
      add :slug, :citext, null: false

      timestamps()
    end

    create unique_index(:organizations, [:slug])
  end
end
