defmodule CoreTest do
  use ExUnit.Case, async: true
  doctest Core

  test "multiple(..., [{1, 10}, {2, 40}, {3, 50}])" do
    result = Utilities.Enum.multiple([{1, 10}, {2, 40}, {3, 50}], fn -> :example end)
    assert result |> Enum.all?(fn item -> item == :example end)
  end

  test "multiple(..., 5, 5)" do
    result = Utilities.Enum.multiple(5, 5, fn -> :example end)
    assert length(result) === 5
    assert result |> Enum.all?(fn item -> item == :example end)
  end

  test "multiple(..., 1, 5)" do
    result = Utilities.Enum.multiple(1, 5, fn -> :example end)
    assert 1..5 |> Enum.member?(length(result))
    assert result |> Enum.all?(fn item -> item == :example end)
  end

  test "multiple_unique(1, 5, ...)" do
    result = Utilities.Enum.multiple_unique(1, 5, fn -> Enum.random(1..5) end)
    assert 1..5 |> Enum.member?(length(result))
    assert result |> Enum.all?(fn item -> Enum.member?(1..5, item) end)
  end

  test "multiple_unique(5, 5, ...)" do
    result = Utilities.Enum.multiple_unique(5, 5, fn -> Enum.random(1..5) end)
    assert 1..5 |> Enum.member?(length(result))
    assert result |> Enum.sort() == [1, 2, 3, 4, 5]
  end
end
