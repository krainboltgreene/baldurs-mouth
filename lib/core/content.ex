defmodule Core.Content do
  @moduledoc """
  Behavior for interacting with user generated content
  """
  require Logger
  require EEx

  EEx.function_from_file(:defp, :sheet, "priv/templates/sheet.eex", [:character])

  def print_character_sheet(%Core.Gameplay.Character{} = character) do
    character
    |> Core.Repo.preload(
      levels: [:class],
      lineage: [:lineage_category],
      background: [],
      account: [],
      items: []
    )
    |> sheet()
  end
end
