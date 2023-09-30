defmodule Scaffolding.Write.Change do
  @moduledoc false
  defmacro __using__([schema, singular, create_changeset, update_changeset])
           when is_atom(singular) do
    quote location: :keep do
      @doc """
      Takes an empty `#{unquote(schema)}` and applies `attributes` to it via `#{unquote(schema)}.#{unquote(create_changeset)}/2`
      """
      @spec unquote(:"new_#{singular}")(struct(), map()) ::
              Ecto.Changeset.t(unquote(schema).t())
      def unquote(:"new_#{singular}")(record, attributes)
          when is_struct(record, unquote(schema)) and is_map(attributes),
          do: unquote(schema).unquote(create_changeset)(record, attributes)

      @doc """
      Takes an existing `#{unquote(schema)}` and applies `attributes` to it via `#{unquote(schema)}.#{unquote(update_changeset)}/2`.
      """
      @spec unquote(:"change_#{singular}")(unquote(schema).t(), map()) ::
              Ecto.Changeset.t(unquote(schema).t())
      def unquote(:"change_#{singular}")(record, attributes)
          when is_struct(record, unquote(schema)) and is_map(attributes),
          do: unquote(schema).unquote(update_changeset)(record, attributes)
    end
  end
end
