defmodule Core.Data.Wizard do
  # https://5thsrd.org/character/classes/wizard/
  @spec plan(Core.Gameplay.Character.t(), integer()) ::
          list(Core.Data.forced_t() | Core.Data.any_of_t())
  def plan(_character, 1) do
    []
  end

  def plan(_character, 2) do
    []
  end

  def plan(_character, 3) do
    []
  end

  def plan(_character, _position) do
    []
  end
end
