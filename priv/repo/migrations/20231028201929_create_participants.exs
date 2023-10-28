defmodule Core.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create(table(:participants)) do
      add(:character_id, references(:characters, on_delete: :delete_all), null: false)
      add(:scene_id, references(:scenes, on_delete: :delete_all), null: false)
    end

    create(unique_index(:participants, [:character_id, :scene_id]))
    create(index(:participants, [:scene_id]))
  end
end
