defmodule CoreWeb.PlayLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(
        _params,
        _session,
        %{assigns: %{live_action: :start, current_account: current_account}} = socket
      ) do
    socket
    |> assign(:page_title, "Select a campaign")
    |> assign(
      :account,
      current_account
      |> Core.Repo.preload(
        saves: [
          campaign: [],
          characters: [
            background: [],
            lineage: [:lineage_category],
            levels: [class: []]
          ]
        ],
      )
    )
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
  end

  def mount(%{"id" => scene_slug}, _session, %{assigns: %{live_action: :show}} = socket) do
    scene = Core.Theater.get_scene_by_slug(scene_slug)

    socket
    |> assign(:scene, scene)
    |> assign(:page_title, scene.name)
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("play", %{id: save_id}, socket) do
    socket
    |> assign(:save, Core.Content.get_save(save_id))
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :start} = assigns) do
    ~H"""
    <ul role="list" class="divide-y divide-gray-100">
      <li :for={save <- @account.saves} class="flex items-center justify-between gap-x-6 py-5">
        <div class="min-w-0">
          <div class="flex items-start gap-x-3">
            <p class="text-sm font-semibold leading-6 text-gray-900"><%= Pretty.get(save.campaign, :name) %></p>
            <p :if={save.playing_state == :playing} class="rounded-md whitespace-nowrap mt-0.5 px-1.5 py-0.5 text-xs font-medium ring-1 ring-inset text-gray-600 bg-gray-50 ring-gray-500/10">
              <%= Pretty.get(save, :playing_state) %>
            </p>
            <p :if={save.playing_state == :completed} class="rounded-md whitespace-nowrap mt-0.5 px-1.5 py-0.5 text-xs font-medium ring-1 ring-inset text-green-700 bg-green-50 ring-green-600/20">
              <%= Pretty.get(save, :playing_state) %>
            </p>
            <p :if={save.playing_state == :archived} class="rounded-md whitespace-nowrap mt-0.5 px-1.5 py-0.5 text-xs font-medium ring-1 ring-inset text-yellow-800 bg-yellow-50 ring-yellow-600/20">
              <%= Pretty.get(save, :playing_state) %>
            </p>
          </div>
          <div class="mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500">
            <p class="whitespace-nowrap">Last played <.timestamp_in_words_ago at={save.updated_at} /></p>
            <svg viewBox="0 0 2 2" class="h-0.5 w-0.5 fill-current">
              <circle cx="1" cy="1" r="1" />
            </svg>
            <p class="truncate"><%= save.characters |> Enum.map(&Pretty.get(&1, :name)) |> Utilities.List.to_sentence() %></p>
          </div> 
        </div>
        <div class="flex flex-none items-center gap-x-4">
          <.button usable_icon="play" phx-click="play" phx-value-id={save.id}>Play<span class="sr-only">, <%= Pretty.get(save.campaign, :name) %></span></.button>
          <.button usable_icon="box">Archive<span class="sr-only">, <%= Pretty.get(save.campaign, :name) %></span></.button>
        </div>
      </li>
    </ul>
    """
  end
end
