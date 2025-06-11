defmodule Core.UsersTest do
  use Core.DataCase

  alias Core.Users

  import Core.UsersFixtures
  alias Core.Users.{Account, AccountToken}

  describe "get_account_by_email/1" do
    test "does not return the account if the email does not exist" do
      refute Users.get_account_by_email("unknown@example.com")
    end

    test "returns the account if the email exists" do
      %{id: id} = account = account_fixture()
      assert %Account{id: ^id} = Users.get_account_by_email(account.email)
    end
  end

  describe "get_account_by_email_and_password/2" do
    test "does not return the account if the email does not exist" do
      refute Users.get_account_by_email_and_password("unknown@example.com", "hello world!")
    end

    test "does not return the account if the password is not valid" do
      account = account_fixture()
      refute Users.get_account_by_email_and_password(account.email, "invalid")
    end

    test "returns the account if the email and password are valid" do
      %{id: id} = account = account_fixture()

      assert %Account{id: ^id} =
               Users.get_account_by_email_and_password(account.email, valid_account_password())
    end
  end

  describe "get_account!/1" do
    test "raises if id is invalid" do
      assert_raise Ecto.NoResultsError, fn ->
        Users.get_account!("11111111-1111-1111-1111-111111111111")
      end
    end

    test "returns the account with the given id" do
      %{id: id} = account = account_fixture()
      assert %Account{id: ^id} = Users.get_account!(account.id)
    end
  end

  describe "register_account/1" do
    test "requires email and password to be set" do
      {:error, changeset} = Users.register_account(%{})

      assert %{
               password: ["can't be blank"],
               email: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "validates email and password when given" do
      {:error, changeset} = Users.register_account(%{email: "not valid", password: "not valid"})

      assert %{
               email: ["must have the @ sign and no spaces"],
               password: ["should be at least 12 character(s)"]
             } = errors_on(changeset)
    end

    test "validates maximum values for email and password for security" do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Users.register_account(%{email: too_long, password: too_long})
      assert "should be at most 160 character(s)" in errors_on(changeset).email
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates email uniqueness" do
      %{email: email} = account_fixture()
      {:error, changeset} = Users.register_account(%{email: email})
      assert "has already been taken" in errors_on(changeset).email

      # Now try with the upper cased email too, to check that email case is ignored.
      {:error, changeset} = Users.register_account(%{email: String.upcase(email)})
      assert "has already been taken" in errors_on(changeset).email
    end

    test "registers accounts with a hashed password" do
      email = unique_account_email()
      {:ok, account} = Users.register_account(valid_account_attributes(email: email))
      assert account.email == email
      assert is_binary(account.hashed_password)
      assert is_nil(account.confirmed_at)
      assert is_nil(account.password)
    end
  end

  describe "change_account_registration/2" do
    test "returns a changeset" do
      assert %Ecto.Changeset{} = changeset = Users.change_account_registration(%Account{})
      assert changeset.required == [:password, :email]
    end

    test "allows fields to be set" do
      email = unique_account_email()
      password = valid_account_password()

      changeset =
        Users.change_account_registration(
          %Account{},
          valid_account_attributes(email: email, password: password)
        )

      assert changeset.valid?
      assert get_change(changeset, :email) == email
      assert get_change(changeset, :password) == password
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "change_account_email/2" do
    test "returns a account changeset" do
      assert %Ecto.Changeset{} = changeset = Users.change_account_email(%Account{})
      assert changeset.required == [:email]
    end
  end

  describe "apply_account_email/3" do
    setup do
      %{account: account_fixture()}
    end

    test "requires email to change", %{account: account} do
      {:error, changeset} = Users.apply_account_email(account, valid_account_password(), %{})
      assert %{email: ["did not change"]} = errors_on(changeset)
    end

    test "validates email", %{account: account} do
      {:error, changeset} =
        Users.apply_account_email(account, valid_account_password(), %{email: "not valid"})

      assert %{email: ["must have the @ sign and no spaces"]} = errors_on(changeset)
    end

    test "validates maximum value for email for security", %{account: account} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Users.apply_account_email(account, valid_account_password(), %{email: too_long})

      assert "should be at most 160 character(s)" in errors_on(changeset).email
    end

    test "validates email uniqueness", %{account: account} do
      %{email: email} = account_fixture()
      password = valid_account_password()

      {:error, changeset} = Users.apply_account_email(account, password, %{email: email})

      assert "has already been taken" in errors_on(changeset).email
    end

    test "validates current password", %{account: account} do
      {:error, changeset} =
        Users.apply_account_email(account, "invalid", %{email: unique_account_email()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "applies the email without persisting it", %{account: account} do
      email = unique_account_email()
      {:ok, account} = Users.apply_account_email(account, valid_account_password(), %{email: email})
      assert account.email == email
      assert Users.get_account!(account.id).email != email
    end
  end

  describe "deliver_account_update_email_instructions/3" do
    setup do
      %{account: account_fixture()}
    end

    test "sends token through notification", %{account: account} do
      token =
        extract_account_token(fn url ->
          Users.deliver_account_update_email_instructions(account, "current@example.com", url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert account_token = Repo.get_by(AccountToken, token: :crypto.hash(:sha256, token))
      assert account_token.account_id == account.id
      assert account_token.sent_to == account.email
      assert account_token.context == "change:current@example.com"
    end
  end

  describe "update_account_email/2" do
    setup do
      account = account_fixture()
      email = unique_account_email()

      token =
        extract_account_token(fn url ->
          Users.deliver_account_update_email_instructions(%{account | email: email}, account.email, url)
        end)

      %{account: account, token: token, email: email}
    end

    test "updates the email with a valid token", %{account: account, token: token, email: email} do
      assert Users.update_account_email(account, token) == :ok
      changed_account = Repo.get!(Account, account.id)
      assert changed_account.email != account.email
      assert changed_account.email == email
      assert changed_account.confirmed_at
      assert changed_account.confirmed_at != account.confirmed_at
      refute Repo.get_by(AccountToken, account_id: account.id)
    end

    test "does not update email with invalid token", %{account: account} do
      assert Users.update_account_email(account, "oops") == :error
      assert Repo.get!(Account, account.id).email == account.email
      assert Repo.get_by(AccountToken, account_id: account.id)
    end

    test "does not update email if account email changed", %{account: account, token: token} do
      assert Users.update_account_email(%{account | email: "current@example.com"}, token) == :error
      assert Repo.get!(Account, account.id).email == account.email
      assert Repo.get_by(AccountToken, account_id: account.id)
    end

    test "does not update email if token expired", %{account: account, token: token} do
      {1, nil} = Repo.update_all(AccountToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Users.update_account_email(account, token) == :error
      assert Repo.get!(Account, account.id).email == account.email
      assert Repo.get_by(AccountToken, account_id: account.id)
    end
  end

  describe "change_account_password/2" do
    test "returns a account changeset" do
      assert %Ecto.Changeset{} = changeset = Users.change_account_password(%Account{})
      assert changeset.required == [:password]
    end

    test "allows fields to be set" do
      changeset =
        Users.change_account_password(%Account{}, %{
          "password" => "new valid password"
        })

      assert changeset.valid?
      assert get_change(changeset, :password) == "new valid password"
      assert is_nil(get_change(changeset, :hashed_password))
    end
  end

  describe "update_account_password/3" do
    setup do
      %{account: account_fixture()}
    end

    test "validates password", %{account: account} do
      {:error, changeset} =
        Users.update_account_password(account, valid_account_password(), %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{account: account} do
      too_long = String.duplicate("db", 100)

      {:error, changeset} =
        Users.update_account_password(account, valid_account_password(), %{password: too_long})

      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "validates current password", %{account: account} do
      {:error, changeset} =
        Users.update_account_password(account, "invalid", %{password: valid_account_password()})

      assert %{current_password: ["is not valid"]} = errors_on(changeset)
    end

    test "updates the password", %{account: account} do
      {:ok, account} =
        Users.update_account_password(account, valid_account_password(), %{
          password: "new valid password"
        })

      assert is_nil(account.password)
      assert Users.get_account_by_email_and_password(account.email, "new valid password")
    end

    test "deletes all tokens for the given account", %{account: account} do
      _ = Users.generate_account_session_token(account)

      {:ok, _} =
        Users.update_account_password(account, valid_account_password(), %{
          password: "new valid password"
        })

      refute Repo.get_by(AccountToken, account_id: account.id)
    end
  end

  describe "generate_account_session_token/1" do
    setup do
      %{account: account_fixture()}
    end

    test "generates a token", %{account: account} do
      token = Users.generate_account_session_token(account)
      assert account_token = Repo.get_by(AccountToken, token: token)
      assert account_token.context == "session"

      # Creating the same token for another account should fail
      assert_raise Ecto.ConstraintError, fn ->
        Repo.insert!(%AccountToken{
          token: account_token.token,
          account_id: account_fixture().id,
          context: "session"
        })
      end
    end
  end

  describe "get_account_by_session_token/1" do
    setup do
      account = account_fixture()
      token = Users.generate_account_session_token(account)
      %{account: account, token: token}
    end

    test "returns account by token", %{account: account, token: token} do
      assert session_account = Users.get_account_by_session_token(token)
      assert session_account.id == account.id
    end

    test "does not return account for invalid token" do
      refute Users.get_account_by_session_token("oops")
    end

    test "does not return account for expired token", %{token: token} do
      {1, nil} = Repo.update_all(AccountToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Users.get_account_by_session_token(token)
    end
  end

  describe "delete_account_session_token/1" do
    test "deletes the token" do
      account = account_fixture()
      token = Users.generate_account_session_token(account)
      assert Users.delete_account_session_token(token) == :ok
      refute Users.get_account_by_session_token(token)
    end
  end

  describe "deliver_account_confirmation_instructions/2" do
    setup do
      %{account: account_fixture()}
    end

    test "sends token through notification", %{account: account} do
      token =
        extract_account_token(fn url ->
          Users.deliver_account_confirmation_instructions(account, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert account_token = Repo.get_by(AccountToken, token: :crypto.hash(:sha256, token))
      assert account_token.account_id == account.id
      assert account_token.sent_to == account.email
      assert account_token.context == "confirm"
    end
  end

  describe "confirm_account/1" do
    setup do
      account = account_fixture()

      token =
        extract_account_token(fn url ->
          Users.deliver_account_confirmation_instructions(account, url)
        end)

      %{account: account, token: token}
    end

    test "confirms the email with a valid token", %{account: account, token: token} do
      assert {:ok, confirmed_account} = Users.confirm_account(token)
      assert confirmed_account.confirmed_at
      assert confirmed_account.confirmed_at != account.confirmed_at
      assert Repo.get!(Account, account.id).confirmed_at
      refute Repo.get_by(AccountToken, account_id: account.id)
    end

    test "does not confirm with invalid token", %{account: account} do
      assert Users.confirm_account("oops") == :error
      refute Repo.get!(Account, account.id).confirmed_at
      assert Repo.get_by(AccountToken, account_id: account.id)
    end

    test "does not confirm email if token expired", %{account: account, token: token} do
      {1, nil} = Repo.update_all(AccountToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      assert Users.confirm_account(token) == :error
      refute Repo.get!(Account, account.id).confirmed_at
      assert Repo.get_by(AccountToken, account_id: account.id)
    end
  end

  describe "deliver_account_reset_password_instructions/2" do
    setup do
      %{account: account_fixture()}
    end

    test "sends token through notification", %{account: account} do
      token =
        extract_account_token(fn url ->
          Users.deliver_account_reset_password_instructions(account, url)
        end)

      {:ok, token} = Base.url_decode64(token, padding: false)
      assert account_token = Repo.get_by(AccountToken, token: :crypto.hash(:sha256, token))
      assert account_token.account_id == account.id
      assert account_token.sent_to == account.email
      assert account_token.context == "reset_password"
    end
  end

  describe "get_account_by_reset_password_token/1" do
    setup do
      account = account_fixture()

      token =
        extract_account_token(fn url ->
          Users.deliver_account_reset_password_instructions(account, url)
        end)

      %{account: account, token: token}
    end

    test "returns the account with valid token", %{account: %{id: id}, token: token} do
      assert %Account{id: ^id} = Users.get_account_by_reset_password_token(token)
      assert Repo.get_by(AccountToken, account_id: id)
    end

    test "does not return the account with invalid token", %{account: account} do
      refute Users.get_account_by_reset_password_token("oops")
      assert Repo.get_by(AccountToken, account_id: account.id)
    end

    test "does not return the account if token expired", %{account: account, token: token} do
      {1, nil} = Repo.update_all(AccountToken, set: [inserted_at: ~N[2020-01-01 00:00:00]])
      refute Users.get_account_by_reset_password_token(token)
      assert Repo.get_by(AccountToken, account_id: account.id)
    end
  end

  describe "reset_account_password/2" do
    setup do
      %{account: account_fixture()}
    end

    test "validates password", %{account: account} do
      {:error, changeset} =
        Users.reset_account_password(account, %{
          password: "not valid",
          password_confirmation: "another"
        })

      assert %{
               password: ["should be at least 12 character(s)"],
               password_confirmation: ["does not match password"]
             } = errors_on(changeset)
    end

    test "validates maximum values for password for security", %{account: account} do
      too_long = String.duplicate("db", 100)
      {:error, changeset} = Users.reset_account_password(account, %{password: too_long})
      assert "should be at most 72 character(s)" in errors_on(changeset).password
    end

    test "updates the password", %{account: account} do
      {:ok, updated_account} = Users.reset_account_password(account, %{password: "new valid password"})
      assert is_nil(updated_account.password)
      assert Users.get_account_by_email_and_password(account.email, "new valid password")
    end

    test "deletes all tokens for the given account", %{account: account} do
      _ = Users.generate_account_session_token(account)
      {:ok, _} = Users.reset_account_password(account, %{password: "new valid password"})
      refute Repo.get_by(AccountToken, account_id: account.id)
    end
  end

  describe "inspect/2 for the Account module" do
    test "does not include password" do
      refute inspect(%Account{password: "123456"}) =~ "password: \"123456\""
    end
  end
end
