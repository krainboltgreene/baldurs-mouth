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

  @spec get(map(), list(atom()) | atom()) :: String.t()
  def get(%Core.Gameplay.Character{hitpoints: hitpoints, levels: levels}, :hitpoints) do
    levels
    |> Enum.map(&Map.get(&1, :choices))
    |> Enum.map(&Map.get(&1, :hitpoints, 0))
    |> Enum.sum()
    |> Kernel.+(hitpoints)
  end

  def get(%Core.Gameplay.Character{levels: levels}, :classes) do
    levels
    |> Utilities.List.pluck(:class)
    |> Utilities.List.pluck(:name)
    |> Enum.uniq()
    |> Utilities.List.to_sentence()
  end

  def get(%Core.Gameplay.Character{levels: levels}, :level) do
    Core.Gameplay.level(levels)
  end


  def get(%Core.Gameplay.Character{levels: levels}, :xp) do
    Core.Gameplay.xp(levels)
  end

  def get(%Core.Gameplay.Character{levels: levels}, :proficiency) do
    Core.Gameplay.proficiency(levels)
  end

  # TODO: Fill in with more logic like Durable
  def get(%Core.Gameplay.Character{constitution: constitution}, :hitpoints_modifier) do
    Core.Gameplay.ability_modifier(constitution)
  end

  def get(%Core.Gameplay.Character{} = record, ability) when ability in @abilities do
    "#{Map.get(record, ability)} (#{Core.Gameplay.ability_modifier(Map.get(record, ability))})"
  end

  def get(record, keys) when is_list(keys),
    do: keys |> Enum.reduce(record, fn value, accumulated -> get(accumulated, value) end)

  def get(%{name: name}, :name) when is_binary(name), do: Utilities.String.titlecase(name)
  def get(record, key) when is_map_key(record, key), do: Map.get(record, key)
end
