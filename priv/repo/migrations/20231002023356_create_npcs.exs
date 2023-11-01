defmodule Core.Repo.Migrations.CreateNPCs do
  use Ecto.Migration

  def change do
    create(table(:npcs)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      add(:known, :boolean, null: false, default: false)
    end

    create(unique_index(:npcs, [:slug]))
  end
end
