defmodule Core.Gameplay.Level do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "levels" do
    belongs_to(:character, Core.Gameplay.Character)
    belongs_to(:class, Core.Gameplay.Character)
    timestamps()
  end

  @type t :: %__MODULE__{
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
  end
end
