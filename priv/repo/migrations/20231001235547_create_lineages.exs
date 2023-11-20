defmodule Core.Repo.Migrations.CreateLineages do
  use Ecto.Migration

  def change do
    create(table(:lineages)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      add(:description, :text, null: false)
      add(:lineage_category_id, references(:lineage_categories, on_delete: :delete_all))
    end

    create(unique_index(:lineages, [:slug]))
    create(index(:lineages, [:lineage_category_id]))
  end
end
