defmodule Core.Data do
  @spec plan(
          Ecto.Changeset.t(Core.Gameplay.Character.t()),
          Core.Gameplay.Class.t(),
          integer()
        ) :: list({:forced, atom(), any()} | {:any_of, atom(), list(any()), integer()})
  def plan(%Ecto.Changeset{} = character_changeset, %Core.Gameplay.Class{slug: "fighter"}, position) do
    Core.Data.Fighter.plan(character_changeset, position)
  end

  def plan(%Ecto.Changeset{} = character_changeset, %Core.Gameplay.Class{slug: "paladin"}, position) do
    Core.Data.Paladin.plan(character_changeset, position)
  end

  def plan(%Ecto.Changeset{} = character_changeset, %Core.Gameplay.Class{slug: "bard"}, position) do
    Core.Data.Bard.plan(character_changeset, position)
  end

  def plan(%Ecto.Changeset{} = character_changeset, %Core.Gameplay.Class{slug: "wizard"}, position) do
    Core.Data.Wizard.plan(character_changeset, position)
  end

  @spec plan(
          Ecto.Changeset.t(Core.Gameplay.Character.t()),
          atom()
        ) :: list({:forced, atom(), any()} | {:any_of, atom(), list(any()), integer()})
  def plan(
        %Ecto.Changeset{} = character_changeset,
        :lineage
      ) do
    Core.Data.Lineage.plan(character_changeset)
  end

  def plan(
        %Ecto.Changeset{} = character_changeset,
        :background
      ) do
    Core.Data.Background.plan(character_changeset)
  end
end
