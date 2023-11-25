defmodule Scaffolding.Read.Slug do
  @moduledoc false
  # credo:disable-for-next-line Credo.Check.Refactor.CyclomaticComplexity
  defmacro __using__([schema, singular])
           when is_atom(singular) do
    quote location: :keep do
      import Ecto.Query

      @doc """
      Returns a singular `#{unquote(schema)}` based on the slug column, but if it isn't found will raise an exception
      """
      @spec unquote(:"get_#{singular}_by_slug!")(String.t()) :: unquote(schema).t()
      def unquote(:"get_#{singular}_by_slug!")(name_or_slug) when is_binary(name_or_slug),
        do: unquote(schema) |> from(where: [slug: ^Slugy.slugify(name_or_slug)], limit: 1) |> Core.Repo.one!()

      @doc """
      Returns a singular `#{unquote(schema)}` based on the slug column and if no record is found it returns `nil`
      """
      @spec unquote(:"get_#{singular}_by_slug")(String.t()) :: unquote(schema).t() | nil
      def unquote(:"get_#{singular}_by_slug")(name_or_slug) when is_binary(name_or_slug),
        do: unquote(schema) |> from(where: [slug: ^Slugy.slugify(name_or_slug)], limit: 1) |> Core.Repo.one()
    end
  end
end
