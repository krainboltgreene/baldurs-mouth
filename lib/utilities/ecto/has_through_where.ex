defmodule Utilities.Ecto.HasThroughWhere do
  @moduledoc """
  Allows for complex many to many or one to one relationships that have conditions
  """

  @doc """
  This creates two underlying relationships: a has_one to the join schema and a has_one through that join

  For example:

      has_one_through(:nobody, :nobody_adventure_person, :person, Core.Universes.AdventurePerson,
        where: [role: "nobody"]
      )
  """
  @spec has_one_through(atom(), atom(), atom(), any(), Keyword.t(map())) :: any()
  defmacro has_one_through(association, join_relationship, end_relationship, join_table_module,
             where: where
           ) do
    quote do
      has_one(
        unquote(join_relationship),
        unquote(join_table_module),
        where: unquote(where),
        on_replace: :delete
      )

      has_one(unquote(association),
        through: [unquote(join_relationship), unquote(end_relationship)]
      )
    end
  end

  @spec has_many_through(atom(), atom(), atom(), any(), Keyword.t(map())) :: any()
  defmacro has_many_through(association, join_relationship, end_relationship, join_table_module,
             where: where
           ) do
    quote do
      has_many(
        unquote(join_relationship),
        unquote(join_table_module),
        where: unquote(where)
      )

      has_many(unquote(association),
        through: [unquote(join_relationship), unquote(end_relationship)]
      )
    end
  end

  @spec put_assoc(
          Ecto.Changeset.t(),
          list(struct()) | struct(),
          atom(),
          atom(),
          atom(),
          Keyword.t(map())
        ) ::
          Ecto.Changeset.t()

  def put_assoc(changeset, nil, _, _, _, _), do: changeset

  def put_assoc(changeset, record_or_records, association, join_relationship, end_relationship,
        where: where
      ) do
    changeset
    |> Ecto.Changeset.put_assoc(
      join_relationship,
      case changeset.data.__struct__.__schema__(:association, association) do
        %Ecto.Association.HasThrough{cardinality: :many} ->
          record_or_records
          |> Enum.map(fn associated -> Map.put(where, end_relationship, associated) end)
          |> Enum.concat(Map.get(changeset.data, join_relationship))

        %Ecto.Association.HasThrough{cardinality: :one} ->
          Map.put(where, end_relationship, record_or_records)
      end
    )
  end
end
