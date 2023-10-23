defmodule Core.Repo.Migrations.CreateCharacters do
  use Ecto.Migration

  def change do
    create(table(:characters)) do
      add(:name, :text, null: false)
      add(:pronouns, :jsonb, null: false)
      add(:account_id, references(:accounts, on_delete: :delete_all), null: false)
      add(:species_id, references(:species, on_delete: :delete_all), null: false)
      add(:background_id, references(:backgrounds, on_delete: :delete_all), null: false)
    end

    create(index(:characters, [:account_id]))
    create(index(:characters, [:species_id]))
    create(index(:characters, [:background_id]))
  end
end
