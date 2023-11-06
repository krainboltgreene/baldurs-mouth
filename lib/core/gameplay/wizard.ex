defmodule Core.Gameplay.Wizard do
  # https://5thsrd.org/character/classes/wizard/
  @spec preview(Core.Gameplay.Character.t(), integer()) :: Core.Gameplay.Level.options_t()
  def preview(_character, 1) do
    %{}
  end

  def preview(_character, 2) do
    %{}
  end

  def preview(_character, 3) do
    %{}
  end

  def preview(_character, _position) do
    %{}
  end
end
