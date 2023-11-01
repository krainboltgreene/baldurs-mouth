defmodule Core.Theater.Scene do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "scenes" do
    field(:name, :string)
    field(:slug, :string)
    belongs_to(:campaign, Core.Content.Campaign)
    has_many(:lines, Core.Theater.Line)
    has_many(:dialogues, Core.Theater.Dialogue, foreign_key: :for_scene_id)
    many_to_many(:participants, Core.Gameplay.Character, join_through: "participants")
    many_to_many(:listeners, Core.Theater.NPC, join_through: "listeners")
  end

  @type t :: %__MODULE__{}

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preloaded_relationships =
      Core.Repo.preload(record, [
        :campaign
      ])

    record_with_preloaded_relationships
    |> Ecto.Changeset.cast(attributes, [:name])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.put_assoc(
      :listeners,
      attributes[:campaign] || record_with_preloaded_relationships.campaign
    )
    |> Ecto.Changeset.validate_required([:name, :slug])
    |> Ecto.Changeset.unique_constraint(:slug)
  end

  @doc false
  @spec add_listeners_changeset(struct, list(Core.Theater.NPC.t())) :: Ecto.Changeset.t(t())
  def add_listeners_changeset(record, listeners) do
    record_with_preloaded_relationships =
      Core.Repo.preload(record, [
        :listeners
      ])

    record_with_preloaded_relationships
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(
      :listeners,
      record_with_preloaded_relationships.listeners |> Enum.concat(listeners || [])
    )
  end

  @doc false
  @spec add_participants_changeset(struct, list(Core.Gameplay.Character.t())) ::
          Ecto.Changeset.t(t())
  def add_participants_changeset(record, participants) do
    record_with_preloaded_relationships =
      Core.Repo.preload(record, [
        :participants
      ])

    record_with_preloaded_relationships
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_assoc(
      :participants,
      record_with_preloaded_relationships.participants |> Enum.concat(participants || [])
    )
  end
end
