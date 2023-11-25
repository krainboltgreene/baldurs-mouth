defmodule Core.Data.Lineage do
  @spec plan(Ecto.Changeset.t(Core.Gameplay.Character.t())) ::
          list({:forced, atom(), any()} | {:any_of, atom(), list(any()), integer()})
  def plan(%Ecto.Changeset{data: %Core.Gameplay.Character{levels: levels}, changes: %{lineage: %{data: %{slug: "half-orc"}}}})
      when length(levels) == 0 do
    [
      {:forced, :features, Core.Content.get_tag_by_slug("mark-of-gruumsh")},
      {:forced, :features, Core.Content.get_tag_by_slug("scarred-and-strong")},
      {:forced, :features, Core.Content.get_tag_by_slug("relentless-endurance")},
      {:forced, :features, Core.Content.get_tag_by_slug("menacing")},
      {:forced, :features, Core.Content.get_tag_by_slug("savage-attack")},
      {:forced, :features, Core.Content.get_tag_by_slug("darkvision")}
    ]
  end

  def plan(%Ecto.Changeset{data: %Core.Gameplay.Character{}} = _character_changeset) do
    []
  end
end
