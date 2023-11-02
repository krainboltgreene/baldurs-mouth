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

  def mount(%{"id" => save_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    save = Core.Content.get_save(save_id)
    |> Core.Repo.preload([
      campaign: [],
      last_scene: [
        lines: [:speaker_npc],
        dialogues: [:next_scene]
      ],
      characters: [
        background: [],
        lineage: [:lineage_category],
        levels: [class: []]
      ]
    ])

    socket
    |> assign(:save, save)
    |> assign(:page_title, "#{save.campaign.name} - #{save.last_scene.name}")
    |> (&{:ok, &1, layout: {CoreWeb.Layouts, :empty}}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("play", %{"id" => save_id}, socket) do
    socket
    |> push_navigate(to: ~p"/play/#{save_id}")
    |> (&{:noreply, &1}).()
  end

  @impl true
  def render(%{live_action: :start} = assigns) do
    ~H"""
    <div class="mx-auto max-w-2xl px-4 py-12">
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
              <p class="truncate"><%= save.characters |> Enum.map(&Pretty.get(&1, :name)) |> Utilities.List.to_sentence() %></p>
              <svg viewBox="0 0 2 2" class="h-0.5 w-0.5 fill-current">
                <circle cx="1" cy="1" r="1" />
              </svg>
              <p class="truncate"><%= Pretty.get(save.last_scene, :name) %></p>
            </div>
            <div class="mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500">
              <p class="whitespace-nowrap">Last played <.timestamp_in_words_ago at={save.updated_at} /></p>
            </div>
          </div>
          <div class="flex flex-none items-center gap-x-4">
            <.button usable_icon="play" phx-click="play" phx-value-id={save.id}>Play<span class="sr-only">, <%= Pretty.get(save.campaign, :name) %></span></.button>
            <.button usable_icon="box">Archive<span class="sr-only">, <%= Pretty.get(save.campaign, :name) %></span></.button>
          </div>
        </li>
      </ul>
    </div>
    """
  end
  def render(%{live_action: :show} = assigns) do
    ~H"""
    <ul>

    </ul>
    <ul class="mx-auto mx-auto max-w-3xl grid grid-cols-3 gap-3">
      <li :for={character <- @save.characters} class="relative flex items-center space-x-2 rounded-lg border border-gray-300 bg-white px-4 py-3 shadow-sm focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:border-gray-400">
        <div class="flex-shrink-0">
          <img class="h-10 w-10 rounded-full" src="https://images.unsplash.com/photo-1494790108377-be9c29b29330?ixlib=rb-1.2.1&ixid=eyJhcHBfaWQiOjEyMDd9&auto=format&fit=facearea&facepad=2&w=256&h=256&q=80" alt="">
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-sm font-medium text-gray-900"><%= Pretty.get(character, :name) %></p>
          <p class="truncate text-sm text-gray-500"><%= Pretty.get(character.lineage, :name) %> <%= Pretty.get(character.background, :name) %></p>
          <p class="truncate text-sm text-gray-500"><%= Pretty.get(character, :classes) %></p>
        </div>
      </li>
    </ul>

    <article class="prose mx-auto max-w-3xl px-4 py-12">
      <p :for={line <- @save.last_scene.lines} class="mt-1 text-sm text-gray-500">
        <%= if line.speaker_npc.slug == "narrator" do %>
          <%= line.body %>
        <% else %>
          <%= Pretty.get(line.speaker_npc, :name) %>: "<%= line.body %>"
        <% end %>
      </p>
      <ol>
        <li :for={dialogue <- @save.last_scene.dialogues} class="mt-1 text-sm text-gray-500">
          "<%= dialogue.body %>"
        </li>
      </ol>
    </article>
    """
  end
end
