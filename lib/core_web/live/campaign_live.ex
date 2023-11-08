defmodule CoreWeb.CampaignLive do
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

  def mount(
        _params,
        _session,
        %{
          assigns: %{live_action: :list}
        } = socket
      ) do
    campaigns =
      Core.Content.list_campaigns()
      |> Core.Repo.preload(
        saves: [],
        scenes: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]]
      )

    socket
    |> assign(:campaigns, campaigns)
    |> assign(:page_title, "List of Campaigns")
    |> (&{:ok, &1}).()
  end

  def mount(%{"id" => campaign_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    campaign =
      Core.Content.get_campaign(campaign_id)
      |> Core.Repo.preload(
        saves: [],
        scenes: [dialogues: [:next_scene, :failure_scene], lines: [:speaker_npc]]
      )

    socket
    |> assign(:campaign, campaign)
    |> assign(:page_title, campaign.name)
    |> (&{:ok, &1}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "build-graph",
        _params,
        %{assigns: %{campaign: campaign}} = socket
      ) do
    socket
    |> push_event("draw", %{})
    |> (&{:noreply, &1}).()
  end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any()) => any()}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{page_loading: true} = assigns) do
    ~H"""
    Loading...
    """
  end

  def render(%{live_action: :list} = assigns) do
    ~H"""
    <ul>
      <li :for={campaign <- @campaigns}><.link navigate={~p"/campaigns/#{campaign.id}"}><%= campaign.name %></.link></li>
    </ul>
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <div id="campaign-chart" class="w-full h-80" phx-hook="CampaignGraph"></div>
    <p>
      Saves: <%= length(@campaign.saves) %>
    </p>
    Scenes:
    <ul>
      <li :for={scene <- @campaign.scenes}><.link navigate={~p"/scenes/#{scene.id}"}><%= scene.name %></.link></li>
    </ul>
    """
  end
end
