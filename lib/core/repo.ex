defmodule Core.Repo do
  @moduledoc """
  A set of funcionality that relates to the specific database we use (postgresql).
  """
  use Ecto.Repo,
    otp_app: :core,
    adapter: Ecto.Adapters.Postgres

  require Ecto.Query
end
