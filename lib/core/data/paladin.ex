defmodule Core.Data.Paladin do
  # https://5thsrd.org/character/classes/paladin/
  @spec plan(Ecto.Changeset.t(Core.Gameplay.Character.t()), integer()) ::
          list({:forced, atom(), any()} | {:any_of, atom(), list(any()), integer()})
  def plan(%Ecto.Changeset{data: %Core.Gameplay.Character{}} = _character_changeset, 1) do
    []
  end

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
#           []
#         ]
