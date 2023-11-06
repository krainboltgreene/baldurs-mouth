defmodule CoreWeb.SaveLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(
        _params,
        _session,
        %{assigns: %{live_action: :list, current_account: current_account}} = socket
      ) do
    socket
    |> assign(:page_title, "Select a saved game")
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
    save =
      Core.Content.get_save(save_id)
      |> Core.Repo.preload(
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
      )

    socket
    |> assign(:save, save)
    |> assign(:scene, save.last_scene)
    |> assign(:page_title, "#{save.campaign.name} - #{save.last_scene.name}")
    |> (&{:ok, &1}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any()) => any()}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{live_action: :list} = assigns) do
    ~H"""
    <ul role="list" class="divide-y divide-gray-100">
      <li :for={save <- @account.saves} class="flex items-center justify-between gap-x-6 py-5">
        <div class="min-w-0">
          <div class="flex items-start gap-x-3">
            <p class="font-semibold"><.link navigate={~p"/saves/#{save.id}"}><%= Pretty.get(save.campaign, :name) %></.link></p>
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
          </div>
          <div class="mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500">
            <p class="truncate"><%= Pretty.get(save.last_scene, :name) %></p>
          </div>
          <div class="mt-1 flex items-center gap-x-2 text-xs leading-5 text-gray-500">
            <p class="whitespace-nowrap">Last played <.timestamp_in_words_ago at={save.updated_at} /></p>
          </div>
        </div>
        <div class="flex flex-none items-center gap-x-4">
          <.button usable_icon="box">Archive<span class="sr-only">, <%= Pretty.get(save.campaign, :name) %></span></.button>
        </div>
      </li>
    </ul>
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <ul></ul>
    <ul class="mx-auto mx-auto max-w-3xl grid grid-cols-3 gap-3">
      <li :for={character <- @save.characters} class="relative flex items-center space-x-2 rounded-lg border border-gray-300 bg-white px-2 py-1 shadow-sm focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:border-gray-400">
        <div class="flex-shrink-0">
          <img class="h-5 w-5 rounded-full" src={~p"/images/class-fighter.svg"} alt="" />
        </div>
        <div class="min-w-0 flex-1">
          <p class="text-sm font-medium"><%= Pretty.get(character, :name) %></p>
          <p class="truncate text-sm text-gray-500"><%= Pretty.get(character.lineage, :name) %> <%= Pretty.get(character.background, :name) %></p>
          <p class="truncate text-sm text-gray-500"><%= Pretty.get(character, :classes) %></p>
        </div>
      </li>
    </ul>

    <article class="mx-auto max-w-3xl px-4 py-4">
      <p :for={{line, index} <- @scene.lines |> Enum.with_index} class="my-3" style={"opacity: 0%; animation: 1.25s ease-out #{1.75 * index}s normal forwards 1 fade-in-keys;"}>
        <%= if line.speaker_npc.slug == "narrator" do %>
          <span class="italic"><%= line.body %></span>
        <% else %>
          <span class="font-bold"><%= Pretty.get(line.speaker_npc, :name) %></span>: "<%= line.body %>"
        <% end %>
      </p>
      <ol class="list-decimal">
        <li :for={dialogue <- @scene.dialogues} class="my-3" style={"opacity: 0%; animation: 0.5s ease-out #{2 * length(@scene.lines)}s normal forwards 1 fade-in-keys;"}>
          <p>
            "<%= dialogue.body %>" <.speaker character={@save.characters |> Enum.at(0)} /> <.speaker character={@save.characters |> Enum.at(1)} /> <.speaker character={@save.characters |> Enum.at(2)} />
          </p>
        </li>
      </ol>
    </article>
    """
  end
end
