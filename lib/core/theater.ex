defmodule Core.Theater do
  use Scaffolding, [Core.Theater.Scene, :scenes, :scene]
  use Scaffolding, [Core.Theater.Line, :lines, :line]
  use Scaffolding, [Core.Theater.NPC, :npcs, :npc]
  use Scaffolding, [Core.Theater.Dialogue, :dialogues, :dialogue]
  use Scaffolding.Read.Slug, [Core.Theater.NPC, :npc]
  use Scaffolding.Read.Slug, [Core.Theater.Scene, :scene]

  @spec add_line_to(Core.Theater.Scene.t(), String.t(), Core.Theater.NPC.t()) :: {:error, Ecto.Changeset.t()} | {:ok, Core.Theater.Line.t()}
  def add_line_to(for_scene, body, speaker) do
    create_line(%{
      for_scene: for_scene,
      body: body,
      speaker: speaker
    })
  end

  @spec add_line_to(Core.Theater.Scene.t(), String.t(), Core.Theater.NPC.t(), Core.Gameplay.Challenge.t()) :: {:error, Ecto.Changeset.t()} | {:ok, Core.Theater.Line.t()}
  def add_line_to(for_scene, body, speaker, challenge) do
    create_line(%{
      for_scene: for_scene,
      body: body,
      speaker: speaker,
      challenge: challenge
    })
  end

  @spec add_dialogue_to(Core.Theater.Scene.t(), String.t()) :: {:error, Ecto.Changeset.t()} | {:ok, Core.Theater.Dialogue.t()}
  def add_dialogue_to(for_scene, body) do
    create_dialogue(%{
      for_scene: for_scene,
      body: body
    })
  end

  @spec add_dialogue_to(Core.Theater.Scene.t(), String.t(), Core.Theater.Scene.t()) :: {:error, Ecto.Changeset.t()} | {:ok, Core.Theater.Dialogue.t()}
  def add_dialogue_to(for_scene, body, to_scene) do
    create_dialogue(%{
      for_scene: for_scene,
      body: body,
      to_scene: to_scene
    })
  end

  @spec add_dialogue_to(Core.Theater.Scene.t(), String.t(), Core.Theater.Scene.t(), Core.Gameplay.Challenge.t()) :: {:error, Ecto.Changeset.t()} | {:ok, Core.Theater.Dialogue.t()}
  def add_dialogue_to(for_scene, body, to_scene, challenge) do
    create_dialogue(%{
      for_scene: for_scene,
      body: body,
      to_scene: to_scene,
      challenge: challenge
    })
  end

  @spec add_dialogue_to(Core.Theater.Scene.t(), String.t(), Core.Theater.Scene.t(), Core.Gameplay.Challenge.t(), Core.Theater.Scene.t()) :: {:error, Ecto.Changeset.t()} | {:ok, Core.Theater.Dialogue.t()}
  def add_dialogue_to(for_scene, body, to_scene, challenge, failure_scene) do
    create_dialogue(%{
      for_scene: for_scene,
      body: body,
      to_scene: to_scene,
      challenge: challenge,
      failure_scene: failure_scene
    })
  end

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
