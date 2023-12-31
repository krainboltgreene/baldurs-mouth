defmodule Core.Theater do
  use EctoInterface, [Core.Theater.Scene, :scenes, :scene]
  use EctoInterface, [Core.Theater.Line, :lines, :line]
  use EctoInterface, [Core.Theater.NPC, :npcs, :npc]
  use EctoInterface, [Core.Theater.Dialogue, :dialogues, :dialogue]
  use EctoInterface.Read.Slug, [Core.Theater.NPC, :npc]
  use EctoInterface.Read.Slug, [Core.Theater.Scene, :scene]

  @spec add_line_to!(Core.Theater.Scene.t(), String.t(), Core.Theater.NPC.t()) ::
          Core.Theater.Line.t()
  def add_line_to!(%Core.Theater.Scene{} = scene, body, %Core.Theater.NPC{} = speaker_npc) do
    create_line!(%{
      scene: scene,
      body: body,
      speaker_npc: speaker_npc
    })
  end

  @spec add_line_to!(
          Core.Theater.Scene.t(),
          String.t(),
          Core.Theater.NPC.t(),
          Core.Gameplay.Challenge.t()
        ) :: Core.Theater.Line.t()
  def add_line_to!(
        %Core.Theater.Scene{} = scene,
        body,
        %Core.Theater.NPC{} = speaker_npc,
        %{} = challenge
      ) do
    create_line!(%{
      scene: scene,
      body: body,
      speaker_npc: speaker_npc,
      challenge: challenge
    })
  end

  @spec add_dialogue_to!(Core.Theater.Scene.t(), String.t()) ::
          Core.Theater.Dialogue.t()
  def add_dialogue_to!(%Core.Theater.Scene{} = for_scene, body) do
    create_dialogue!(%{
      for_scene: for_scene,
      body: body
    })
  end

  @spec add_dialogue_to!(Core.Theater.Scene.t(), String.t(), Core.Theater.Scene.t()) ::
          Core.Theater.Dialogue.t()
  def add_dialogue_to!(
        %Core.Theater.Scene{} = for_scene,
        body,
        %Core.Theater.Scene{} = next_scene
      ) do
    create_dialogue!(%{
      for_scene: for_scene,
      body: body,
      next_scene: next_scene
    })
  end

  @spec add_dialogue_to!(
          Core.Theater.Scene.t(),
          String.t(),
          Core.Theater.Scene.t(),
          Core.Gameplay.Challenge.t()
        ) :: Core.Theater.Dialogue.t()
  def add_dialogue_to!(
        %Core.Theater.Scene{} = for_scene,
        body,
        %Core.Theater.Scene{} = next_scene,
        %{} = challenge
      ) do
    create_dialogue!(%{
      for_scene: for_scene,
      body: body,
      next_scene: next_scene,
      challenge: challenge
    })
  end

  @spec add_dialogue_to!(
          Core.Theater.Scene.t(),
          String.t(),
          Core.Theater.Scene.t(),
          Core.Gameplay.Challenge.t(),
          Core.Theater.Scene.t()
        ) :: Core.Theater.Dialogue.t()
  def add_dialogue_to!(
        %Core.Theater.Scene{} = for_scene,
        body,
        %Core.Theater.Scene{} = next_scene,
        %{} = challenge,
        %Core.Theater.Scene{} = failure_scene
      ) do
    create_dialogue!(%{
      for_scene: for_scene,
      body: body,
      next_scene: next_scene,
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
