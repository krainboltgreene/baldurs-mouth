defmodule Core.Repo.Migrations.AddOauthToAccounts do
  use Ecto.Migration

  def change do
    alter(table(:accounts)) do
      add :provider, :text
      add :provider_access_token, :text
      add :provider_refresh_token, :text
      add :provider_token_expiration, :integer
      add :provider_id, :text
      add :avatar_uri, :text
      add :provider_scopes, {:array, :text}, default: []
    end
  end
end
