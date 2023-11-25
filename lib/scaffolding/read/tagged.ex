defmodule Scaffolding.Read.Tagged do
  @moduledoc false
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__([schema, plural])
           when is_atom(plural) do
    quote location: :keep do
      import Ecto.Query
      import Utilities.Ecto.Query

      @doc """
      Returns all `#{unquote(schema)}` records that have *all* of the given tags
      """
      @spec unquote(:"list_#{plural}_with_tags")(list(String.t())) ::
              list(unquote(schema))
      def unquote(:"list_#{plural}_with_tags")([]),
        do: []
      def unquote(:"list_#{plural}_with_tags")(tags),
        do: from(record in unquote(schema), join: tag in assoc(record, :tags), having: array_contains(array_agg(tag.slug), ^tags), group_by: record.id) |> Core.Repo.all()
    end
  end
end
