defmodule Core.SessionsFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Core.Sessions` context.
  """

  def stub_account_session_fetch(context) do
    Mimic.stub(Core.Users, :get_account_by_session_token, fn _ ->
      Map.get(context, :account)
    end)

    context
  end

  @doc """
  Setup helper that registers and logs in accounts.

      setup :register_and_log_in_account

  It stores an updated connection and a registered account in the
  test context.
  """
  def register_and_log_in_account(context) do
    context
    |> Map.put(:account, Core.UsersFixtures.account_fixture())
    |> then(fn context ->
      Map.put(context, :conn, log_in_account(context.conn, context.account))
    end)
  end

  @doc """
  Logs the given `account` into the `conn`.

  It returns an updated `conn`.
  """
  def log_in_account(conn, account) do
    token = Core.Users.generate_account_session_token(account)

    conn
    |> Phoenix.ConnTest.init_test_session(%{})
    |> Plug.Conn.put_session(:account_token, token)
  end
end
