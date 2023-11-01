defmodule Core.Repo.Migrations.CreateLevels do
  use Ecto.Migration

  def change do
    create(table(:levels)) do
      add(:position, :integer, null: false)
      add(:class_id, references(:classes, on_delete: :delete_all), null: false)
      add(:character_id, references(:characters, on_delete: :delete_all), null: false)
      add(:choices, :jsonb, null: false)
    end

    create(unique_index(:levels, [:character_id, :class_id, :position]))
    create(index(:levels, [:class_id]))
    create(index(:levels, [:position]))
  end
end
