defmodule Core.Data.Bard do
  @spec plan(Ecto.Changeset.t(Core.Gameplay.Character.t()), integer()) ::
          list({:forced, atom(), any()} | {:any_of, atom(), list(any()), integer()})
  def plan(%Ecto.Changeset{data: %Core.Gameplay.Character{}} = _character_changeset, 1) do
    [
      {:forced, :weapon_proficiencies, Core.Content.get_tag_by_slug("hand-crossbows")},
      {:forced, :weapon_proficiencies, Core.Content.get_tag_by_slug("longswords")},
      {:forced, :weapon_proficiencies, Core.Content.get_tag_by_slug("rapiers")},
      {:forced, :weapon_proficiencies, Core.Content.get_tag_by_slug("shortswords")},
      {:forced, :weapon_proficiencies, Core.Content.get_tag_by_slug("simple-weapons")},
      {:forced, :armor_proficiencies, Core.Content.get_tag_by_slug("light")},
      {:forced, :features, Core.Content.get_tag_by_slug("ritual-casting")},
      {:forced, :features, Core.Content.get_tag_by_slug("musical-spellcasting-focus")},
      {:forced, :features, Core.Content.get_tag_by_slug("bardic-inspiration")},
      # {:any_of, :cantrips, Core.Content.list_spells_with_tags(["bard", "cantrip"]), 2},
      # {:any_of, :skill_proficiencies, Core.Gameplay.skills(), 3},
      # {:any_of, :tool_proficiencies, Core.Content.list_items_with_tags(["musical"]), 3},
    ]
  end

  # [
  #         :vicious_mockery,
  #         :dancing_lights,
  #         :light,
  #         :mage_hand,
  #         :mending,
  #         :message,
  #         :minor_illusion,
  #         :prestidigitation,
  #         :true_strike
  #       ]

  def plan(%Ecto.Changeset{data: %Core.Gameplay.Character{}} = _character_changeset, 2) do
    []
  end

  def plan(%Ecto.Changeset{data: %Core.Gameplay.Character{}} = _character_changeset, 3) do
    []
  end

  def plan(%Ecto.Changeset{data: %Core.Gameplay.Character{}} = _character_changeset, _position) do
    []
  end
end
