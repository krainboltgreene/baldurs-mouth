defmodule Core.Repo.Migrations.CreateCampaigns do
  use Ecto.Migration

  def change do
    create(table(:campaigns)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      timestamps()
    end

    create(unique_index(:campaigns, [:slug]))
  end
end
