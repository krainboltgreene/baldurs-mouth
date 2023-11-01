defmodule Core.Repo.Migrations.CreateListeners do
  use Ecto.Migration

  def change do
    create(table(:listeners, primary_key: false)) do
      add(:npc_id, references(:npcs, on_delete: :delete_all), null: false)
      add(:scene_id, references(:scenes, on_delete: :delete_all), null: false)
    end

    create(unique_index(:listeners, [:npc_id, :scene_id]))
    create(index(:listeners, [:scene_id]))
  end
end
