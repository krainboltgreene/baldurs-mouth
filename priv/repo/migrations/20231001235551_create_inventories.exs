defmodule Core.Repo.Migrations.CreateInventories do
  use Ecto.Migration

  def change do
    create(table(:inventories)) do
      add(:character_id, references(:characters, on_delete: :delete_all), null: false)
      add(:item_id, references(:items, on_delete: :delete_all), null: false)
    end

    create(index(:inventories, [:character_id, :item_id]))
    create(index(:inventories, [:item_id]))
  end
end
