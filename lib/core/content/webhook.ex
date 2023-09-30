defmodule Core.Content.Webhook do
  @moduledoc false
  use Ecto.Schema

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "webhooks" do
    field(:provider, :string)
    field(:headers, :map)
    field(:payload, :map)
  end

  @type t :: %__MODULE__{
          provider: String.t()
        }

  @doc false
  @spec changeset(struct, map) :: Ecto.Changeset.t(t())
  def changeset(record, attributes) do
    record
    |> Ecto.Changeset.cast(attributes, [:provider, :headers, :payload])
    |> Ecto.Changeset.validate_required([:provider, :headers, :payload])
  end
end
