defmodule Core.Gameplay.Challenge do
  @moduledoc false
  use Ecto.Schema

  embedded_schema do
    field(:type, Ecto.Enum, values: [:optional, :required])
    field(:track, :string)
    field(:state, :string)
    field(:tag, :string)
    field(:skill, :string)
    field(:ability, :string)
    field(:target, :integer)
  end

  @type t :: %__MODULE__{
          type: String.t()
        }

  @doc false
  @spec changeset(struct(), map()) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [
      :type,
      :track,
      :state,
      :tag,
      :skill,
      :ability,
      :target
    ])
    |> Ecto.Changeset.validate_required(:type)
  end
end
