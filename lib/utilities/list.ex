defmodule Utilities.List do
  @moduledoc """
  Extra functionality relating to lists
  """

  @spec find_header(list({key, value}), key, default) :: value | default
        when key: String.t(), value: String.t(), default: any
  def find_header(headers, key, default \\ nil) when is_list(headers) and is_binary(key) do
    headers
    |> Enum.find(default, fn {header, _value} -> header == key end)
    |> then(fn {header, _value} -> header end)
  end

  # Pick a better name
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

  @spec pluck(list(map()), any() | list(any)) :: list(any())
  def pluck(maps, key)
      when (is_list(maps) and is_atom(key)) or is_binary(key) or is_integer(key) do
    Enum.map(maps, &Map.get(&1, key))
  end

  def pluck(maps, path) when is_list(maps) and is_list(path) do
    Enum.map(maps, &Utilities.Map.dig(&1, path))
  end

  @spec delete_all(list(), list()) :: list()
  def delete_all(all, picked) do
    all
    |> Enum.reduce([], fn item, remaining_items ->
      if Enum.member?(picked, item) do
        remaining_items
      else
        [item | remaining_items]
      end
    end)
  end

  @spec to_sentence(list(String.t()), String.t() | nil) :: String.t()
  def to_sentence(list, combinator \\ "and")
  def to_sentence([], _), do: ""

  def to_sentence(list, combinator) when is_list(list) and is_binary(combinator) do
    [butt | body] = list |> Enum.reverse()

    cond do
      length(body) < 1 -> butt
      length(body) == 1 -> "#{body} #{combinator} #{butt}"
      length(body) > 1 -> "#{body |> Enum.reverse() |> Enum.join(", ")}, #{combinator} #{butt}"
    end
  end

  @doc """
  This function takes a list of weighted values, buckets them
  based on the Alias Method algorithms, and efficiently picks
  a random value from the list.

  This implements Walker's Alias Method, an algorithms
  for taking a list of weighted options: apples (40%),
  oranges (10%), banans (50%) and randomly picking
  a result.
  """
  @spec random(list({any(), float() | integer()})) :: any()
  def random(options_and_their_weights) when is_list(options_and_their_weights) do
    {options, weights} = Utilities.List.split(options_and_their_weights)
    sum_of_weights = Enum.sum(weights)

    if sum_of_weights == 0 do
      nil
    else
      size = length(weights)

      probabilities = weights |> Enum.map(&(&1 * size / sum_of_weights))
      short = probabilities |> index_and_filter(&(&1 <= 1.0))
      long = probabilities |> index_and_filter(&(&1 > 1.0)) |> Enum.reverse()

      probability_table = probabilities |> to_index_map
      alias_table = Enum.to_list(0..(size - 1)) |> Enum.map(&{&1, 0}) |> Map.new()

      {probability_table, alias_table} = r_gen_tables(short, long, probability_table, alias_table)

      element = Enum.random(0..(size - 1))

      choice =
        if :rand.uniform() <= Map.fetch!(probability_table, element) do
          element
        else
          Map.fetch!(alias_table, element)
        end

      Enum.at(options, choice)
    end
  end

  defp r_gen_tables(short, long, probability_table, alias_table) when short == [] or long == [],
    do: {probability_table, alias_table}

  defp r_gen_tables(short, long, probability_table, alias_table) do
    {remaining_short, [last_short]} = snip(short, -1)
    [first_long | remaining_long] = long
    alias_table = Map.put(alias_table, last_short, first_long)

    probability_table =
      Map.update(
        probability_table,
        first_long,
        0,
        &(&1 - (1 - Map.fetch!(probability_table, last_short)))
      )

    if Map.fetch!(probability_table, first_long) < 1 do
      r_gen_tables(
        append(remaining_short, first_long),
        remaining_long,
        probability_table,
        alias_table
      )
    else
      r_gen_tables(remaining_short, long, probability_table, alias_table)
    end
  end

  @spec index_and_filter(list(), function()) :: list(integer())
  def index_and_filter(list, function) when is_list(list) and is_function(function, 1),
    do:
      list
      |> Enum.with_index()
      |> Enum.filter(fn {element, _index} -> function.(element) end)
      |> Enum.map(&elem(&1, 1))

  @spec snip(list(), integer()) :: {list(), any()}
  def snip(list, position) when is_list(list) and is_integer(position),
    do: {Enum.drop(list, position), Enum.take(list, position)}

  @spec append(list(), any) :: list()
  def append(list, element) when is_list(list), do: Enum.concat(list, [element])

  @spec to_index_map(list()) :: map()
  def to_index_map(list) when is_list(list),
    do: list |> Enum.with_index() |> Map.new(fn {v, i} -> {i, v} end)
end
