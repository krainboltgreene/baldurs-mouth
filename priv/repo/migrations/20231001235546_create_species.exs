defmodule Core.Repo.Migrations.CreateSpecies do
  use Ecto.Migration

  def change do
    create(table(:species)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
    end

    create(unique_index(:species, [:slug]))
  end
end
