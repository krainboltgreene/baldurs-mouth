defmodule Core.Theater.Line do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "lines" do
    field(:body, :string, default: "")
    embeds_one(:challenge, Core.Gameplay.Challenge)
    belongs_to(:scene, Core.Theater.Scene)
    belongs_to(:speaker_npc, Core.Theater.NPC)
  end

  @type t :: %__MODULE__{
          body: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preloaded_relationships =
      Core.Repo.preload(record, [
        :speaker_npc,
        :scene
      ])

    record_with_preloaded_relationships
    |> Ecto.Changeset.cast(attributes, [:body])
    |> Ecto.Changeset.cast_embed(:challenge)
    |> Ecto.Changeset.put_assoc(
      :scene,
      attributes[:scene] || record_with_preloaded_relationships.scene
    )
    |> Ecto.Changeset.put_assoc(
      :speaker_npc,
      attributes[:speaker_npc] || record_with_preloaded_relationships.speaker_npc
    )
    |> Ecto.Changeset.validate_required([:body, :scene, :speaker_npc])
  end
end
