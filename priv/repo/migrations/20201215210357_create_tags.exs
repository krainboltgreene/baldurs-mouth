defmodule Core.Repo.Migrations.CreateTags do
  use Ecto.Migration

  def change do
    create table(:tags) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      add(:description, :text, null: false, default: "")
    end

    create unique_index(:tags, [:slug])
  end
end
