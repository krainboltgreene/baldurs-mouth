defmodule Core.Repo.Migrations.CreateSpells do
  use Ecto.Migration

  def change do
    create(table(:spells)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      add(:description, :text, null: false, default: "")
    end
    create(unique_index(:spells, [:slug]))
  end
end
