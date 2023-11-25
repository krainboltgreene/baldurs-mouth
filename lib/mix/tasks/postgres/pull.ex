defmodule Mix.Tasks.Postgres.Pull do
  @moduledoc false
  use Mix.Task

  @impl Mix.Task
  def run(_) do
    System.cmd("mkdir", ["tmp"])

    System.cmd(
      "pg_dump",
      [
        "--file=tmp/dump.sql",
        "--data-only",
        "--exclude-schema=auth",
        "--exclude-schema=storage",
        "--exclude-schema=pgsodium",
        "--exclude-schema=supabase_migrations",
        "--exclude-schema=vault",
        "--exclude-table-data=schema_migrations",
        "--quote-all-identifiers",
        System.get_env("DATABASE_URI")
      ],
      into: IO.stream()
    )
  end
end
