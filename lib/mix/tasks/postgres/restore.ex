defmodule Mix.Tasks.Postgres.Restore do
  @moduledoc false
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    System.shell("psql -h localhost -U postgres core_dev < tmp/dump.sql")
  end
end
