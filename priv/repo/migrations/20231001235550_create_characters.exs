defmodule Core.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create(table(:characters)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      add(:strength, :integer, null: false, default: 8)
      add(:dexterity, :integer, null: false, default: 8)
      add(:constitution, :integer, null: false, default: 8)
      add(:intelligence, :integer, null: false, default: 8)
      add(:wisdom, :integer, null: false, default: 8)
      add(:charisma, :integer, null: false, default: 8)
      add(:lineage_choices, :jsonb, null: false, default: "{}")
      add(:background_choices, :jsonb, null: false, default: "{}")
      add(:pronouns, :jsonb, null: false)
      add(:account_id, references(:accounts, on_delete: :delete_all), null: false)
      add(:lineage_id, references(:lineages, on_delete: :delete_all), null: false)
      add(:background_id, references(:backgrounds, on_delete: :delete_all), null: false)
    end

    create(unique_index(:characters, [:slug]))
    create(index(:characters, [:account_id]))
    create(index(:characters, [:lineage_id]))
    create(index(:characters, [:background_id]))
  end
end
