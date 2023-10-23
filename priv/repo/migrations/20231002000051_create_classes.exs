defmodule Core.Repo.Migrations.CreateClasses do
  use Ecto.Migration

  def change do
    create(table(:classes)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
    end

    create(unique_index(:classes, [:slug]))
  end
end
