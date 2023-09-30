defmodule Core.Repo.Migrations.CreatePreferences do
  use Ecto.Migration

  def change do
    create table(:preferences) do
      add :religion_id, references(:religions, on_delete: :delete_all), null: false
      add :culture_id, references(:cultures, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:preferences, [:religion_id, :culture_id])
    create index(:preferences, [:culture_id])
  end
end
