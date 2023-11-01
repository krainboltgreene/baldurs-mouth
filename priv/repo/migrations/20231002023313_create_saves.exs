defmodule Core.Repo.Migrations.CreateSaves do
  use Ecto.Migration

  def change do
    create(table(:saves)) do
      add(:campaign_id, references(:campaigns, on_delete: :delete_all), null: false)
      add(:scene_id, references(:scenes, on_delete: :delete_all), null: false)
      timestamps()
    end

    create(index(:saves, [:campaign_id]))
    create(index(:saves, [:scene_id]))
  end
end
