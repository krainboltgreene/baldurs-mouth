defmodule Pretty do
  @moduledoc """
  Decorating getters for display.
  """

  @abilities [
    :strength,
    :dexterity,
    :constitution,
    :intelligence,
    :wisdom,
    :charisma
  ]

  @spec get(struct() | map(), atom() | list(atom()), atom()) :: String.t()
  def get(%Core.Gameplay.Character{name: name}, :name, :sheet) do
    name |> String.pad_trailing(41, " ")
  end

  def get(%Core.Gameplay.Character{hitpoints: hitpoints, levels: levels}, :hitpoints, :sheet) do
    levels
    |> Enum.map(&Map.get(&1, :choices))
    |> Enum.map(&Map.get(&1, :hitpoints, 0))
    |> Enum.sum()
    |> Kernel.+(hitpoints)
    |> dbg()
    |> Integer.to_string()
    |> String.pad_trailing(26, " ")
  end

  def get(%Core.Gameplay.Character{lineage: %{name: name}}, :lineage, :sheet) do
    name |> String.pad_trailing(38, " ")
  end

  def get(%Core.Gameplay.Character{levels: levels}, :classes, :sheet) do
    levels
    |> Utilities.List.pluck(:class)
    |> Utilities.List.pluck(:name)
    |> Enum.uniq()
    |> Utilities.List.to_sentence()
    |> String.pad_trailing(40, " ")
  end

  def get(%Core.Gameplay.Character{background: %{name: name}}, :background, :sheet) do
    name |> String.pad_trailing(35, " ")
  end

  def get(%Core.Gameplay.Character{levels: levels}, :level_and_xp, :sheet) do
    "#{Core.Gameplay.level(levels)} & #{Core.Gameplay.xp(levels)}xp" |> String.pad_trailing(35, " ")
  end

  def get(%Core.Gameplay.Character{levels: levels}, :proficiency, :sheet) do
    Core.Gameplay.proficiency(levels)
  end

  def get(%Core.Gameplay.Character{constitution: constitution}, :hitpoints_modifier, :sheet) do
    Core.Gameplay.ability_modifier(constitution) |> Integer.to_string() |> String.pad_trailing(25, " ")
  end

  def get(%Core.Gameplay.Character{} = record, ability, :sheet) when ability in @abilities do
    "#{Map.get(record, ability)} (#{Core.Gameplay.ability_modifier(Map.get(record, ability))})" |> String.pad_trailing(7, " ")
  end

  def get(record, :name, _context), do: get(record, :name)
  def get(record, key, _context) when is_map_key(record, key), do: get(record, key)

  @spec get(map(), list(atom()) | atom()) :: String.t()
  def get(record, keys) when is_list(keys),
    do: keys |> Enum.reduce(record, fn value, accumulated -> get(accumulated, value) end)

  def get(%{name: name}, :name) when is_binary(name), do: Utilities.String.titlecase(name)
  def get(record, key) when is_map_key(record, key), do: Map.get(record, key)
end
