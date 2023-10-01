defmodule Core.UsersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Core.Users` context.
  """

  def create_account(context) do
    Map.put(context, :account, Core.UsersFixtures.account_fixture())
  end

  def unique_account_email_address, do: "account#{System.unique_integer()}@example.com"
  def valid_account_password, do: "hello world!"

  def valid_account_attributes(attrs \\ %{}) do
    Enum.into(attrs, %{
      email_address: unique_account_email_address(),
      password: valid_account_password()
    })
  end

  def account_fixture(attrs \\ %{}) do
    {:ok, account} =
      attrs
      |> valid_account_attributes()
      |> Core.Users.register_account()

    account
  end

  def extract_account_token(fun) do
    {:ok, captured_email} = fun.(&"[TOKEN]#{&1}[TOKEN]")
    [_, token | _] = String.split(captured_email.text_body, "[TOKEN]")
    token
  end
end
