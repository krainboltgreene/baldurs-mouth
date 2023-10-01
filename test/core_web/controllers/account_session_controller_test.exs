defmodule CoreWeb.AccountSessionControllerTest do
  use CoreWeb.ConnCase, async: true

  import Core.UsersFixtures
  import Core.SessionsFixtures

  setup do
    %{account: account_fixture()}
  end

  describe "POST /accounts/log_in" do
    test "logs the account in", %{conn: conn, account: account} do
      conn =
        post(conn, ~p"/accounts/log_in", %{
          "account" => %{
            "email_address" => account.email_address,
            "password" => valid_account_password()
          }
        })

      assert get_session(conn, :account_token)
      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, ~p"/")
      response = html_response(conn, 200)
      assert response =~ "Account"
      assert response =~ ~p"/accounts/settings"
      assert response =~ ~p"/accounts/log_out"
    end

    test "logs the account in with remember me", %{conn: conn, account: account} do
      conn =
        post(conn, ~p"/accounts/log_in", %{
          "account" => %{
            "email_address" => account.email_address,
            "password" => valid_account_password(),
            "remember_me" => "true"
          }
        })

      assert conn.resp_cookies["_core_web_account_remember_me"]
      assert redirected_to(conn) == ~p"/"
    end

    # Implement this feature at some point
    test "logs the account in with return to", %{conn: conn, account: account} do
      conn =
        conn
        |> init_test_session(account_return_to: ~p"/")
        |> post(~p"/accounts/log_in", %{
          "account" => %{
            "email_address" => account.email_address,
            "password" => valid_account_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Welcome back!"
    end

    test "login following registration", %{conn: conn, account: account} do
      conn =
        conn
        |> post(~p"/accounts/log_in", %{
          "_action" => "registered",
          "account" => %{
            "email_address" => account.email_address,
            "password" => valid_account_password()
          }
        })

      assert redirected_to(conn) == ~p"/"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Account created successfully"
    end

    test "login following password update", %{conn: conn, account: account} do
      conn =
        conn
        |> post(~p"/accounts/log_in", %{
          "_action" => "password_updated",
          "account" => %{
            "email_address" => account.email_address,
            "password" => valid_account_password()
          }
        })

      assert redirected_to(conn) == ~p"/accounts/settings"
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password updated successfully"
    end

    test "redirects to login page with invalid credentials", %{conn: conn} do
      conn =
        post(conn, ~p"/accounts/log_in", %{
          "account" => %{"email_address" => "invalid@email.com", "password" => "invalid_password"}
        })

      assert Phoenix.Flash.get(conn.assigns.flash, :error) == "Invalid email or password"
      assert redirected_to(conn) == ~p"/accounts/log_in"
    end
  end

  describe "DELETE /accounts/log_out" do
    test "logs the account out", %{conn: conn, account: account} do
      conn = conn |> log_in_account(account) |> delete(~p"/accounts/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :account_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end

    test "succeeds even if the account is not logged in", %{conn: conn} do
      conn = delete(conn, ~p"/accounts/log_out")
      assert redirected_to(conn) == ~p"/"
      refute get_session(conn, :account_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Logged out successfully"
    end
  end
end
