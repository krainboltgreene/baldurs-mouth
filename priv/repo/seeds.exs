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

Core.Repo.transaction(fn ->
  {:ok, _} =
    Core.Users.create_organization(%{
      name: "Global"
    })

  {:ok, _} =
    Core.Users.create_permission(%{
      name: "Administrator"
    })

  {:ok, _} =
    Core.Users.create_permission(%{
      name: "Default"
    })

  :ok = Utilities.Seeder.load_all()
end)

# Reset the log level back to normal
Logger.configure(level: previous_log_level)
