defmodule CoreWeb.SceneLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(
        _params,
        _session,
        %{assigns: %{current_account: %Core.Users.Account{username: username}}}
      )
      when username != "krainboltgreene",
      do: raise(CoreWeb.Exceptions.NotFoundException)

  def mount(_params, _session, %{transport_pid: nil} = socket),
    do:
      socket
      |> assign(:page_title, "Loading...")
      |> assign(:page_loading, true)
      |> (&{:ok, &1}).()

  def mount(%{"id" => scene_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    scene =
      Core.Theater.get_scene(scene_id)
      |> Core.Repo.preload(
        campaign: [],
        dialogues: [:next_scene, :failure_scene],
        lines: [:speaker_npc]
      )

    socket
    |> assign(:scene, scene)
    |> assign(:page_title, scene.name)
    |> assign(:page_subtitle, "Scene")
    |> (&{:ok, &1}).()
  end

  def mount(
        %{"campaign_id" => campaign_id},
        _session,
        %{
          assigns: %{live_action: :new}
        } = socket
      ) do
    campaign =
      Core.Content.get_campaign(campaign_id)
      |> Core.Repo.preload([
        opening_scene: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]],
        saves: [last_scene: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]]],
        scenes: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]],
        speakers: [],
        listeners: []
      ])

    socket
    |> assign(:campaign, campaign)
    |> (&{:ok, &1}).()
  end

  @impl true
  @spec handle_params(map(), String.t(), map()) :: {:noreply, map()}
  def handle_params(_params, _url, %{transport_pid: nil} = socket),
    do:
      socket
      |> assign(:page_title, "Loading...")
      |> assign(:page_loading, true)
      |> (&{:noreply, &1}).()

  def handle_params(
        _params,
        _url,
        %{assigns: %{live_action: :new, campaign: campaign}} = socket
      ) do
    socket
    |> assign(
      :scene_form,
      %Core.Theater.Scene{}
      |> Core.Repo.preload([dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc], speakers: [], listeners: []])
      |> Core.Theater.new_scene(%{
        campaign: campaign
      })
      |> to_form()
    )
    |> assign(:page_title, "New Scene")
    |> assign(:page_subtitle, campaign.name)
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "validate",
        %{"scene" => scene_params},
        %{assigns: %{campaign: campaign}} = socket
      ) do
    socket
    |> assign(
      :scene_form,
      %Core.Theater.Scene{}
      |> Core.Repo.preload([dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc], speakers: [], listeners: []])
      |> Core.Theater.change_scene(from_form(
        scene_params
        |> Map.merge(%{
          campaign: campaign
        })
      ))
      |> Map.put(:action, :validate)
      |> then(fn changeset -> to_form(changeset, check_errors: !changeset.valid?) end)
    )
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "save",
        %{"scene" => scene_params},
        %{assigns: %{campaign: campaign}} = socket
      ) do
    scene_params
    |> from_form()
    |> Map.merge(%{
          campaign: campaign
        })
    |> Core.Theater.create_scene()
    |> case do
      {:ok, scene} ->
        socket
        |> put_flash(:info, "Saved!")
        |> push_navigate(to: ~p"/scenes/#{scene.id}")
    end
    |> (&{:noreply, &1}).()
  end

  # @impl true
  # def handle_event(
  #       "...",
  #       %{},
  #       %{assigns: %{...}} = socket
  #     ) do
  #   socket
  #   |> (&{:noreply, &1}).()
  # end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any()) => any()}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{page_loading: true} = assigns) do
    ~H"""
    Loading...
    """
  end

  def render(%{live_action: :new} = assigns) do
    ~H"""
    <.simple_form for={@scene_form} phx-change="validate" phx-submit="save">
      <.input field={@scene_form[:name]} label="Name" type="text" required />
      <:actions>
        <.button phx-disable-with="Saving..." type="submit" usable_icon="save">Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <.link navigate={~p"/lines/new?scene_id=#{@scene.id}"}>New Line</.link>
    <.link navigate={~p"/dialogues/new?scene_id=#{@scene.id}"}>New Dialogue</.link>
    <.link navigate={~p"/scenes/#{@scene.id}/edit"}>Edit Scene</.link>
    <.list>
      <:item title="Campaign">
        <.link navigate={~p"/campaigns/#{@scene.campaign.id}"}><%= Pretty.get(@scene.campaign, :name) %></.link>
      </:item>
      <:item title="Lines">
        <div class="prose">
          <ul>
            <li :for={line <- @scene.lines}>
              <.link navigate={~p"/npcs/#{line.speaker_npc.id}"}><%= Pretty.get(line.speaker_npc, :name) %></.link>: "<.link navigate={~p"/lines/#{line.id}"}><%= Pretty.get(line, :body) %></.link>"
            </li>
          </ul>
        </div>
      </:item>
      <:item title="Dialogues">
        <div class="prose">
          <ul>
            <li :for={dialogue <- @scene.dialogues}>
              "<.link navigate={~p"/dialogues/#{dialogue.id}"}><%= Pretty.get(dialogue, :body) %></.link>"
            </li>
          </ul>
        </div>
      </:item>
    </.list>
    """
  end

  defp from_form(params) when is_map(params) do
    params
    |> Utilities.Map.migrate_lazy("next_scene", :next_scene, fn
      "" ->
        nil

      next_scene_id ->
        Core.Theater.get_scene(next_scene_id)
    end)
    |> Utilities.Map.migrate_lazy("failure_scene", :failure_scene, fn
      "" ->
        nil

      failure_scene_id ->
        Core.Theater.get_scene(failure_scene_id)
    end)
    |> Utilities.Map.atomize_keys()
  end
end
