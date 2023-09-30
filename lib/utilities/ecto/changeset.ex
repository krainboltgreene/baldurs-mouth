defmodule Utilities.Ecto.Changeset do
  @moduledoc """
  Extra functionality relating to changesets
  """

  @spec put_all_relationships(Ecto.Changeset.t(), map()) ::
          Ecto.Changeset.t()
  def put_all_relationships(changeset, attributes),
    do: put_all_relationships(changeset, attributes, except: [])

  @spec put_all_relationships(Ecto.Changeset.t(), map(), Keyword.t(list(atom()))) ::
          Ecto.Changeset.t()
  def put_all_relationships(changeset, attributes, except: except) when is_list(except) do
    changeset
    |> put_all_associations(attributes, except: except)
    |> put_all_embeds(attributes, except: except)
  end

  @spec put_all_associations(Ecto.Changeset.t(), map()) ::
          Ecto.Changeset.t()
  def put_all_associations(changeset, attributes),
    do: put_all_associations(changeset, attributes, except: [])

  @spec put_all_associations(Ecto.Changeset.t(), map(), Keyword.t(list(atom()))) ::
          Ecto.Changeset.t()
  def put_all_associations(changeset, attributes, except: except) when is_list(except) do
    changeset.data.__struct__.__schema__(:associations)
    |> case do
      [] ->
        changeset

      associations ->
        associations
        |> Enum.reject(&Enum.member?(except, &1))
        |> Enum.map(&changeset.data.__struct__.__schema__(:association, &1))
        |> Enum.reduce(changeset, fn
          association, changeset
          when is_struct(association, Ecto.Association.HasThrough) or
                 is_struct(association, Ecto.Association.ManyToMany) ->
            changeset

          %Ecto.Association.BelongsTo{owner_key: owner_key, field: field}, changeset ->
            changeset
            |> Ecto.Changeset.change(%{
              owner_key =>
                association_with_fallback(field, attributes, changeset)
                |> Kernel.||(%{})
                |> Map.get(:id)
            })
            |> Ecto.Changeset.foreign_key_constraint(owner_key)
            |> Ecto.Changeset.assoc_constraint(field)

          %{field: field}, changeset ->
            Ecto.Changeset.put_assoc(
              changeset,
              field,
              association_with_fallback(field, attributes, changeset)
            )
        end)
    end
  end

  @spec put_all_embeds(Ecto.Changeset.t(), map()) ::
          Ecto.Changeset.t()
  def put_all_embeds(changeset, attributes), do: put_all_embeds(changeset, attributes, except: [])

  @spec put_all_embeds(Ecto.Changeset.t(), map(), Keyword.t(list(atom()))) ::
          Ecto.Changeset.t()
  def put_all_embeds(changeset, attributes, except: except) when is_list(except) do
    changeset.data.__struct__.__schema__(:embeds)
    |> case do
      [] ->
        changeset

      embeds ->
        embeds
        |> Enum.reject(&Enum.member?(except, &1))
        |> Enum.map(&changeset.data.__struct__.__schema__(:embed, &1))
        |> Enum.reduce(changeset, fn
          %Ecto.Embedded{field: field}, changeset ->
            Ecto.Changeset.put_embed(
              changeset,
              field,
              association_with_fallback(field, attributes, changeset)
            )
        end)
    end
  end

  defp association_with_fallback(field, attributes, %Ecto.Changeset{changes: changes, data: data}) do
    attributes[field] || Map.get(changes, field) || Map.get(data, field)
  end

  @spec default_embeds_one(Ecto.Changeset.t(), atom(), any()) :: Ecto.Changeset.t()
  def default_embeds_one(%{changes: changes, data: data} = changeset, key, value)
      when is_struct(changeset, Ecto.Changeset) and is_atom(key) do
    if Utilities.present?(Map.get(changes, key)) || Utilities.present?(Map.get(data, key)) do
      changeset
    else
      Ecto.Changeset.change(changeset, %{key => value})
    end
  end

  @spec put_assoc(Ecto.Changeset.t(), atom(), any(), maybe: true) :: Ecto.Changeset.t()
  def put_assoc(changeset, key, value, maybe: true) do
    if value do
      Ecto.Changeset.put_assoc(changeset, key, value, [])
    else
      changeset
    end
  end

  @spec terminal_error_formatting({:error, Ecto.Changeset.t()} | {:ok, any} | Ecto.Changeset.t()) ::
          :ok | String.t()
  def terminal_error_formatting({:ok, _}), do: :ok

  def terminal_error_formatting({:error, changeset}) when is_struct(changeset, Ecto.Changeset),
    do: terminal_error_formatting(changeset)

  def terminal_error_formatting(changeset) when is_struct(changeset, Ecto.Changeset) do
    changeset
    |> traverse_errors()
    |> format_mapping()
    |> prefix_error_with_struct(changeset)
    |> suffix_error_with_changeset(changeset)
  end

  defp traverse_errors(changeset) when is_struct(changeset, Ecto.Changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn
      {msg, opts} -> String.replace(msg, "%{count}", to_string(opts[:count]))
      msg -> msg
    end)
  end

  defp format_mapping(mapping) do
    mapping
    |> Enum.map(fn
      {field, validation_message} when is_binary(validation_message) ->
        "#{field} #{validation_message}"

      {field, subdetails} when is_map(subdetails) ->
        "#{field} #{format_mapping(subdetails)}"

      {field, list} when is_list(list) ->
        list |> Enum.map(fn detail -> "#{field} #{detail}" end) |> Utilities.List.to_sentence()
    end)
    |> Utilities.List.to_sentence()
  end

  defp prefix_error_with_struct(message, changeset) do
    "#{changeset.data.__struct__} had validation errors:\n\t\t#{message}"
  end

  defp suffix_error_with_changeset(message, changeset) do
    "#{message}\n\t#{changeset.changes |> inspect}"
  end
end
