# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Core.Repo.insert!(%Core.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

require Logger

# Capture the current log level so we can reset after
previous_log_level = Logger.level()

# Change the log level so we don't see all the debug output.
Logger.configure(level: :info)

if Mix.env() == :dev do
  Core.Repo.transaction(fn ->
    {:ok, krainboltgreene} =
      Core.Users.register_account(%{
        name: "Kurtis Rainbolt-Greene",
        email_address: "kurtis@project.com",
        username: "krainboltgreene",
        password: "passwordpassword"
      })

    {encoded_token, account_token} =
      Core.Users.AccountToken.build_email_token(krainboltgreene, "confirm")

    {:ok, _} = Core.Repo.insert(account_token)
    {:ok, _} = Core.Users.confirm_account(encoded_token)

    {:ok, josephryan} =
      Core.Users.register_account(%{
        name: "Joseph Ryan",
        email_address: "joseph.j.a.ryan@project.com",
        username: "josephryan",
        password: "passwordpassword"
      })

    {encoded_token, account_token} =
      Core.Users.AccountToken.build_email_token(josephryan, "confirm")

    {:ok, _} = Core.Repo.insert(account_token)
    {:ok, _} = Core.Users.confirm_account(encoded_token)

    {:ok, organization} =
      Core.Users.join_organization_by_slug(krainboltgreene, "global", "administrator")

    {:ok, _organization} =
      Core.Users.join_organization_by_slug(josephryan, "global", "administrator")
  end)
end

# Reset the log level back to normal
Logger.configure(level: previous_log_level)
