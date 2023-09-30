defmodule CoreWeb.AccountRegistrationLiveTest do
  use CoreWeb.ConnCase

  import Phoenix.LiveViewTest
  import Swoosh.TestAssertions
  import Core.UsersFixtures
  import Core.SessionsFixtures

  setup :set_swoosh_global

  describe "Registration page" do
    test "renders registration page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/accounts/register")

      assert html =~ "Register"
      assert html =~ "Log in"
    end

    test "redirects if already logged in", %{conn: conn} do
      result =
        conn
        |> log_in_account(account_fixture())
        |> live(~p"/accounts/register")
        |> follow_redirect(conn, "/")

      assert {:ok, _conn} = result
    end

    test "renders errors for invalid data", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      result =
        lv
        |> element("#registration_form")
        |> render_change(account: %{"email_address" => "with spaces", "password" => "too short"})

      assert result =~ "Register"
      assert result =~ "must have the @ sign and no spaces"
      assert result =~ "should be at least 12 character"
    end
  end

  describe "register account" do
    test "creates account and logs the account in", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      email_address = unique_account_email_address()

      form =
        form(lv, "#registration_form",
          account: valid_account_attributes(email_address: email_address)
        )

      render_submit(form)
      conn = follow_trigger_action(form, conn)

      assert redirected_to(conn) == ~p"/"

      # Now do a logged in request and assert on the menu
      conn = get(conn, "/")
      response = html_response(conn, 200)
      assert response =~ "Account"
      assert response =~ "Log out"
    end

    test "renders errors for duplicated email", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      account = account_fixture(%{email_address: "test@email.com"})

      result =
        lv
        |> form("#registration_form",
          account: %{"email_address" => account.email_address, "password" => "valid_password"}
        )
        |> render_submit()

      assert result =~ "has already been taken"
    end
  end

  describe "registration navigation" do
    test "redirects to login page when the Log in button is clicked", %{conn: conn} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/register")

      {:ok, _login_live, login_html} =
        lv
        |> element(~s|main a:fl-contains("Sign in")|)
        |> render_click()
        |> follow_redirect(conn, ~p"/accounts/log_in")

      assert login_html =~ "Log in"
    end
  end
end
