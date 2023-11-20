defmodule Core.Gameplay.Class do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "classes" do
    field(:name, :string)
    field(:slug, :string)
    field(:description, :string)
    field(:saving_throw_proficiencies, {:array, :string})
    field(:hit_dice, :integer)
    field(:spellcasting_ability, Ecto.Enum, values: [:charisma, :wisdom, :intelligence])
  end

  @type t :: %__MODULE__{
          name: String.t(),
          slug: String.t(),
          saving_throw_proficiencies: list(String.t()),
          hit_dice: integer()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [
      :name,
      :description,
      :saving_throw_proficiencies,
      :spellcasting_ability,
      :hit_dice
    ])
    |> Slugy.slugify(:name)
    |> Ecto.Changeset.validate_required([:name, :slug, :saving_throw_proficiencies, :hit_dice, :description])
    |> Ecto.Changeset.unique_constraint(:slug)
  end
end
