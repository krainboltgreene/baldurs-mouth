defmodule Utilities.Tuple do
  @moduledoc """
  Behavior relating to tuples
  """

  @spec right({any, value}) :: value when value: any
  def right({_, value}) do
    value
  end

  @spec left({value, any}) :: value when value: any
  def left({value, _}) do
    value
  end
end
