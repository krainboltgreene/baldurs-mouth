defmodule Core.Repo.Migrations.CreateAccountTokens do
  use Ecto.Migration

  def change do
    create table(:accounts_tokens) do
      add :account_id, references(:accounts, on_delete: :delete_all), null: false
      add :token, :binary, null: false
      add :context, :string, null: false
      add :sent_to, :string
      timestamps(updated_at: false)
    end

    create index(:accounts_tokens, [:account_id])
    create unique_index(:accounts_tokens, [:context, :token])
  end
end
