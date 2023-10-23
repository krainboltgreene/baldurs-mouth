defmodule Core.Repo.Migrations.CreateItems do
  use Ecto.Migration

  def change do
    create(table(:items)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
    end

    create(unique_index(:items, [:slug]))
  end
end
