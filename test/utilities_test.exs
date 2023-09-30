defmodule UtilitiesTest do
  use ExUnit.Case, async: true
  doctest Utilities

  test "to_sentence()" do
    assert Utilities.List.to_sentence(["a", "b", "c"]) == "a, b, and c"
  end

  test "titlecase(with small words)" do
    assert Utilities.String.titlecase("a walk in the park") == "A Walk in the Park"
  end

  test "titlecase(with a small word as the first world)" do
    assert Utilities.String.titlecase("are Wolves Here") == "Are Wolves Here"
  end

  test "titlecase(with a hyphenated word)" do
    assert Utilities.String.titlecase("What wrought-iron?") == "What Wrought-Iron?"
  end

  test "titlecase(with an apostrophied word)" do
    assert Utilities.String.titlecase("jed'ai") == "Jed'Ai"
  end
end
