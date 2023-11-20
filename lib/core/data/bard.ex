defmodule Core.Data.Bard do
  @spec plan(Core.Gameplay.Character.t(), integer()) ::
          list(Core.Data.forced_t() | Core.Data.any_of_t())
  def plan(_character, 1) do
    [
      %Core.Data.Forced{name: :hand_crossbows, type: :weapon_proficiencies},
      %Core.Data.Forced{name: :longswords, type: :weapon_proficiencies},
      %Core.Data.Forced{name: :rapiers, type: :weapon_proficiencies},
      %Core.Data.Forced{name: :shortswords, type: :weapon_proficiencies},
      %Core.Data.Forced{name: :simple_weapons, type: :weapon_proficiencies},
      %Core.Data.Forced{name: :light, type: :armor_proficiencies},
      %Core.Data.Forced{name: :ritual_casting, type: :features},
      %Core.Data.Forced{name: :musical_spellcasting_focus, type: :features},
      %Core.Data.Forced{name: :bardic_inspiration, type: :features},
      %Core.Data.AnyOf{
        names: [
          :vicious_mockery,
          :dancing_lights,
          :light,
          :mage_hand,
          :mending,
          :message,
          :minor_illusion,
          :prestidigitation,
          :true_strike
        ],
        type: :cantrips,
        count: 2
      },
      %Core.Data.AnyOf{
        names: Core.Gameplay.skills(),
        type: :skill_proficiencies,
        count: 3
      },
      %Core.Data.AnyOf{names: [:musical], type: :tool_proficiencies, count: 3}
    ]
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
