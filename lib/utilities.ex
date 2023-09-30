defmodule Utilities do
  @moduledoc """
  Generic behavior that we use elsewhere.
  """

  @tenant_key {__MODULE__, :world_id}

  @doc """
  find duplicate-aware intersection between lists or stings

  ## Examples:
      iex> Utilities.intersect([1,2,3], [2,3,4])
      [2, 3]
      iex> Utilities.intersect([1,2,2,3], [2,3,4])
      [2, 3]
      iex> Utilities.intersect([1,2,2,3], [2,2,3,4])
      [2, 2, 3]
      iex> Utilities.intersect("abcb", "bbcx")
      ["b", "c", "b"]
      iex> Utilities.intersect("abcb", "")
      []
      iex> Utilities.intersect(["free","world"], ["free"])
      ["free"]
  """
  @spec intersect(String.t() | list(), String.t() | list()) :: list(String.t())
  def intersect(a, b) when is_binary(a) and is_binary(b) do
    intersect(String.graphemes(a), String.graphemes(b))
  end

  def intersect(a, b) when is_list(a) and is_list(b) do
    a -- a -- b
  end

  @doc """
  Determines if the value is considered present, which is non-empty for values that
  contain data like `[]`.
  """
  @spec present?(any()) :: boolean()
  def present?(nil), do: false
  def present?(false), do: false
  def present?(%{}), do: false
  def present?([]), do: false
  def present?(""), do: false
  def present?(0), do: false
  def present?({}), do: false
  def present?(_), do: true

  @doc """
  Takes a function that contains some amount of work then measures
  the time between work start and work finish. The return value is
  the number of seconds.
  """
  @spec measure((-> any())) :: {float(), any()}
  def measure(function) when is_function(function, 0) do
    {nsec, value} = :timer.tc(function)

    {nsec / 1_000_000.0, value}
  end

  def until(function) when is_function(function, 0), do: function.() || until(function)
end
