defmodule Core.Repo.Migrations.CreateDialogues do
  use Ecto.Migration

  def change do
    create(table(:dialogues)) do
      add(:speaker_id, references(:characters, on_delete: :delete_all))
      add(:body, :text, null: false)
    end

    create(unique_index(:dialogues, [:speaker_id]))
  end
end
