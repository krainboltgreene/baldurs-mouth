defmodule Core.Repo.Migrations.CreateParticipants do
  use Ecto.Migration

  def change do
    create(table(:participants, primary_key: false)) do
      add(:character_id, references(:characters, on_delete: :delete_all), null: false)
      add(:save_id, references(:saves, on_delete: :delete_all), null: false)
    end

    create(unique_index(:participants, [:character_id, :save_id]))
    create(index(:participants, [:save_id]))
  end
end
