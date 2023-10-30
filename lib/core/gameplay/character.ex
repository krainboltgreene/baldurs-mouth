defmodule Core.Gameplay.Character do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "characters" do
    field(:name, :string)
    field(:slug, :string)
    field(:hitpoints, :integer, default: 0)
    field(:strength, :integer, default: 8)
    field(:dexterity, :integer, default: 8)
    field(:constitution, :integer, default: 8)
    field(:intelligence, :integer, default: 8)
    field(:wisdom, :integer, default: 8)
    field(:charisma, :integer, default: 8)
    timestamps()
    belongs_to(:background, Core.Gameplay.Background)
    belongs_to(:lineage, Core.Gameplay.Lineage)
    belongs_to(:account, Core.Users.Account)
    has_many(:levels, Core.Gameplay.Level)
    has_many(:inventories, Core.Gameplay.Inventory)
    has_many(:items, through: [:inventories, :item])

    embeds_one(:pronouns, Pronoun) do
      field(:normative, :string)
      field(:accusative, :string)
      field(:genitive, :string)
      field(:reflexive, :string)
    end
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:name, :strength, :dexterity, :constitution, :intelligence, :wisdom, :charisma])
    |> Ecto.Changeset.cast_embed(:pronouns, required: true, with: &pronouns_changeset/2)
    |> Ecto.Changeset.put_assoc(:account, attributes[:account] || Core.Repo.preload(record, :account).account)
    |> Ecto.Changeset.put_assoc(:lineage, attributes[:lineage] || Core.Repo.preload(record, :lineage).lineage)
    |> Ecto.Changeset.put_assoc(:background, attributes[:background] || Core.Repo.preload(record, :background).background)
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug])
    |> Ecto.Changeset.unique_constraint(:name)
    |> Ecto.Changeset.unique_constraint(:slug)
  end

  @spec changeset(struct(), map()) :: Ecto.Changeset.t(t())
  def pronouns_changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:normative, :accusative, :genitive, :reflexive])
    |> Ecto.Changeset.validate_required([:normative, :accusative, :genitive, :reflexive])
  end
end
