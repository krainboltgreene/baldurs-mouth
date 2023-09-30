defmodule Scaffolding.Write.Create do
  @moduledoc false
  defmacro __using__([schema, singular])
           when is_atom(singular) do
    quote location: :keep do
      @doc """
      Creates a blank `#{unquote(schema)}`, applies the given `attributes` via
      `#{unquote(schema)}.unquote(create_changeset)/2`, and then inserts it into the database.

      This function will raise an exception if any validation issues are encountered.
      """
      @spec unquote(:"create_#{singular}!")(map()) :: unquote(schema).t()
      def unquote(:"create_#{singular}!")(attributes \\ %{}) when is_map(attributes),
        do: %unquote(schema){} |> unquote(:"new_#{singular}")(attributes) |> Core.Repo.insert!()

      @doc """
      Creates a blank `#{unquote(schema)}`, applies the given `attributes` via
      `#{unquote(schema)}.unquote(create_changeset)/2` and then inserts it into the database.
      """
      @spec unquote(:"create_#{singular}")(map()) ::
              {:ok, unquote(schema).t()} | {:error, Ecto.Changeset.t(unquote(schema).t())}
      def unquote(:"create_#{singular}")(attributes \\ %{}) when is_map(attributes),
        do: %unquote(schema){} |> unquote(:"new_#{singular}")(attributes) |> Core.Repo.insert()
    end
  end
end
