defmodule Core.Data.Background do
  @spec plan(Ecto.Changeset.t(Core.Gameplay.Character.t())) ::
          list({:forced, atom(), any()} | {:any_of, atom(), list(any()), integer()})
  def plan(%Ecto.Changeset{data: %Core.Gameplay.Character{levels: levels}, changes: %{background: %{data: %{slug: "folk-hero"}}}})
      when length(levels) == 0 do
    [
      {:forced, :skill_proficiencies, Core.Content.get_tag_by_slug("animal-handling")},
      {:forced, :skill_proficiencies, Core.Content.get_tag_by_slug("survival")},
      {:any_of, :tool_proficiencies, Enum.concat([Core.Gameplay.list_items_with_tags(["land-vehicles"]), Core.Gameplay.list_items_with_tags(["artisans"])]), 2}
    ]
  end

  def plan(%Ecto.Changeset{data: %Core.Gameplay.Character{}} = _character_changeset) do
    []
  end
end
