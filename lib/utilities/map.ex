defmodule Utilities.Map do
  @moduledoc """
  Extra functionality relating to maps
  """
  def dig(nested_map, path) when is_map(nested_map) and is_list(path) do
    Enum.reduce(path, &Map.get(&2, &1))
  end

  @spec atomize_keys(map()) :: map()
  def atomize_keys(map) when is_map(map) do
    map
    |> Map.new(fn
      {key, value} when is_binary(key) -> {String.to_atom(key), value}
      {key, value} when is_atom(key) -> {key, value}
    end)
  end

  @spec stringify_keys(map()) :: map()
  def stringify_keys(map) when is_map(map) do
    map
    |> Map.new(fn
      {key, value} when is_atom(key) -> {Atom.to_string(key), value}
      {key, value} when is_binary(key) -> {key, value}
    end)
  end
end
