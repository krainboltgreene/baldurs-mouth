defmodule Core.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add :name, :text, null: false
      add :slug, :citext, null: false

      timestamps()
    end

    create unique_index(:tags, [:name])
    create unique_index(:tags, [:slug])
  end
end
