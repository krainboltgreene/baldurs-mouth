defmodule CoreWeb.AccountForgotPasswordLiveTest do
  use CoreWeb.ConnCase

  import Phoenix.LiveViewTest
  import Core.UsersFixtures
  import Core.SessionsFixtures

  describe "Forgot password page" do
    test "renders email page", %{conn: conn} do
      {:ok, lv, html} = live(conn, ~p"/accounts/reset_password")

      assert html =~ "Forgot your password?"
      assert has_element?(lv, ~s|a[href="#{~p"/accounts/register"}"]|, "Register")
      assert has_element?(lv, ~s|a[href="#{~p"/accounts/log_in"}"]|, "Log in")
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_account(account_fixture())
        |> live(~p"/accounts/reset_password")
        |> follow_redirect(conn, ~p"/")

      assert {:ok, _conn} = result
    end
  end

  describe "Reset link" do
    setup do
      %{account: account_fixture()}
    end

    test "sends a new reset password token", %{conn: conn, account: account} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", account: %{"email_address" => account.email_address})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"

      assert Core.Repo.get_by!(Core.Users.AccountToken, account_id: account.id).context ==
               "reset_password"
    end

    test "does not send reset password token if email is invalid", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/reset_password")

      {:ok, conn} =
        lv
        |> form("#reset_password_form", account: %{"email_address" => "unknown@example.com"})
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "If your email is in our system"
      assert Core.Repo.all(Core.Users.AccountToken) == []
    end
  end
end
