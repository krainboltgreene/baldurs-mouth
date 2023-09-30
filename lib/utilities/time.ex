defmodule Utilities.Time do
  @moduledoc """
  Useful behavior for dealing with time.
  """

  @spec now() :: NaiveDateTime.t()
  def now(), do: NaiveDateTime.utc_now() |> NaiveDateTime.truncate(:second)
end
