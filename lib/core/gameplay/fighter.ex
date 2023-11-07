defmodule Core.Gameplay.Fighter do
  # https://5thsrd.org/character/classes/fighter/
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

# Armor: All armor, shields
# Weapons: Simple weapons, martial weapons
# Tools: None
# Saving Throws: Wisdom, Charisma
# ,
#         levels: [
#           %{
#             weapon_proficiencies: ["simple-weapons", "martial-weapons"],
#             armor_proficiencies: ["light-armour", "medium-armour", "heavy-armour", "shield"],
#             features: [
#               "fighting-style",
#               "second-wind"
#             ],
#             selectable_skills: [
#               "acrobatics",
#               "animal-handling",
#               "athletics",
#               "history",
#               "insight",
#               "intimidation",
#               "perception",
#               "survival"
#             ],
#             skill_choices: 2
#           },
#           %{
#             features: ["action-surge"]
#           },
#           %{}
#         ]
