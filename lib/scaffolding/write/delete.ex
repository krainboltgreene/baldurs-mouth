defmodule Scaffolding.Write.Delete do
  @moduledoc false
  defmacro __using__([schema, singular])
           when is_atom(singular) do
    quote location: :keep do
      @doc """
      Takes an existing `#{unquote(schema)}` and deletes it from the database.
      """
      @spec unquote(:"delete_#{singular}")(unquote(schema).t()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"delete_#{singular}")(record) when is_struct(record, unquote(schema)),
        do: record |> Core.Repo.delete()

      @doc """
      Takes an existing `#{unquote(schema)}` and deletes it from the database.

      If the row can't be found or constraints prevent you from deleting the row, this will raise an exception.
      """
      @spec unquote(:"delete_#{singular}!")(unquote(schema).t()) :: unquote(schema).t()
      def unquote(:"delete_#{singular}!")(record) when is_struct(record, unquote(schema)),
        do: record |> Core.Repo.delete!()
    end
  end
end
