defmodule Core.Data.Lineage do
  @spec plan(Core.Gameplay.Character.t()) ::
          list(Core.Data.forced_t() | Core.Data.any_of_t())
  def plan(%Core.Gameplay.Character{levels: levels, lineage: %{slug: "half-orc"}})
      when length(levels) == 0 do
    [
      %Core.Data.Forced{name: :animal_handling, type: :skill_proficiencies},
      %Core.Data.Forced{name: :survival, type: :skill_proficiencies},
      %Core.Data.AnyOf{
        names: [:vehicle_land, :artisan_tool],
        type: :tool_proficiencies,
        count: 2
      }
    ]
  end

  def plan(%Core.Gameplay.Character{}) do
    []
  end
end
