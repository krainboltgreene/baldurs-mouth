defmodule Scaffolding do
  @moduledoc false
  defmacro __using__([schema, plural, singular]) do
    quote location: :keep do
      use Scaffolding.Read, [unquote(schema), unquote(plural), unquote(singular)]
      use Scaffolding.Write, [unquote(schema), unquote(singular), :changeset, :changeset]
    end
  end
end
