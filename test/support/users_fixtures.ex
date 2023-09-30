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

  @doc """
  Generate a permission.
  """
  def permission_fixture(attrs \\ %{}) do
    {:ok, permission} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Core.Users.create_permission()

    permission
  end

  @doc """
  Generate a organization.
  """
  def organization_fixture(attrs \\ %{}) do
    {:ok, organization} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Core.Users.create_organization()

    organization
  end

  def with_default_permission(context) do
    Map.put(
      context,
      :default_permission,
      Core.Users.create_permission(%{
        name: "Default"
      })
    )
  end

  def with_administrator_permission(context) do
    Map.put(
      context,
      :administrator_permission,
      Core.Users.create_permission(%{
        name: "Administrator"
      })
    )
  end

  def with_global_organization(context) do
    Map.put(
      context,
      :global_organization,
      Core.Users.create_organization(%{
        name: "Global"
      })
    )
  end
end
