defmodule Core.Gameplay.Tiefling do
  @spec preview(Core.Gameplay.Character.t()) :: Core.Gameplay.Level.options_t()
  def preview(%Core.Gameplay.Character{levels: levels}) when length(levels) == 1 do
    %{}
  end

  def preview(%Core.Gameplay.Character{levels: _levels}) do
    %{}
  end
end
