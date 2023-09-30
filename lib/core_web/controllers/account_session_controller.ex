defmodule CoreWeb.AccountSessionController do
  use CoreWeb, :controller

  def create(conn, %{"_action" => "registered"} = params) do
    conn
    |> put_session(:account_return_to, ~p"/")
    |> create(params, "Account created successfully!")
  end

  def create(conn, %{"_action" => "password_updated"} = params) do
    conn
    |> put_session(:account_return_to, ~p"/accounts/settings")
    |> create(params, "Password updated successfully!")
  end

  def create(conn, params) do
    conn
    |> put_session(:account_return_to, ~p"/")
    |> create(params, "Welcome back!")
  end

  defp create(conn, %{"account" => account_params}, info) do
    %{"email_address" => email_address, "password" => password} = account_params

    if account = Core.Users.get_account_by_email_address_and_password(email_address, password) do
      conn
      |> put_flash(:info, info)
      |> CoreWeb.AccountAuthenticationHelpers.log_in_account(account, account_params)
    else
      # In order to prevent user enumeration attacks, don't disclose whether the email is registered.
      conn
      |> put_flash(:error, "Invalid email or password")
      |> put_flash(:email_address, String.slice(email_address, 0, 160))
      |> redirect(to: ~p"/accounts/log_in")
    end
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "Logged out successfully.")
    |> CoreWeb.AccountAuthenticationHelpers.log_out_account()
  end

  def callback(%{assigns: %{ueberauth_failure: _}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: ~p"/")
  end

  def callback(%{assigns: %{ueberauth_auth: ueberauth_auth}} = conn, _params) do
    # This is an example of how you can pass the auth information to
    # a function that you implement that will register or login a user
    with {:ok, account} <- Core.Users.find_or_create_account_from_oauth(ueberauth_auth),
         {encoded_token, account_token} <-
           Core.Users.AccountToken.build_email_token(account, "confirm"),
         {:ok, _account_token} <- Core.Repo.insert(account_token),
         {:ok, _confirmation} <- Core.Users.confirm_account(encoded_token) do
      conn
      |> put_flash(:info, "Successfully authenticated.")
      |> CoreWeb.AccountAuthenticationHelpers.log_in_account(account, %{return_to: ~p"/"})
      |> configure_session(renew: true)
    else
      :error ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: ~p"/")

      {:error, changeset} ->
        conn
        |> put_flash(:error, changeset)
        |> redirect(to: ~p"/")
    end
  end
end
