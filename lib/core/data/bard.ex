defmodule Core.Data.Bard do
  @spec plan(Ecto.Changeset.t(Core.Gameplay.Character.t()), integer()) ::
          list({:forced, atom(), any()} | {:any_of, atom(), list(any()), integer()})
  def plan(%Ecto.Changeset{data: %Core.Gameplay.Character{}} = _character_changeset, 1) do
    [
      # {:forced, :weapon_proficiencies, :hand_crossbows},
      # {:forced, :weapon_proficiencies, :longswords},
      # {:forced, :weapon_proficiencies, :rapiers},
      # {:forced, :weapon_proficiencies, :shortswords},
      # {:forced, :weapon_proficiencies, :simple_weapons},
      # {:forced, :armor_proficiencies, :light},
      {:forced, :features, Core.Gameplay.get_feature_by_slug("ritual-casting")},
      {:forced, :features, Core.Gameplay.get_feature_by_slug("musical-spellcasting-focus")},
      {:forced, :features, Core.Gameplay.get_feature_by_slug("bardic-inspiration")},
      # {:any_of, :cantrips, Core.Gameplay.list_spells_with_tags(["bard", "cantrip"]), 2},
      # {:any_of, :skill_proficiencies, Core.Gameplay.list_skills(), 3},
      # {:any_of, :tool_proficiencies, Core.Gameplay.list_tools_with_tags(["musical"]), 3},
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
