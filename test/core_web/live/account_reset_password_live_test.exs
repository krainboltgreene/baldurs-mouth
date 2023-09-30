defmodule CoreWeb.AccountResetPasswordLiveTest do
  use CoreWeb.ConnCase

  import Phoenix.LiveViewTest
  import Core.UsersFixtures

  setup do
    account = account_fixture()

    token =
      extract_account_token(fn url ->
        Core.Users.deliver_account_reset_password_instructions(account, url)
      end)

    %{token: token, account: account}
  end

  describe "Reset password page" do
    test "renders reset password with valid token", %{conn: conn, token: token} do
      {:ok, _lv, html} = live(conn, ~p"/accounts/reset_password/#{token}")

      assert html =~ "Reset Password"
    end

    test "does not render reset password with invalid token", %{conn: conn} do
      {:error, {:redirect, to}} = live(conn, ~p"/accounts/reset_password/invalid")

      assert to == %{
               flash: %{"error" => "Reset password link is invalid or it has expired."},
               to: ~p"/"
             }
    end

    test "renders errors for invalid data", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/reset_password/#{token}")

      result =
        lv
        |> element("#reset_password_form")
        |> render_change(
          account: %{"password" => "secret12", "confirmation_password" => "secret123456"}
        )

      assert result =~ "should be at least 12 character"
      assert result =~ "does not match password"
    end
  end

  describe "Reset Password" do
    test "resets password once", %{conn: conn, token: token, account: account} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/reset_password/#{token}")

      {:ok, conn} =
        lv
        |> form("#reset_password_form",
          account: %{
            "password" => "new valid password",
            "password_confirmation" => "new valid password"
          }
        )
        |> render_submit()
        |> follow_redirect(conn, ~p"/accounts/log_in")

      refute get_session(conn, :account_token)
      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~ "Password reset successfully"

      assert Core.Users.get_account_by_email_address_and_password(
               account.email_address,
               "new valid password"
             )
    end

    test "does not reset password on invalid data", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/reset_password/#{token}")

      result =
        lv
        |> form("#reset_password_form",
          account: %{
            "password" => "too short",
            "password_confirmation" => "does not match"
          }
        )
        |> render_submit()

      assert result =~ "Reset Password"
      assert result =~ "should be at least 12 character(s)"
      assert result =~ "does not match password"
    end
  end

  describe "Reset password navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn, token: token} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/reset_password/#{token}")

      {:ok, _lv, html} =
        lv
        |> element(~s|main a:fl-contains("Log in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/accounts/log_in")

      assert html =~ "Log in"
    end

    test "redirects to password reset page when the Register button is clicked", %{
      conn: conn,
      token: token
    } do
      {:ok, lv, _html} = live(conn, ~p"/accounts/reset_password/#{token}")

      {:ok, _lv, html} =
        lv
        |> element(~s|main a:fl-contains("Register")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/accounts/register")

      assert html =~ "Register"
    end
  end
end
