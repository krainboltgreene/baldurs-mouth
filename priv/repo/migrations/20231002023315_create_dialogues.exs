defmodule Core.Repo.Migrations.CreateDialogues do
  use Ecto.Migration

  def change do
    create(table(:dialogues)) do
      add(:body, :text, null: false, default: "")
      add(:challenge, :jsonb)
      add(:for_scene_id, references(:scenes, on_delete: :delete_all))
      add(:next_scene_id, references(:scenes, on_delete: :delete_all))
      add(:failure_scene_id, references(:scenes, on_delete: :delete_all))
      add(:speaker_character_id, references(:characters, on_delete: :delete_all))
    end

    create(index(:dialogues, [:for_scene_id]))
    create(index(:dialogues, [:next_scene_id]))
    create(index(:dialogues, [:failure_scene_id]))
    create(unique_index(:dialogues, [:speaker_character_id]))
  end
end
