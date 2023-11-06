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
    if connected?(socket) do
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
      |> assign(:speaker, Enum.random(save.characters))
      |> assign(:page_title, "#{save.campaign.name} - #{save.last_scene.name}")
      |> (&{:ok, &1}).()
    else
      socket
      |> assign(:page_title, "Loading save...")
      |> assign(:page_loading, true)
      |> (&{:ok, &1}).()
    end
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("switch_speaker", %{"id" => character_id}, %{assigns: %{save: %{characters: characters}}} = socket) do

    socket
    |> assign(:speaker, Enum.find(characters, fn character -> character.id == character_id end))
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
    <ul class="mx-auto mx-auto max-w-3xl grid grid-cols-3 gap-2">
      <li :for={character <- @save.characters} class={["rounded-lg border border-gray-300 bg-white shadow-sm focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:border-gray-400", @speaker == character && "border-highlight-400 hover:border-highlight-600"]}>
        <div class="grid grid-cols-[1fr_max-content] content-start space-x-2 pr-2 py-2">
          <p class="ml-2 text-md font-medium"><%= Pretty.get(character, :name) %></p>
          <img class="h-6 w-6" src={~p"/images/class-fighter.svg"} alt="" />
          <div class="col-span-2">
            <p class="truncate text-sm text-gray-500"><%= Pretty.get(character.lineage, :name) %> <%= Pretty.get(character, :classes) %></p>
          </div>
        </div>
        <div :if={@speaker == character} class="rounded-b-md bg-highlight-400 text-center uppercase font-medium text-light-500">
          Speaker
        </div>
        <div :if={@speaker != character} phx-click="switch_speaker" phx-value-id={character.id} class="text-center uppercase font-medium   opacity-0 hover:opacity-100 hover:cursor-pointer">
          Switch
        </div>
      </li>
    </ul>

    <article class="mx-auto max-w-3xl px-4 py-4">
      <p :for={{line, index} <- @scene.lines |> Enum.with_index} class="my-3 opacity-0" style={"animation: 1.25s ease-out #{1.75 * index}s normal forwards 1 fade-in-keys;"}>
        <%= if line.speaker_npc.slug == "narrator" do %>
          <span class="italic"><%= line.body %></span>
        <% else %>
          <span class="font-bold"><%= Pretty.get(line.speaker_npc, :name) %></span>: "<%= line.body %>"
        <% end %>
      </p>
      <ol class="list-decimal">
        <li :for={dialogue <- @scene.dialogues} class="my-3 opacity-0" style={"animation: 0.5s ease-out #{2 * length(@scene.lines)}s normal forwards 1 fade-in-keys;"}>
          <p>
            <.speaker character={@speaker} /> <.link navigate>"<%= dialogue.body %>"</.link>
          </p>
        </li>
      </ol>
    </article>
    """
  end
end
