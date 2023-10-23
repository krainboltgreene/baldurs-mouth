defmodule Core.Repo.Migrations.CreateInteractions do
  use Ecto.Migration

  def change do
    create(table(:dialogues)) do
      add(:speaker_id, references(:characters, on_delete: :delete_all), null: false)
      add(:lines, :text, null: false)
      add(:narration, :text, null: false)
      add(:skill, :citext)
      add(:difficulty, :integer)
    end
  end
end
