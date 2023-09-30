defmodule CoreWeb.AccountSettingsLiveTest do
  use CoreWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions
  import Core.UsersFixtures
  import Core.SessionsFixtures

  setup :set_swoosh_global

  describe "Settings page" do
    test "renders settings page", %{conn: conn} do
      {:ok, _lv, html} =
        conn
        |> log_in_account(account_fixture())
        |> live(~p"/accounts/settings")

      assert html =~ "Change Email"
      assert html =~ "Change Password"
    end

    test "redirects if account is not logged in", %{conn: conn} do
      assert {:error, redirect} = live(conn, ~p"/accounts/settings")

      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/accounts/log_in"
      assert %{"error" => "You must log in to access this page."} = flash
    end
  end

  describe "update email form" do
    setup %{conn: conn} do
      password = valid_account_password()
      account = account_fixture(%{password: password})
      %{conn: log_in_account(conn, account), account: account, password: password}
    end

    test "updates the account email", %{conn: conn, password: password, account: account} do
      new_email = unique_account_email_address()

      {:ok, lv, _html} = live(conn, ~p"/accounts/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => password,
          "account" => %{"email_address" => new_email}
        })
        |> render_submit()

      assert result =~ "A link to confirm your email"
      assert Core.Users.get_account_by_email_address(account.email_address)
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/settings")

      result =
        lv
        |> element("#email_form")
        |> render_change(%{
          "action" => "update_email",
          "current_password" => "invalid",
          "account" => %{"email_address" => "with spaces"}
        })

      assert result =~ "Change Email"
      assert result =~ "must have the @ sign and no spaces"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn, account: account} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/settings")

      result =
        lv
        |> form("#email_form", %{
          "current_password" => "invalid",
          "account" => %{"email_address" => account.email_address}
        })
        |> render_submit()

      assert result =~ "Change Email"
      assert result =~ "did not change"
      assert result =~ "is not valid"
    end
  end

  describe "update password form" do
    setup %{conn: conn} do
      password = valid_account_password()
      account = account_fixture(%{password: password})
      %{conn: log_in_account(conn, account), account: account, password: password}
    end

    test "updates the account password", %{conn: conn, account: account, password: password} do
      new_password = valid_account_password()

      {:ok, lv, _html} = live(conn, ~p"/accounts/settings")

      form =
        form(lv, "#password_form", %{
          "current_password" => password,
          "account" => %{
            "email_address" => account.email_address,
            "password" => new_password,
            "password_confirmation" => new_password
          }
        })

      render_submit(form)

      new_password_conn = follow_trigger_action(form, conn)

      assert redirected_to(new_password_conn) == ~p"/accounts/settings"

      assert get_session(new_password_conn, :account_token) != get_session(conn, :account_token)

      assert Phoenix.Flash.get(new_password_conn.assigns.flash, :info) =~
               "Password updated successfully"

      assert Core.Users.get_account_by_email_address_and_password(
               account.email_address,
               new_password
             )
    end

    test "renders errors with invalid data (phx-change)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/settings")

      result =
        lv
        |> element("#password_form")
        |> render_change(%{
          "current_password" => "invalid",
          "account" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end

    test "renders errors with invalid data (phx-submit)", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/settings")

      result =
        lv
        |> form("#password_form", %{
          "current_password" => "invalid",
          "account" => %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        })
        |> render_submit()

      assert result =~ "Change Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
      assert result =~ "is not valid"
    end
  end

  describe "confirm email" do
    setup %{conn: conn} do
      account = account_fixture()
      email = unique_account_email_address()

      token =
        extract_account_token(fn url ->
          Core.Users.deliver_account_update_email_address_instructions(
            %{account | email_address: email},
            account.email_address,
            url
          )
        end)

      %{conn: log_in_account(conn, account), token: token, email_address: email, account: account}
    end

    test "updates the account email once", %{
      conn: conn,
      account: account,
      token: token,
      email_address: email_address
    } do
      {:error, redirect} = live(conn, ~p"/accounts/settings/confirm_email/#{token}")

      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/accounts/settings"
      assert %{"info" => message} = flash
      assert message == "Email changed successfully."
      refute Core.Users.get_account_by_email_address(account.email_address)
      assert Core.Users.get_account_by_email_address(email_address)

      # use confirm token again
      {:error, redirect} = live(conn, ~p"/accounts/settings/confirm_email/#{token}")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/accounts/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
    end

    test "does not update email with invalid token", %{conn: conn, account: account} do
      {:error, redirect} = live(conn, ~p"/accounts/settings/confirm_email/oops")
      assert {:live_redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/accounts/settings"
      assert %{"error" => message} = flash
      assert message == "Email change link is invalid or it has expired."
      assert Core.Users.get_account_by_email_address(account.email_address)
    end

    test "redirects if account is not logged in", %{token: token} do
      conn = build_conn()
      {:error, redirect} = live(conn, ~p"/accounts/settings/confirm_email/#{token}")
      assert {:redirect, %{to: path, flash: flash}} = redirect
      assert path == ~p"/accounts/log_in"
      assert %{"error" => message} = flash
      assert message == "You must log in to access this page."
    end
  end
end
