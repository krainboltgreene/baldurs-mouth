defmodule Core.Repo.Migrations.CreateFeature do
  use Ecto.Migration

  def change do
    create(table(:features)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      add(:description, :text, null: false, default: "")
    end

    create(unique_index(:features, [:slug]))
  end
end
