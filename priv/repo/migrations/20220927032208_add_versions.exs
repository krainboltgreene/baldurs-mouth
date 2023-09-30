defmodule Repo.Migrations.AddVersions do
  use Ecto.Migration

  def change do
    create table(:versions, primary_key: false) do
      add :id, :bigserial, primary_key: true
      add :event, :citext, null: false
      add :item_type, :text, null: false
      add :item_id, :uuid, null: false
      add :item_changes, :map, null: false
      # you can change :users to your own foreign key constraint
      add :originator_id, references(:accounts)
      add :origin, :text
      add :meta, :map

      # Configure timestamps type in config.ex :paper_trail :timestamps_type
      add :inserted_at, :utc_datetime, null: false
    end

    create index(:versions, [:originator_id])
    create index(:versions, [:item_id, :item_type])
    # Uncomment if you want to add the following indexes to speed up special queries:
    create index(:versions, [:event, :item_type])
    create index(:versions, [:item_type, :inserted_at])
  end
end
