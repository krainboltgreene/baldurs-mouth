defmodule Core.Gameplay.Choices do
  @moduledoc false
  use Ecto.Schema

  defmodule SkillProficiency do
    defstruct [:name, :required]
  end

  embedded_schema do
    field(:features, {:array, :string}, default: [])
    field(:weapon_proficiencies, {:array, :string}, default: [])
    field(:armor_proficiencies, {:array, :string}, default: [])
    field(:skill_proficiencies, {:array, :string}, default: [])
    field(:skill_expertises, {:array, :string}, default: [])
    field(:tool_proficiencies, {:array, :string}, default: [])
    field(:tool_expertises, {:array, :string}, default: [])
    field(:cantrips, {:array, :string}, default: [])
    field(:languages, {:array, :string}, default: [])
  end

  @type t :: %__MODULE__{
          features: list(String.t()),
          weapon_proficiencies: list(String.t()),
          armor_proficiencies: list(String.t()),
          skill_proficiencies: list(String.t()),
          skill_expertises: list(String.t()),
          tool_proficiencies: list(String.t()),
          tool_expertises: list(String.t()),
          cantrips: list(String.t()),
          languages: list(String.t())
        }

  @type new_t :: %{
          optional(:features) => list(String.t()),
          optional(:weapon_proficiencies) => list(String.t()),
          optional(:armor_proficiencies) => list(String.t()),
          optional(:skill_proficiencies) => list(String.t()),
          optional(:skill_expertises) => list(String.t()),
          optional(:tool_proficiencies) => list(String.t()),
          optional(:tool_expertises) => list(String.t()),
          optional(:cantrips) => list(String.t()),
          optional(:languages) => list(String.t())
        }

  @doc false
  @spec changeset(struct(), new_t()) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [
      :features,
      :weapon_proficiencies,
      :armor_proficiencies,
      :skill_proficiencies,
      :skill_expertises,
      :tool_proficiencies,
      :tool_expertises,
      :cantrips,
      :languages
    ])
  end
end
