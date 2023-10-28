defmodule Core.Repo.Migrations.CreateLevels do
  use Ecto.Migration

  def change do
    create(table(:levels)) do
      add(:index, :integer, null: false)
      add(:class_id, references(:classes, on_delete: :delete_all), null: false)
      add(:character_id, references(:characters, on_delete: :delete_all), null: false)
      add(:data, :jsonb, null: false)
      timestamps()
    end

    create(unique_index(:levels, [:character_id, :class_id, :index]))
    create(index(:levels, [:class_id]))
    create(index(:levels, [:index]))
  end
end
