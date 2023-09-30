defmodule Scaffolding.Write.Update do
  @moduledoc false
  defmacro __using__([schema, singular])
           when is_atom(singular) do
    quote location: :keep do
      @doc """
      Updates a given `#{unquote(schema)}`, applies the given `attributes` via
      `#{unquote(schema)}.unquote(update_changeset)/2`, and then updates the database.
      """
      @spec unquote(:"update_#{singular}")(unquote(schema).t(), map()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"update_#{singular}")(record, attributes)
          when is_struct(record, unquote(schema)) and is_map(attributes),
          do: record |> unquote(:"change_#{singular}")(attributes) |> Core.Repo.update()

      @doc """
      Updates a given `#{unquote(schema)}`, applies the given `attributes` via
      `#{unquote(schema)}.unquote(update_changeset)/2`, and then updates the database.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"update_#{singular}!")(unquote(schema).t(), map()) :: unquote(schema).t()
      def unquote(:"update_#{singular}!")(record, attributes)
          when is_struct(record, unquote(schema)) and is_map(attributes),
          do: record |> unquote(:"change_#{singular}")(attributes) |> Core.Repo.update!()
    end
  end
end
