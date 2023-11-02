defmodule Core.Users.Account do
  @moduledoc false
  use Ecto.Schema
  import Estate, only: [state_machines: 2]

  state_machines(
    Core.Repo,
    onboarding_state: [
      complete: [converted: "completed"]
    ]
  )

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "accounts" do
    field(:provider, :string)
    field(:provider_id, :string)
    field(:provider_access_token, :string)
    field(:provider_refresh_token, :string)
    field(:provider_token_expiration, :integer)
    field(:provider_scopes, {:array, :string})
    field(:avatar_uri, :string)
    field(:email_address, :string)
    field(:username, :string)
    field(:onboarding_state, Ecto.Enum, values: [:converted], default: :converted)
    field(:password, :string, virtual: true, redact: true)
    field(:hashed_password, :string, redact: true)
    field(:confirmed_at, :naive_datetime)
    timestamps()
    embeds_one(:settings, Core.Users.Settings)
    embeds_one(:profile, Core.Users.Profile)
    has_many(:characters, Core.Gameplay.Character)
    has_many(:saves, through: [:characters, :saves])
  end

  @type t :: %__MODULE__{
          email_address: String.t(),
          username: String.t(),
          onboarding_state: String.t(),
          password: String.t() | nil,
          hashed_password: String.t() | nil,
          settings: Core.Users.Settings.t() | nil,
          profile: Core.Users.Profile.t() | nil
        }

  def oauth_changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [
      :provider,
      :provider_id,
      :provider_access_token,
      :provider_refresh_token,
      :provider_token_expiration,
      :provider_scopes,
      :avatar_uri,
      :username
    ])
    |> Ecto.Changeset.validate_required([
      :provider,
      :provider_id,
      :provider_access_token,
      :provider_refresh_token,
      :provider_token_expiration,
      :provider_scopes,
      :avatar_uri,
      :username
    ])
  end

  @doc """
  A account changeset for registration.

  It is important to validate the length of both email and password.
  Otherwise databases may truncate the email without warnings, which
  could lead to unpredictable or insecure behaviour. Long passwords may
  also be very expensive to hash for certain algorithms.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.

    * `:validate_email` - Validates the uniqueness of the email, in case
      you don't want to validate the uniqueness of the email (like when
      using this changeset for validations on a LiveView form before
      submitting the form), this option can be set to `false`.
      Defaults to `true`.
  """
  def registration_changeset(record, attributes, opts \\ []) do
    record
    |> Ecto.Changeset.change(with_autousername(attributes))
    |> Ecto.Changeset.cast(attributes, [
      :email_address,
      :username,
      :password,
      :provider,
      :provider_id,
      :provider_access_token,
      :provider_refresh_token,
      :provider_token_expiration,
      :provider_scopes,
      :avatar_uri
    ])
    |> Ecto.Changeset.validate_required([
      :username
    ])
    |> validate_email_address(opts)
    |> validate_password(opts)
  end

  defp validate_email_address(changeset, opts) do
    changeset
    |> Ecto.Changeset.validate_required([:email_address])
    |> Ecto.Changeset.validate_format(:email_address, ~r/^[^\s]+@[^\s]+$/,
      message: "must have the @ sign and no spaces"
    )
    |> Ecto.Changeset.validate_length(:email_address, max: 160)
    |> maybe_validate_unique_email_address(opts)
  end

  defp validate_password(changeset, opts) do
    changeset
    |> Ecto.Changeset.validate_required([:password])
    |> Ecto.Changeset.validate_length(:password, min: 12, max: 72)
    # Replace this with actual password complexity logic
    # |> Ecto.Changeset.validate_format(:password, ~r/[a-z]/, message: "at least one lower case character")
    # |> Ecto.Changeset.validate_format(:password, ~r/[A-Z]/, message: "at least one upper case character")
    # |> Ecto.Changeset.validate_format(:password, ~r/[!?@#$%^&*_0-9]/, message: "at least one digit or punctuation character")
    |> maybe_hash_password(opts)
  end

  defp maybe_hash_password(changeset, opts) do
    hash_password? = Keyword.get(opts, :hash_password, true)
    password = Ecto.Changeset.get_change(changeset, :password)

    if hash_password? && password && changeset.valid? do
      changeset
      # If using Bcrypt, then further validate it is at most 72 bytes long
      |> Ecto.Changeset.validate_length(:password, max: 72, count: :bytes)
      |> Ecto.Changeset.put_change(:hashed_password, Argon2.hash_pwd_salt(password))
      |> Ecto.Changeset.delete_change(:password)
    else
      changeset
    end
  end

  defp maybe_validate_unique_email_address(changeset, opts) do
    if Keyword.get(opts, :validate_email, true) do
      changeset
      |> Ecto.Changeset.unsafe_validate_unique(:email_address, Core.Repo)
      |> Ecto.Changeset.unique_constraint(:email_address)
    else
      changeset
    end
  end

  defp with_autousername(%{"email_address" => email_address}) when is_binary(email_address),
    do: with_autousername(%{email_address: email_address})

  defp with_autousername(%{email_address: email_address}) when is_binary(email_address) do
    %{username: email_address |> String.split("@") |> List.first()}
  end

  defp with_autousername(attributes), do: attributes

  @doc """
  A account changeset for changing the email.

  It requires the email to change otherwise an error is added.
  """
  def email_address_changeset(account, attributes, opts \\ []) do
    account
    |> Ecto.Changeset.cast(attributes, [:email_address])
    |> validate_email_address(opts)
    |> case do
      %{changes: %{email_address: _}} = changeset -> changeset
      %{} = changeset -> Ecto.Changeset.add_error(changeset, :email_address, "did not change")
    end
  end

  @doc """
  A account changeset for changing the password.

  ## Options

    * `:hash_password` - Hashes the password so it can be stored securely
      in the database and ensures the password field is cleared to prevent
      leaks in the logs. If password hashing is not needed and clearing the
      password field is not desired (like when using this changeset for
      validations on a LiveView form), this option can be set to `false`.
      Defaults to `true`.
  """
  def password_changeset(account, attributes, opts \\ []) do
    account
    |> Ecto.Changeset.cast(attributes, [:password])
    |> Ecto.Changeset.validate_confirmation(:password, message: "does not match password")
    |> validate_password(opts)
  end

  @doc """
  Confirms the account by setting `confirmed_at`.
  """
  def confirm_changeset(account) do
    Ecto.Changeset.change(account, confirmed_at: Utilities.Time.now())
  end

  @doc """
  Verifies the password.

  If there is no account or the account doesn't have a password, we call
  `Argon2.no_user_verify/0` to avoid timing attacks.
  """
  def valid_password?(%__MODULE__{hashed_password: hashed_password}, password)
      when is_binary(hashed_password) and byte_size(password) > 0 do
    Argon2.verify_pass(password, hashed_password)
  end

  def valid_password?(_, _) do
    Argon2.no_user_verify()
    false
  end

  @doc """
  Validates the current password otherwise adds an error to the changeset.
  """
  def validate_current_password(changeset, password) do
    if valid_password?(changeset.data, password) do
      changeset
    else
      Ecto.Changeset.add_error(changeset, :current_password, "is not valid")
    end
  end
end
