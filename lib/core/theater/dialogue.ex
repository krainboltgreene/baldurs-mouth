defmodule Core.Theater.Dialogue do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "dialogues" do
    field(:body, :string, default: "")
    embeds_one(:challenge, Core.Gameplay.Challenge)
    belongs_to(:for_scene, Core.Theater.Scene)
    belongs_to(:next_scene, Core.Theater.Scene)
    belongs_to(:failure_scene, Core.Theater.Scene)
    belongs_to(:speaker_character, Core.Gameplay.Character)
  end

  @type t :: %__MODULE__{
          body: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preloaded_relationships =
      Core.Repo.preload(record, [
        :for_scene,
        :next_scene,
        :failure_scene
      ])

    record_with_preloaded_relationships
    |> Ecto.Changeset.cast(attributes, [:body])
    |> Ecto.Changeset.cast_embed(:challenge)
    |> Ecto.Changeset.put_assoc(
      :for_scene,
      attributes[:for_scene] || record_with_preloaded_relationships.for_scene
    )
    |> Ecto.Changeset.put_assoc(
      :next_scene,
      attributes[:next_scene] || record_with_preloaded_relationships.next_scene
    )
    |> Ecto.Changeset.put_assoc(
      :failure_scene,
      attributes[:failure_scene] || record_with_preloaded_relationships.failure_scene
    )
    |> Ecto.Changeset.validate_required([:body])
  end
end
