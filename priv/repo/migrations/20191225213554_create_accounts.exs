defmodule Core.Repo.Migrations.CreateAccounts do
  use Ecto.Migration

  def change do
    create table(:accounts) do
      add :email_address, :citext, null: false
      add :confirmed_at, :naive_datetime
      add :username, :citext
      add :onboarding_state, :citext, null: false
      add :hashed_password, :string, null: false
      add :profile, :map, default: %{}, null: false
      add :settings, :map, default: %{}, null: false

      timestamps()
    end

    create(unique_index(:accounts, [:email_address]))
    create(index(:accounts, :onboarding_state))
  end
end
