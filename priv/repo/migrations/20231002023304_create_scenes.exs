defmodule Core.Repo.Migrations.CreateScenes do
  use Ecto.Migration

  def change do
    create(table(:scenes)) do
      add(:name, :text, null: false)
      add(:slug, :citext, null: false)
      add(:opening, :boolean, null: false, default: false)
      add(:campaign_id, references(:campaigns, on_delete: :delete_all), null: false)
    end

    create(unique_index(:scenes, [:slug]))
    create(unique_index(:scenes, [:opening, :campaign_id]))
    create(index(:scenes, [:campaign_id], where: "opening is TRUE"))
  end
end
