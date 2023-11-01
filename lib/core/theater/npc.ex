defmodule Core.Theater.NPC do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "npcs" do
    field(:name, :string)
    field(:slug, :string)
    field(:known, :boolean, default: false)
    many_to_many(:scenes, Core.Theater.Scene, join_through: "listeners")
    has_many(:lines, Core.Theater.Line, foreign_key: :speaker_npc_id)
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:name, :known])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug])
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
