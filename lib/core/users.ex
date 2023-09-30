defmodule Core.Users do
  @moduledoc """
  A set of behavior concerning users, access, and permissions
  """

  import Ecto.Query, warn: false
  require Logger

  use Scaffolding.Read, [Core.Users.Account, :accounts, :account]
  use Scaffolding, [Core.Users.Organization, :organizations, :organization]
  use Scaffolding, [Core.Users.Permission, :permissions, :permission]

  def can_read?(_record, %Core.Users.Account{} = _current_account) do
    false
  end

  @doc """
  Gets a account by email_address.
  """
  def get_account_by_email_address(email_address) when is_binary(email_address) do
    Core.Repo.get_by(Core.Users.Account, email_address: email_address)
  end

  @doc """
  Gets a account by email and password.
  """
  def get_account_by_email_address_and_password(email_address, password)
      when is_binary(email_address) and is_binary(password) do
    account = Core.Repo.get_by(Core.Users.Account, email_address: email_address)

    if Core.Users.Account.valid_password?(account, password) do
      account
    else
      Logger.debug("Failed to validate password")
      nil
    end
  end

  @doc """
  Find or create an account based on OAuth data.
  """
  @spec find_or_create_account_from_oauth(Ueberauth.Auth.t()) ::
          {:ok, Core.Users.Account.t()} | {:error, Ecto.Changeset.t()}
  def find_or_create_account_from_oauth(%Ueberauth.Auth{} = data) do
    get_account_by_email_address(data.info.email)
    |> case do
      nil ->
        register_account(%{
          name: data.info.name,
          username: data.info.nickname,
          password: Utilities.String.random(),
          email_address: data.info.email,
          provider: "twitch",
          provider_id: data.uid,
          provider_access_token: data.credentials.token,
          provider_refresh_token: data.credentials.refresh_token,
          provider_token_expiration: data.credentials.expires_at,
          provider_scopes: data.credentials.scopes,
          avatar_uri: data.info.image
        })

      account ->
        {:ok, account}
    end
    |> case do
      {:error, changeset} ->
        Logger.error(changeset.errors)

      {:ok, account} ->
        update_account_oauth(
          account,
          %{
            name: data.info.name,
            username: data.info.nickname,
            provider_id: data.uid,
            provider_access_token: data.credentials.token,
            provider_refresh_token: data.credentials.refresh_token,
            provider_token_expiration: data.credentials.expires_at,
            provider_scopes: data.credentials.scopes,
            avatar_uri: data.info.image
          }
        )
    end
  end

  @doc """
  Registers a account.
  """
  @spec register_account(map()) :: {:ok, Core.Users.Account.t()} | {:error, Ecto.Changeset.t()}
  def register_account(attrs) do
    with {:ok, account} <-
           %Core.Users.Account{}
           |> Core.Users.Account.registration_changeset(attrs)
           |> Core.Repo.insert(),
         {:ok, organization} <- create_organization(%{name: "#{account.username}'s Crew"}),
         {:ok, _} <- join_organization(account, organization, "administrator") do
      {:ok, account |> Core.Repo.reload() |> Core.Repo.preload(:organizations)}
    else
      {:error, _} = error -> error
    end
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking account changes.
  """
  def change_account_registration(%Core.Users.Account{} = account, attrs \\ %{}) do
    Core.Users.Account.registration_changeset(account, attrs, hash_password: false)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the account email_address.
  """
  def change_account_email_address(account, attrs \\ %{}) do
    Core.Users.Account.email_address_changeset(account, attrs)
  end

  @doc """
  Emulates that the email_address will change without actually changing
  it in the database.
  """
  def apply_account_email_address(account, password, attrs) do
    account
    |> Core.Users.Account.email_address_changeset(attrs)
    |> Core.Users.Account.validate_current_password(password)
    |> Ecto.Changeset.apply_action(:update)
  end

  @doc """
  Updates the account email_address using the given token.

  If the token matches, the account email_address is updated and the token is deleted.
  The confirmed_at date is also updated to the current time.
  """
  def update_account_email_address(account, token) do
    context = "change:#{account.email_address}"

    with {:ok, query} <-
           Core.Users.AccountToken.verify_change_email_token_query(token, context),
         %Core.Users.AccountToken{sent_to: email_address} <-
           Core.Repo.one(query),
         {:ok, _} <-
           Core.Repo.transaction(account_email_address_multi(account, email_address, context)) do
      :ok
    else
      _ -> :error
    end
  end

  defp account_email_address_multi(account, email_address, context) do
    changeset =
      account
      |> Core.Users.Account.email_address_changeset(%{email_address: email_address})
      |> Core.Users.Account.confirm_changeset()

    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      Core.Users.AccountToken.account_and_contexts_query(account, [context])
    )
  end

  @doc """
  Delivers the update email instructions to the given account.
  """
  def deliver_account_update_email_address_instructions(
        %Core.Users.Account{} = account,
        current_email_address,
        update_email_address_url_fun
      )
      when is_function(update_email_address_url_fun, 1) do
    {encoded_token, account_token} =
      Core.Users.AccountToken.build_email_token(
        account,
        "change:#{current_email_address}"
      )

    Core.Repo.insert!(account_token)

    Core.Users.AccountNotifier.deliver_update_email_address_instructions(
      account,
      update_email_address_url_fun.(encoded_token)
    )
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for changing the account password.
  """
  def change_account_password(account, attrs \\ %{}) do
    Core.Users.Account.password_changeset(account, attrs, hash_password: false)
  end

  @doc """
  Updates the accounts details.
  """
  def update_account_oauth(account, attributes) do
    account
    |> Core.Users.Account.oauth_changeset(attributes)
    |> Core.Repo.update()
  end

  @doc """
  Updates the account password.
  """
  def update_account_password(account, password, attrs) do
    changeset =
      account
      |> Core.Users.Account.password_changeset(attrs)
      |> Core.Users.Account.validate_current_password(password)

    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, changeset)
    |> Ecto.Multi.delete_all(
      :tokens,
      Core.Users.AccountToken.account_and_contexts_query(account, :all)
    )
    |> Core.Repo.transaction()
    |> case do
      {:ok, %{account: account}} -> {:ok, account}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end

  @doc """
  Generates a session token.
  """
  def generate_account_session_token(account) do
    {token, account_token} = Core.Users.AccountToken.build_session_token(account)
    Core.Repo.insert!(account_token)
    token
  end

  @doc """
  Gets the account with the given signed token.
  """
  def get_account_by_session_token(token) do
    {:ok, query} = Core.Users.AccountToken.verify_session_token_query(token)
    Core.Repo.one(query)
  end

  @doc """
  Deletes the signed token with the given context.
  """
  def delete_account_session_token(token) do
    Core.Repo.delete_all(Core.Users.AccountToken.token_and_context_query(token, "session"))

    :ok
  end

  ## Confirmation

  @doc """
  Delivers the confirmation email instructions to the given account.
  """
  def deliver_account_confirmation_instructions(
        %Core.Users.Account{} = account,
        confirmation_url_fun
      )
      when is_function(confirmation_url_fun, 1) do
    if account.confirmed_at do
      {:error, :already_confirmed}
    else
      {encoded_token, account_token} =
        Core.Users.AccountToken.build_email_token(account, "confirm")

      Core.Repo.insert!(account_token)

      Core.Users.AccountNotifier.deliver_confirmation_instructions(
        account,
        confirmation_url_fun.(encoded_token)
      )
    end
  end

  @doc """
  Confirms a account by the given token.

  If the token matches, the account account is marked as confirmed
  and the token is deleted.
  """
  def confirm_account(token) do
    with {:ok, query} <-
           Core.Users.AccountToken.verify_email_token_query(token, "confirm"),
         %Core.Users.Account{} = account <- Core.Repo.one(query),
         {:ok, %{account: account}} <-
           Core.Repo.transaction(confirm_account_multi(account)) do
      {:ok, account}
    else
      _ -> :error
    end
  end

  defp confirm_account_multi(account) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, Core.Users.Account.confirm_changeset(account))
    |> Ecto.Multi.delete_all(
      :tokens,
      Core.Users.AccountToken.account_and_contexts_query(account, ["confirm"])
    )
  end

  ## Reset password

  @doc """
  Delivers the reset password email to the given account.
  """
  def deliver_account_reset_password_instructions(
        %Core.Users.Account{} = account,
        reset_password_url_fun
      )
      when is_function(reset_password_url_fun, 1) do
    {encoded_token, account_token} =
      Core.Users.AccountToken.build_email_token(account, "reset_password")

    Core.Repo.insert!(account_token)

    Core.Users.AccountNotifier.deliver_reset_password_instructions(
      account,
      reset_password_url_fun.(encoded_token)
    )
  end

  @doc """
  Gets the account by reset password token.
  """
  def get_account_by_reset_password_token(token) do
    with {:ok, query} <-
           Core.Users.AccountToken.verify_email_token_query(token, "reset_password"),
         %Core.Users.Account{} = account <- Core.Repo.one(query) do
      account
    else
      _ -> nil
    end
  end

  @doc """
  Resets the account password.
  """
  def reset_account_password(account, attrs) do
    Ecto.Multi.new()
    |> Ecto.Multi.update(:account, Core.Users.Account.password_changeset(account, attrs))
    |> Ecto.Multi.delete_all(
      :tokens,
      Core.Users.AccountToken.account_and_contexts_query(account, :all)
    )
    |> Core.Repo.transaction()
    |> case do
      {:ok, %{account: account}} -> {:ok, account}
      {:error, :account, changeset, _} -> {:error, changeset}
    end
  end

  @spec join_organization(Core.Users.Account.t(), Core.Users.Organization.t(), String.t()) ::
          {:ok, Core.Users.Organization.t()}
          | {:error, :not_found | Ecto.Changeset.t(Core.Users.OrganizationPermission.t())}
  def join_organization(account, organization, permission_slug) do
    with permission when is_struct(permission, Core.Users.Permission) <-
           Core.Repo.get_by(Core.Users.Permission, %{slug: permission_slug}),
         {:ok, organization_membership} <-
           Core.Users.create_organization_membership(%{
             organization: organization,
             account: account
           }),
         {:ok, _} <-
           Core.Users.create_organization_permission(%{
             organization_membership: organization_membership,
             permission: permission
           }) do
      {:ok, organization}
    else
      nil -> {:error, {Core.Users.Permission, :not_found}}
      error -> error
    end
  end

  @spec join_organization_by_slug(Core.Users.Account.t(), String.t()) ::
          {:ok, Core.Users.Organization.t()}
          | {:error, :not_found | Ecto.Changeset.t(Core.Users.OrganizationPermission.t())}
  def join_organization_by_slug(account, organization_slug) do
    join_organization_by_slug(account, organization_slug, "default")
  end

  @spec join_organization_by_slug(Core.Users.Account.t(), String.t(), String.t()) ::
          {:ok, Core.Users.Organization.t()}
          | {:error, :not_found | Ecto.Changeset.t(Core.Users.OrganizationPermission.t())}
  def join_organization_by_slug(account, organization_slug, permission_slug) do
    join_organization(
      account,
      Core.Repo.get_by(Core.Users.Organization, %{slug: organization_slug}),
      permission_slug
    )
  end

  @spec has_permission?(Core.Users.Account.t() | nil, String.t(), String.t()) :: boolean()
  def has_permission?(nil, _, _), do: false

  def has_permission?(account, organization_slug, permission_slug) do
    from(
      organization_permission in Core.Users.OrganizationPermission,
      join: account in assoc(organization_permission, :account),
      join: permission in assoc(organization_permission, :permission),
      join: organization in assoc(organization_permission, :organization),
      where:
        permission.slug == ^permission_slug and
          organization.slug == ^organization_slug and
          account.id == ^account.id
    )
    |> Core.Repo.exists?()
  end

  def create_organization_membership(attributes) do
    %Core.Users.OrganizationMembership{}
    |> Core.Users.OrganizationMembership.changeset(attributes)
    |> Core.Repo.insert()
  end

  def create_organization_permission(attributes) do
    %Core.Users.OrganizationPermission{}
    |> Core.Users.OrganizationPermission.changeset(attributes)
    |> Core.Repo.insert()
  end
end
