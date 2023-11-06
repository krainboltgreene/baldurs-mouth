defmodule Core.Gameplay.Bard do
  @spec preview(Core.Gameplay.Character.t(), integer()) :: Core.Gameplay.Level.options_t()
  def preview(_character, 1) do
    # weapon_proficiencies: [
    #   "hand-crossbows",
    #   "longswords",
    #   "rapiers",
    #   "shortswords",
    #   "simple-weapons"
    # ],
    # armor_proficiencies: ["light-armour"],
    # features: [
    #   "ritual-casting",
    #   "musical-spellcasting-focus",
    #   "bardic-inspiration"
    # ],
    # selectable_skills: [],
    # skill_choices: 3,
    # tool_choices: 3,
    # selectable_tools: ["musical"],
    # cantrip_choices: 2,
    # selectable_cantrips: [
    #   "vicious-mockery",
    #   "dancing-lights",
    #   "light",
    #   "mage-hand",
    #   "mending",
    #   "message",
    #   "minor-illusion",
    #   "prestidigitation",
    #   "true-strike"
    # ]
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
