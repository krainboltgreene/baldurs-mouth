defmodule Scaffolding.Write do
  @moduledoc false
  defmacro __using__([schema, singular, create_changeset, update_changeset])
           when is_atom(singular) do
    quote location: :keep do
      use Scaffolding.Write.Create, [unquote(schema), unquote(singular)]
      use Scaffolding.Write.Update, [unquote(schema), unquote(singular)]
      use Scaffolding.Write.Delete, [unquote(schema), unquote(singular)]

      use Scaffolding.Write.Change, [
        unquote(schema),
        unquote(singular),
        unquote(create_changeset),
        unquote(update_changeset)
      ]
    end
  end
end
