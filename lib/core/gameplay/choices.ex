defmodule Core.Gameplay.Choices do
  @moduledoc false
  use Ecto.Schema

  embedded_schema do
    field(:hitpoints, :integer, default: 0)
    field(:features, {:array, :string}, default: [])
    field(:skill_proficiencies, {:array, :string}, default: [])
    field(:tool_proficiencies, {:array, :string}, default: [])
    field(:weapon_proficiencies, {:array, :string}, default: [])
    field(:armor_proficiencies, {:array, :string}, default: [])
    field(:languages, {:array, :string}, default: [])
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct(), map()) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [
      :hitpoints,
      :features,
      :skill_proficiencies,
      :tool_proficiencies,
      :weapon_proficiencies,
      :armor_proficiencies,
      :languages
    ])
  end
end
