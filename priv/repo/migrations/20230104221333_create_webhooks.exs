defmodule Core.Repo.Migrations.CreateWebhooks do
  use Ecto.Migration

  def change do
    create(table(:webhooks)) do
      add :provider, :citext, null: false
      add :headers, :map, null: false
      add :payload, :map, null: false
    end

    create(index(:webhooks, [:provider]))
  end
end
