defmodule Utilities.Enum do
  @moduledoc """
  Houses a bunch of enumerable based functionality
  """

  @spec split(list(tuple())) :: {list(), list()}
  def split(list) when is_list(list) do
    list
    |> Enum.reduce({[], []}, fn {left, right}, {lefts, rights} ->
      {
        List.insert_at(lefts, -1, left),
        List.insert_at(rights, -1, right)
      }
    end)
  end

  @spec times(pos_integer(), function()) :: any()
  def times(0, _), do: []
  def times(1, function) when is_function(function, 0), do: [function.()]

  def times(amount, function)
      when is_integer(amount) and amount >= 1 and is_function(function, 0) do
    1..amount
    |> Enum.map(fn _ -> function.() end)
  end

  @doc """
  Randomly creates a list of (the return type of the first argument), where the list size is based on a list of chance:

      multiple(fn -> some_randomization end, [{1, 10}, {2, 40}, {3, 50}])

  This will return `list(any)` where the size is 10% likely to be `[any]`, 40% likely to be `[any, any]`, and 50% likely to be `[any, any, any]`.

  All chance values (the second value of the tuples) should *sum* to either 10, 100, or 1000, to give you precise chance.

  You have to have more than one {value, chance} tuple.
  """
  @spec multiple(list(tuple()), (-> any())) :: list()
  def multiple(range_with_chance, function)
      when is_function(function, 0) and
             is_list(range_with_chance) and length(range_with_chance) > 1 do
    range_with_chance
    |> Enum.flat_map(fn
      {value, chance} when is_integer(value) and is_integer(chance) and chance >= 1 ->
        List.duplicate(value, chance)
    end)
    |> Enum.random()
    |> Utilities.Enum.times(function)
  end

  @doc """
  Executes a function a random number of times between minimum and maximum times and returns each return value in a list.
  """
  @spec multiple(pos_integer, pos_integer, (-> any())) :: list()
  def multiple(minimum, maximum, function)
      when is_function(function, 0) and is_integer(minimum) and is_integer(maximum) and
             minimum <= maximum and minimum > 0 do
    minimum..maximum
    |> Enum.random()
    |> Utilities.Enum.times(function)
  end

  @doc """
  Executes a function a random number of times between minimum and maximum times and returns each return value in a list.

  If the executed function returns a non-unique value it will be run until it does.

  WARNING: The executed function *must* generate a random value. Something like below will generate an infinite loop:

      Utilities.Enum.multiple_unique(1, 2, fn -> 1 end)

  WARNING: The executed function's possible permutations *must* exceed the maximum possible size of the list, for example:

      Utilities.Enum.multiple_unique(1, 10, fn -> Enum.random(1..3) end)

  Will result in an infinite loop.
  """
  @spec multiple_unique(pos_integer, pos_integer, (-> any)) :: list(any())
  def multiple_unique(minimum, maximum, function)
      when is_function(function, 0) and is_integer(minimum) and is_integer(maximum) and
             minimum <= maximum and minimum > 0 do
    minimum..maximum
    |> Enum.random()
    |> then(fn maximum -> 1..maximum end)
    |> Enum.reduce([], &until_correct(function, &1, &2))
  end

  defp until_correct(function, _, list) when is_list(list) do
    value = function.()

    if Enum.member?(list, value) do
      until_correct(function, nil, list)
    else
      [value | list]
    end
  end
end
