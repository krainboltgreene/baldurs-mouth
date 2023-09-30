defmodule Core.Repo.Migrations.EnableExtensions do
  use Ecto.Migration

  def change do
    [
      "citext",
      "pgcrypto",
      "cube",
      "btree_gin",
      "btree_gist",
      "hstore",
      "isn",
      "ltree",
      "lo",
      "fuzzystrmatch",
      "pg_buffercache",
      "pgrowlocks",
      "pg_prewarm",
      "pg_stat_statements",
      "pg_trgm",
      "tablefunc"
    ]
    |> Enum.each(fn
      extension ->
        execute "CREATE EXTENSION IF NOT EXISTS \"#{extension}\"",
                "DROP EXTENSION IF EXISTS \"#{extension}\""
    end)
  end
end
