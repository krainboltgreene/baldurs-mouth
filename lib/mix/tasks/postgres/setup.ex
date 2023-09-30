defmodule Mix.Tasks.Postgres.Setup do
  @moduledoc false
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    System.cmd("which", ["initdb"])
    |> case do
      {_, 0} -> "initdb"
      _ -> "/usr/lib/postgresql/13/bin/initdb"
    end
    |> System.cmd(["--username=postgres", "tmp/postgres/data"], into: IO.stream())
  end
end
