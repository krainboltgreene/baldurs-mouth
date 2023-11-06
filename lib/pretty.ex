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
  def get(%Core.Gameplay.Character{levels: levels}, :hitpoints) do
    levels
    |> Enum.map(&Map.get(&1, :hitpoints, 0))
    |> Enum.sum()
  end

  def get(%Core.Gameplay.Character{levels: levels}, :classes) do
    levels
    |> Core.Gameplay.last_level_in_classes()
    |> Enum.map(fn {class, level} -> "#{class.name} (#{level})" end)
    |> Utilities.List.to_sentence()
  end

  def get(%Core.Gameplay.Character{levels: levels}, :level) do
    Core.Gameplay.level(levels)
  end

  def get(%Core.Gameplay.Character{levels: levels}, :xp) do
    Core.Gameplay.xp(levels)
  end

  def get(%Core.Gameplay.Character{levels: levels}, :proficiency_bonus) do
    levels |> Core.Gameplay.proficiency_bonus() |> bonus_or_negative()
  end

  # TODO: Fill in with more logic like Durable
  def get(%Core.Gameplay.Character{constitution: constitution}, :hitpoints_modifier) do
    Core.Gameplay.ability_modifier(constitution) |> bonus_or_negative()
  end

  def get(%Core.Gameplay.Character{} = record, ability) when ability in @abilities do
    "#{Map.get(record, ability)} (#{record |> Map.get(ability) |> Core.Gameplay.ability_modifier() |> bonus_or_negative()})"
  end

  def get(record, keys) when is_list(keys),
    do: keys |> Enum.reduce(record, fn value, accumulated -> get(accumulated, value) end)

  def get(%{name: name}, :name) when is_binary(name), do: Utilities.String.titlecase(name)
  def get(record, key) when is_map_key(record, key), do: Map.get(record, key)

  defp bonus_or_negative(value) when value >= 1, do: "+#{value}"

  defp bonus_or_negative(value), do: "#{value}"
end
