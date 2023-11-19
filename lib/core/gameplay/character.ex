defmodule Core.Gameplay.Character do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "characters" do
    field(:name, :string)
    field(:slug, :string)

    embeds_one(:pronouns, Pronoun) do
      field(:normative, :string)
      field(:accusative, :string)
      field(:genitive, :string)
      field(:reflexive, :string)
    end

    belongs_to(:background, Core.Gameplay.Background)
    belongs_to(:lineage, Core.Gameplay.Lineage)
    belongs_to(:account, Core.Users.Account)
    has_many(:levels, Core.Gameplay.Level)
    has_many(:inventories, Core.Gameplay.Inventory)
    has_many(:items, through: [:inventories, :item])
    has_many(:dialogues, Core.Theater.Dialogue, foreign_key: :speaker_character_id)
    many_to_many(:saves, Core.Content.Save, join_through: "parties")
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record_with_preloaded_relationships =
      Core.Repo.preload(record, [
        :account
      ])

    record_with_preloaded_relationships
    |> Ecto.Changeset.cast(
      attributes,
      [
        :name
      ]
    )
    |> Ecto.Changeset.cast_embed(:pronouns, required: true, with: &pronouns_changeset/2)
    |> Ecto.Changeset.put_assoc(
      :account,
      attributes[:account] || record_with_preloaded_relationships.account
    )
    |> Ecto.Changeset.put_assoc(
      :lineage,
      attributes[:lineage] || record_with_preloaded_relationships.lineage
    )
    |> Ecto.Changeset.put_assoc(
      :background,
      attributes[:background] || record_with_preloaded_relationships.background
    )
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug])
    |> Ecto.Changeset.unique_constraint(:slug)
  end

  @spec pronouns_changeset(struct(), map()) :: Ecto.Changeset.t(t())
  def pronouns_changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:normative, :accusative, :genitive, :reflexive])
    |> Ecto.Changeset.validate_required([:normative, :accusative, :genitive, :reflexive])
  end
end
