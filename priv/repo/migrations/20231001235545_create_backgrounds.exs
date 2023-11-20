defmodule Core.Repo.Migrations.CreateBackgrounds do
  use Ecto.Migration

  def change do
    create(table(:backgrounds)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      add(:description, :text, null: false)
    end

    create(unique_index(:backgrounds, [:slug]))
  end
end
