defmodule Core.Repo.Migrations.CreateLevels do
  use Ecto.Migration

  def change do
    create(table(:levels)) do
      add(:position, :integer, null: false)
      add(:hitpoints, :integer, null: false, default: 1)
      add(:features, {:array, :citext}, null: false, default: [])
      add(:weapon_proficiencies, {:array, :citext}, null: false, default: [])
      add(:armor_proficiencies, {:array, :citext}, null: false, default: [])
      add(:skill_proficiencies, {:array, :citext}, null: false, default: [])
      add(:skill_expertises, {:array, :citext}, null: false, default: [])
      add(:tool_proficiencies, {:array, :citext}, null: false, default: [])
      add(:tool_expertises, {:array, :citext}, null: false, default: [])
      add(:cantrips, {:array, :citext}, null: false, default: [])
      add(:languages, {:array, :citext}, null: false, default: [])
      add(:class_id, references(:classes, on_delete: :delete_all), null: false)
      add(:character_id, references(:characters, on_delete: :delete_all), null: false)
    end

    create(unique_index(:levels, [:character_id, :class_id, :position]))
    create(index(:levels, [:class_id]))
    create(index(:levels, [:position]))
  end
end
