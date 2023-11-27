defmodule Core.Theater.Scene do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "scenes" do
    field(:name, :string)
    field(:slug, :string)
    field(:opening, :boolean, default: false)
    belongs_to(:campaign, Core.Content.Campaign)
    has_many(:lines, Core.Theater.Line)
    has_many(:dialogues, Core.Theater.Dialogue, foreign_key: :for_scene_id)
    has_many(:saves, Core.Content.Save, foreign_key: :last_scene_id)
    has_many(:speakers, through: [:lines, :speaker_npc])
    many_to_many(:listeners, Core.Theater.NPC, join_through: "listeners")
  end

  @type t :: %__MODULE__{
    name: String.t(),
    slug: String.t(),
    opening: boolean()
  }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preloaded_relationships =
      Core.Repo.preload(record, [
        :campaign
      ])

    record_with_preloaded_relationships
    |> Ecto.Changeset.cast(attributes, [:name, :opening])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.put_assoc(
      :campaign,
      attributes[:campaign] || record_with_preloaded_relationships.campaign
    )
    |> Ecto.Changeset.validate_required([:name, :slug, :campaign])
    |> Ecto.Changeset.unique_constraint(:slug)
    |> Ecto.Changeset.unique_constraint([:opening, :campaign_id])
    |> Ecto.Changeset.foreign_key_constraint(:campaign_id)
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
end
