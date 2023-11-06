defmodule Core.Repo.Migrations.CreateSaves do
  use Ecto.Migration

  def change do
    create(table(:saves)) do
      add(:playing_state, :citext, null: false)
      add(:inspiration, :integer, null: false, default: 0)
      add(:last_scene_id, references(:scenes, on_delete: :delete_all), null: false)
      timestamps()
    end

    create(index(:saves, [:last_scene_id]))
    create(index(:saves, [:playing_state]))
  end
end
