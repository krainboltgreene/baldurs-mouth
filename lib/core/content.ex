defmodule Core.Content do
  @moduledoc """
  Behavior for interacting with user generated content
  """
  require Logger
  require EEx

  use Scaffolding, [Core.Content.Campaign, :campaigns, :campaign]
  use Scaffolding.Read.Slug, [Core.Content.Campaign, :campaign]
  use Scaffolding, [Core.Content.Save, :saves, :save]
  use Scaffolding, [Core.Content.Tag, :tags, :tag]
  use Scaffolding.Read.Slug, [Core.Content.Tag, :tag]

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
