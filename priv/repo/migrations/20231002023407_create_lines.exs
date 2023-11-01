defmodule Core.Repo.Migrations.CreateLines do
  use Ecto.Migration

  def change do
    create(table(:lines)) do
      add(:body, :text, null: false, default: "")
      add(:challenge, :jsonb)
      add(:scene_id, references(:scenes, on_delete: :delete_all))
      add(:speaker_npc_id, references(:npcs, on_delete: :delete_all), null: false)
    end

    create(index(:lines, [:scene_id]))
    create(index(:lines, [:speaker_npc_id]))
  end
end
