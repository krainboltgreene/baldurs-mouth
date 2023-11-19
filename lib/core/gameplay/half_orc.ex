defmodule Core.Gameplay.HalfOrc do
  @spec preview(Core.Gameplay.Character.t()) :: Core.Gameplay.Level.options_t()
  def preview(%Core.Gameplay.Character{levels: levels}) when length(levels) == 0 do
    %{}
  end

  def preview(%Core.Gameplay.Character{levels: _levels}) do
    %{}
  end
end
