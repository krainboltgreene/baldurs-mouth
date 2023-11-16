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

  @spec migrate_lazy(map(), Map.key(), Map.key(), (Map.value() -> Map.value())) :: map()
  def migrate_lazy(mapping, old_key, new_key, function) when is_map(mapping) and is_function(function, 1) do
    if Map.has_key?(mapping, old_key) do
      mapping |> Map.put(new_key, function.(Map.get(mapping, old_key))) |> Map.delete(old_key)
    else
      mapping
    end
  end
end
