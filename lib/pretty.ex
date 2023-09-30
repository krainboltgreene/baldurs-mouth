defmodule Pretty do
  @moduledoc """
  Decorating getters for display.
  """

  @spec get(struct() | map(), atom() | list(atom())) :: any()

  def get(record, keys) when is_list(keys),
    do: keys |> Enum.reduce(record, fn value, accumulated -> get(accumulated, value) end)
  def get(%{name: name}, :name) when is_binary(name), do: Utilities.String.titlecase(name)
  def get(%{prompt: prompt}, :prompt), do: Utilities.String.titlecase(prompt)
  def get(record, :prompt), do: Core.Prompt.for(record)
  def get(record, key) when is_map_key(record, key), do: Map.get(record, key)
end
