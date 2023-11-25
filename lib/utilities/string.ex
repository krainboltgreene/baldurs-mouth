defmodule Utilities.String do
  @moduledoc """
  Extra functionality relating to strings
  """

  @race_to_collective_mapping %{
    "human" => "human",
    "elf" => "elven",
    "dwarf" => "dwarven",
    "goblin" => "goblin",
    "orc" => "orcish",
    "gnome" => "gnomen",
    "halfling" => "halfling",
    "dragonborn" => "dragonborn",
    "hobgoblin" => "hobgoblin",
    "kobold" => "kobold"
  }


  @doc """
  Generate a random string
  """
  @spec random() :: String.t()
  def random() do
    :crypto.strong_rand_bytes(32) |> Base.encode64(padding: false) |> binary_part(0, 32)
  end

  def as_slug(text) do
    text |> String.replace(~r/\s/, "_")
  end

  def titlecase(input) do
    input
    |> String.capitalize()
    |> String.split()
    |> Enum.map_join(" ", fn string ->
      cond do
        String.match?(string, ~r/^(and|the|with|in|is|a|an|of|or)$/) ->
          string

        String.match?(string, ~r/-/) ->
          string |> String.split("-") |> Enum.map_join("-", &String.capitalize/1)

        String.match?(string, ~r/'\w{2,}/) ->
          string |> String.split("'") |> Enum.map_join("'", &String.capitalize/1)

        true ->
          string |> String.capitalize()
      end
    end)
  end
end
