defmodule Utilities.Ecto do
  @moduledoc """
  Contains useful function for Ecto
  """

  @doc """
  Wraps a papertrail result so that our existing infrastructure isn't changed
  """
  @spec with_version({:ok, %{model: struct(), version: struct()}} | {:error, Ecto.Changeset.t()}) ::
          {:ok, struct()} | {:error, Ecto.Changeset.t()}
  def with_version({:ok, %{model: model, version: _version}}), do: {:ok, model}
  def with_version({:error, _changeset} = result), do: result
end
