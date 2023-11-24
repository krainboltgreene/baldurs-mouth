defmodule Core.Data.Wizard do
  # https://5thsrd.org/character/classes/wizard/
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
