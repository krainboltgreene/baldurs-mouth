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
        ]
      )
    )
    |> (&{:ok, &1}).()
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
    |> (&{:ok, &1}).()
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
          <img class="h-10 w-10 rounded-full" src={~p"/images/class-fighter.svg"} alt="">
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-sm font-medium text-gray-900"><%= Pretty.get(character, :name) %></p>
          <p class="truncate text-sm text-gray-500"><%= Pretty.get(character.lineage, :name) %> <%= Pretty.get(character.background, :name) %></p>
          <p class="truncate text-sm text-gray-500"><%= Pretty.get(character, :classes) %></p>
        </div>
      </li>
    </ul>

    <article class="mx-auto max-w-3xl px-4 py-12">
      <p :for={line <- @save.last_scene.lines} class="mt-1 text-sm text-gray-500">
        <%= if line.speaker_npc.slug == "narrator" do %>
          <%= line.body %>
        <% else %>
          <%= Pretty.get(line.speaker_npc, :name) %>: "<%= line.body %>"
        <% end %>
      </p>
      <ol>
        <li :for={dialogue <- @save.last_scene.dialogues} class="mt-1 text-sm text-gray-500">
          <p>
            "<%= dialogue.body %>" <.speaker character={Enum.random(@save.characters)} /> or
            <div class="relative inline-block text-left">
              <div>
                <button type="button" class="inline-flex w-full justify-center gap-x-1.5 rounded-md bg-white px-3 py-2 text-sm font-semibold text-gray-900 shadow-sm ring-1 ring-inset ring-gray-300 hover:bg-gray-50" id="menu-button" aria-expanded="true" aria-haspopup="true">
                  Someone else
                  <.icon as="chevron-down"/>
                </button>
              </div>

              <!--
                Dropdown menu, show/hide based on menu state.

                Entering: "transition ease-out duration-100"
                  From: "transform opacity-0 scale-95"
                  To: "transform opacity-100 scale-100"
                Leaving: "transition ease-in duration-75"
                  From: "transform opacity-100 scale-100"
                  To: "transform opacity-0 scale-95"
              -->
              <div class="absolute right-0 z-10 mt-2 w-56 origin-top-right divide-y divide-gray-100 rounded-md bg-white shadow-lg ring-1 ring-black ring-opacity-5 focus:outline-none" role="menu" aria-orientation="vertical" aria-labelledby="menu-button" tabindex="-1">
                <div class="py-1" role="none">
                  <!-- Active: "bg-gray-100 text-gray-900", Not Active: "text-gray-700" -->
                  <a href="#" class="text-gray-700 group flex items-center px-4 py-2 text-sm" role="menuitem" tabindex="-1" id="menu-item-0">
                    <svg class="mr-3 h-5 w-5 text-gray-400 group-hover:text-gray-500" viewBox="0 0 20 20" fill="currentColor" aria-hidden="true">
                      <path d="M5.433 13.917l1.262-3.155A4 4 0 017.58 9.42l6.92-6.918a2.121 2.121 0 013 3l-6.92 6.918c-.383.383-.84.685-1.343.886l-3.154 1.262a.5.5 0 01-.65-.65z" />
                      <path d="M3.5 5.75c0-.69.56-1.25 1.25-1.25H10A.75.75 0 0010 3H4.75A2.75 2.75 0 002 5.75v9.5A2.75 2.75 0 004.75 18h9.5A2.75 2.75 0 0017 15.25V10a.75.75 0 00-1.5 0v5.25c0 .69-.56 1.25-1.25 1.25h-9.5c-.69 0-1.25-.56-1.25-1.25v-9.5z" />
                    </svg>
                    Edit
                  </a>
                </div>
              </div>
            </div>
          </p>
        </li>
      </ol>
    </article>
    """
  end
end
