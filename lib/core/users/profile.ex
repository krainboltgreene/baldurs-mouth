defmodule Core.Users.Profile do
  @moduledoc false
  use Ecto.Schema

  embedded_schema do
    field(:public_name, :string)
  end

  @type t :: %__MODULE__{
          public_name: String.t() | nil
        }

  @spec changeset(struct, map) ::
          Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:public_name])
  end
end
