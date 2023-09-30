defmodule Core.Users.Settings do
  @moduledoc false
  use Ecto.Schema

  embedded_schema do
    field(:light_mode, :boolean, default: true)
  end

  @type t :: %__MODULE__{
          light_mode: boolean
        }

  @spec changeset(struct, map) ::
          Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:light_mode])
  end
end
