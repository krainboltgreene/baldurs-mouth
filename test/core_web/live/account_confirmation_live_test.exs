defmodule CoreWeb.AccountConfirmationLiveTest do
  use CoreWeb.ConnCase, async: true

  import Phoenix.LiveViewTest
  import Core.UsersFixtures

  alias Core.Users
  alias Core.Repo

  setup do
    %{account: account_fixture()}
  end

  describe "Confirm account" do
    test "renders confirmation page", %{conn: conn} do
      {:ok, _lv, html} = live(conn, ~p"/accounts/confirm/some-token")
      assert html =~ "Confirm Account"
    end

    test "confirms the given token once", %{conn: conn, account: account} do
      token =
        extract_account_token(fn url ->
          Users.deliver_account_confirmation_instructions(account, url)
        end)

      {:ok, lv, _html} = live(conn, ~p"/accounts/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :info) =~
               "Account confirmed successfully"

      assert Users.get_account!(account.id).confirmed_at
      refute get_session(conn, :account_token)
      assert Repo.all(Users.AccountToken) == []

      # when not logged in
      {:ok, lv, _html} = live(conn, ~p"/accounts/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Account confirmation link is invalid or it has expired"

      # when logged in
      conn =
        build_conn()
        |> log_in_account(account)

      {:ok, lv, _html} = live(conn, ~p"/accounts/confirm/#{token}")

      result =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, "/")

      assert {:ok, conn} = result
      refute Phoenix.Flash.get(conn.assigns.flash, :error)
    end

    test "does not confirm email with invalid token", %{conn: conn, account: account} do
      {:ok, lv, _html} = live(conn, ~p"/accounts/confirm/invalid-token")

      {:ok, conn} =
        lv
        |> form("#confirmation_form")
        |> render_submit()
        |> follow_redirect(conn, ~p"/")

      assert Phoenix.Flash.get(conn.assigns.flash, :error) =~
               "Account confirmation link is invalid or it has expired"

      refute Users.get_account!(account.id).confirmed_at
    end
  end
end
