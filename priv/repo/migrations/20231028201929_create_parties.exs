defmodule Core.Repo.Migrations.CreateParties do
  use Ecto.Migration

  def change do
    create(table(:parties, primary_key: false)) do
      add(:character_id, references(:characters, on_delete: :delete_all), null: false)
      add(:save_id, references(:saves, on_delete: :delete_all), null: false)
    end

    create(unique_index(:parties, [:character_id, :save_id]))
    create(index(:parties, [:save_id]))
  end
end
