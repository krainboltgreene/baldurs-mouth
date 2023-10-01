defmodule Utilities do
  @moduledoc """
  Generic behavior that we use elsewhere.
  """

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
