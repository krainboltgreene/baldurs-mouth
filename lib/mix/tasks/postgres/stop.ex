defmodule Mix.Tasks.Postgres.Stop do
  @moduledoc false
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    System.cmd("which", ["pg_ctl"])
    |> case do
      {_, 0} -> "pg_ctl"
      _ -> "/usr/lib/postgresql/13/bin/pg_ctl"
    end
    |> System.cmd(["-D", "tmp/postgres/data", "-l", "tmp/postgres.log", "stop"],
      into: IO.stream()
    )
  end
end
