defmodule Core.Repo.Migrations.CreateLineages do
  use Ecto.Migration

  def change do
    create(table(:lineages)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
    end

    create(unique_index(:lineages, [:slug]))
  end
end
