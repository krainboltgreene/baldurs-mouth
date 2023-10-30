defmodule Core.Gameplay.Class do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "classes" do
    field(:name, :string)
    field(:slug, :string)
    field(:saving_proficiencies, {:array, :string})
    field(:hit_dice, :integer)

    embeds_many :levels, Level do
      field(:features, {:array, :string})
      field(:optional_skills, {:array, :string})
      field(:skill_choices, :integer)
    end
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t(),
          saving_proficiencies: list(String.t()),
          hit_dice: integer()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:name, :saving_proficiencies, :hit_dice])
    |> Ecto.Changeset.cast_embed(:levels, required: true, with: &level_changeset/2)
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug])
    |> Ecto.Changeset.unique_constraint(:name)
    |> Ecto.Changeset.unique_constraint(:slug)
  end

  def level_changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:features, :optional_skills, :skill_choices])
  end
end
