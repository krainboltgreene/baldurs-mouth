defmodule Core.Theater do
  use Scaffolding, [Core.Theater.Scene, :scenes, :scene]
  use Scaffolding, [Core.Theater.Line, :lines, :line]
  use Scaffolding, [Core.Theater.NPC, :npcs, :npc]
  use Scaffolding, [Core.Theater.Dialogue, :dialogues, :dialogue]
  use Scaffolding.Read.Slug, [Core.Theater.NPC, :npc]
  use Scaffolding.Read.Slug, [Core.Theater.Scene, :scene]

  @spec play(Core.Content.Campaign.t(), list(Core.Gameplay.Character.t())) ::
          Core.Theater.Scene.t()
  def play(%Core.Content.Campaign{} = campaign, characters) when is_list(characters) do
    {:ok, save} =
      Core.Content.create_save(%{
        last_scene: Core.Repo.preload(campaign, [:opening_scene]).opening_scene,
        characters: characters
      })

    save.last_scene
    |> Core.Repo.preload(lines: [:speaker_npc], dialogues: [:next_scene])
    |> tap(fn %{lines: lines} ->
      lines
      |> Enum.map(&read/1)
      |> Enum.each(&IO.puts/1)
    end)
    |> tap(fn _ ->
      IO.puts("")
    end)
    |> tap(fn %{dialogues: dialogues} ->
      dialogues
      |> Enum.with_index(1)
      |> Enum.map(&prompt/1)
      |> Enum.each(&IO.puts/1)
    end)
  end

  @spec read(Core.Theater.Line.t()) :: String.t()
  def read(%Core.Theater.Line{speaker_npc: %Core.Theater.NPC{slug: "narrator"}, body: body})
      when is_binary(body) do
    "#{body}\n"
  end

  def read(%Core.Theater.Line{speaker_npc: %Core.Theater.NPC{name: name}, body: body})
      when is_binary(body) do
    "#{name}: \"#{body}\"\n"
  end

  @spec prompt({Core.Theater.Dialogue.t(), integer()}) :: String.t()
  def prompt({%Core.Theater.Dialogue{body: body, next_scene: nil}, index}) do
    "#{index}. \"#{body}\" [Leave]"
  end

  def prompt({%Core.Theater.Dialogue{body: body}, index}) do
    "#{index}. \"#{body}\""
  end
end
