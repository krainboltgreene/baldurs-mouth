defmodule Utilities.Ecto.Query do
  @moduledoc """
  Contains useful function for Ecto.Query
  """
  require Ecto.Query

  @doc """
  Takes a database table name or an `Ecto.Query` partial and either a singular field or many fields to map each returned record to. For example:

      from(Core.Users.Account) |> Core.Repo.pluck([:email_address, :name])

  Would return:

      [["kurtis@project.com", "Kurtis Rainbolt-Greene"], ["james@project.com", "James Ryan"]]
  """
  @spec pluck(atom | Ecto.Query.t(), atom | list(atom)) :: list(any)
  def pluck(model_or_query, field)
      when is_atom(model_or_query) or (is_struct(model_or_query) and is_atom(field)) do
    model_or_query
    |> Ecto.Query.select(^[field])
    |> Core.Repo.all()
    |> Utilities.List.pluck(field)
  end

  def pluck(model_or_query, fields)
      when is_atom(model_or_query) or (is_struct(model_or_query) and is_list(fields)) do
    model_or_query
    |> Ecto.Query.select(^fields)
    |> Core.Repo.all()
    |> Enum.map(fn record -> Map.values(Map.take(record, fields)) end)
  end
end
