defmodule Core.Repo.Migrations.CreateLineageCategories do
  use Ecto.Migration

  def change do
    create(table(:lineage_categories)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
    end

    create(unique_index(:lineage_categories, [:slug]))
  end
end
