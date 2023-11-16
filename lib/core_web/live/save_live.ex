defmodule CoreWeb.SaveLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  @spec mount(map(), map(), map()) :: {:ok, map()}
  def mount(
        _params,
        _session,
        %{assigns: %{live_action: :new, current_account: current_account}} = socket
      ) do
    socket
    |> assign(
      :current_account,
      current_account
      |> Core.Repo.preload(
        saves: [
          campaign: []
        ]
      )
    )
    |> assign(:characters, Core.Gameplay.list_characters() |> Enum.map(fn character -> {character.name, character.id} end))
    |> assign(:campaigns, Core.Content.list_campaigns()
      |> Core.Repo.preload([:opening_scene])
      |> Enum.map(fn campaign -> {campaign.name, campaign.opening_scene.id} end)
    )
    |> (&{:ok, &1}).()
  end

  def mount(
        _params,
        _session,
        %{assigns: %{live_action: :list, current_account: current_account}} = socket
      ) do
    socket
    |> assign(
      :current_account,
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
    |> assign(:page_title, "Select a saved game")
    |> (&{:ok, &1}).()
  end

  def mount(_params, _session, socket) do
    socket
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

  def handle_params(_params, _url, %{assigns: %{live_action: :new}} = socket) do
    socket
    |> assign(:page_title, "Start a new campaign")
    |> assign(
      :form,
      %Core.Content.Save{}
      |> Core.Repo.preload([:campaign, :characters])
      |> Core.Content.new_save(%{})
      |> to_form()
    )
    |> (&{:noreply, &1}).()
  end

  def handle_params(%{"id" => save_id}, _url, %{assigns: %{live_action: :show}} = socket) do
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
    |> assign(:lines, save.last_scene.lines)
    |> assign(:dialogues, save.last_scene.dialogues)
    |> assign(:speaker, Enum.random(save.characters))
    |> assign(:current_line, 0)
    |> assign(:page_title, save.last_scene.name)
    |> assign(:page_subtitle, save.campaign.name)
    |> (&{:noreply, &1}).()
  end

  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "validate",
        %{"save" => save_params},
        socket
      ) do
    socket
    |> assign(
      :form,
      %Core.Content.Save{}
      |> Core.Repo.preload([:campaign, :characters])
      |> Core.Content.change_save(from_form(save_params))
      |> Map.put(:action, :validate)
      |> then(fn changeset -> to_form(changeset, check_errors: !changeset.valid?) end)
    )
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "save",
        %{"save" => save_params},
        socket
      ) do
    save_params
    |> from_form()
    |> Core.Content.create_save()
    |> case do
      {:ok, save} ->
        socket
        |> put_flash(:info, "Enjoy the game!")
        |> push_navigate(to: ~p"/saves/#{save.id}")
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "switch_speaker",
        %{"id" => character_id},
        %{assigns: %{save: %{characters: characters}}} = socket
      ) do
    socket
    |> assign(:speaker, Enum.find(characters, fn character -> character.id == character_id end))
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "open_character_sheet",
        %{"id" => character_id},
        socket
      ) do
    CoreWeb.SlidesheetComponent.open(character_id)
    socket
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "select_dialogue",
        %{"id" => dialogue_id},
        %{assigns: %{save: save}} = socket
      ) do
    with %Core.Theater.Dialogue{next_scene: next_scene} <- Core.Repo.preload(Core.Theater.get_dialogue(dialogue_id), [:next_scene]),
      {:ok, transitioned_save} <- Core.Content.update_save(save, %{"last_scene" => next_scene}) do
        socket
        |> put_flash(:info, "Changed to #{next_scene.id}")
        |> push_navigate(to: ~p"/saves/#{transitioned_save.id}")
    else
      nil ->
        socket
        |> put_flash(:error, "Couldn't find that dialogue!")
      {:error, _changeset} ->
        socket
        |> put_flash(:error, "Couldn't save your dialogue choice!")
    end
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event("show_more", _params, %{assigns: %{current_line: current_line}} = socket) do
    socket
    |> assign(:current_line, current_line + 1)
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

  def render(%{live_action: :new} = assigns) do
    ~H"""
    <.simple_form for={@form} phx-change="validate" phx-submit="save">
      <.input field={@form[:last_scene]} label="Campaign" type="select" prompt="Select a campaign" value={@form[:last_scene].value && @form[:last_scene].value.data.id} options={@campaigns} />
      <.input field={@form[:characters]} label="Party" type="select" multiple value={@form[:characters].value |> Enum.map(fn character -> character.data.id end)} options={@characters} />
      <:actions>
        <.button usable_icon="plus">Start New Campaign</.button>
      </:actions>
    </.simple_form>
    """
  end

  def render(%{live_action: :list} = assigns) do
    ~H"""
    <ul role="list" class="divide-y divide-gray-100">
      <li :for={save <- @current_account.saves} class="flex items-center justify-between gap-x-6 py-5">
        <div class="min-w-0">
          <div class="flex items-start gap-x-3">
            <p class="font-semibold"><.link navigate={~p"/saves/#{save.id}"}><%= Pretty.get(save.campaign, :name) %></.link></p>
            <.tag :if={save.playing_state == :playing}>
              <%= Pretty.get(save, :playing_state) %>
            </.tag>
            <.tag :if={save.playing_state == :completed} class="text-green-700 bg-green-50 ring-green-600/20">
              <%= Pretty.get(save, :playing_state) %>
            </.tag>
            <.tag :if={save.playing_state == :archived} class="text-yellow-800 bg-yellow-50 ring-yellow-600/20">
              <%= Pretty.get(save, :playing_state) %>
            </.tag>
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
    <article data-current-line={@current_line} class="mx-auto px-2 py-4">
      <.line :if={index <= @current_line} :for={{line, index} <- @lines |> Enum.with_index()} line={line}/>
      <div :if={show_more?(@lines, @current_line)} class="text-center">
        <.button usable_icon="comment-dots" phx-click="show_more" kind="outline">More</.button>
      </div>
    </article>

    <article :if={show_dialogue?(@lines, @current_line)} class="mx-12 py-4 opacity-5" style="animation: 0.5s ease-out 0.75s normal forwards 1 fade-in-keys;">
      <div class="prose">
        <p>
          <strong><%= Pretty.get(@speaker, :name) %></strong> says ...
        </p>
        <ol>
          <li id={dialogue.id} :for={dialogue <- @dialogues}>
            <p>
              "<.link href="#" phx-click="select_dialogue" phx-value-id={dialogue.id}><%= dialogue.body %></.link>" <.requirement :if={dialogue.challenge} challenge={dialogue.challenge} />
              <span :if={!dialogue.next_scene_id} class="text-xs text-grey-400">
                <em>This will end the conversation.</em>
              </span>
            </p>
          </li>
        </ol>
      </div>
    </article>


    <aside class="fixed z-9 top-1/2 right-0">
      <ul class="mx-auto mx-auto grid grid-cols-1 grid-rows-2 gap-2 max-w-xl">
        <li :for={character <- @save.characters} class={["rounded-lg border border-gray-300 bg-white shadow-sm focus-within:ring-2 focus-within:ring-indigo-500 focus-within:ring-offset-2 hover:border-gray-400", @speaker == character && "border-highlight-400 hover:border-highlight-600"]}>
          <div class="grid grid-cols-[1fr_max-content] content-start space-x-2 pr-2 py-2">
            <p class="ml-2 text-md font-medium"><.link href="#" phx-click="open_character_sheet" phx-value-id={character.id} class="text-highlight-300"><%= Pretty.get(character, :name) %></.link></p>
            <img class="h-6 w-6" src={~p"/images/class-fighter.svg"} alt="" />
            <div class="col-span-2">
              <p class="truncate text-sm text-gray-500"><%= Pretty.get(character.lineage, :name) %> <%= Pretty.get(character, :classes) %></p>
            </div>
          </div>
          <div :if={@speaker == character} class="rounded-b-md bg-highlight-400 text-center uppercase font-medium text-light-500">
            Speaker
          </div>
          <div :if={@speaker != character} phx-click="switch_speaker" phx-value-id={character.id} class="text-center uppercase opacity-25 hover:opacity-100 hover:cursor-pointer">
            Switch
          </div>
        </li>
      </ul>
    </aside>

    <.live_component id={character.id} module={CoreWeb.SlidesheetComponent} label={"Character sheet for #{character.name}"} :for={character <- @save.characters}>
      <.sheet character={character} />
    </.live_component>
    """
  end

  attr :line, Core.Theater.Line, required: true
  defp line(assigns) do
    ~H"""
    <div id={@line.id} class="my-2 opacity-5 mx-auto rounded-lg border border-dark-600 bg-dark-600" style="animation: 0.2s ease-out 0.25s normal forwards 1 fade-in-keys;" >
      <div class="prose mx-auto px-6 py-4 text-light-500 font-serif">
        <p>
          <%= if @line.speaker_npc.slug == "narrator" do %>
            <em><%= @line.body %></em>
          <% else %>
            <.link class="text-highlight-300 font-semibold"><%= Pretty.get(@line.speaker_npc, :name) %></.link> shouts "<%= @line.body %>"
          <% end %>
        </p>
      </div>
    </div>
    """
  end

  attr :challenge, Core.Gameplay.Challenge, required: true
  defp requirement(assigns) do
    ~H"""
    <.tag :if={@challenge.tag} class="text-highlight-800 bg-highlight-50 ring-highlight-600/20 mr-1">
      <%= Pretty.get(@challenge, :tag) %>
    </.tag>
    <.tag :if={@challenge.state} class="text-highlight-800 bg-highlight-50 ring-highlight-600/20 mr-1">
      <%= Pretty.get(@challenge, :state) %>
    </.tag>
    <.tag :if={@challenge.ability && @challenge.skill} class="text-highlight-800 bg-highlight-50 ring-highlight-600/20 mr-1">
      <%= Pretty.get(@challenge, :skill) %> (<%= Pretty.get(@challenge, :ability) %>)
    </.tag>
    <.tag :if={@challenge.ability && !@challenge.skill} class="text-highlight-800 bg-highlight-50 ring-highlight-600/20 mr-1">
      <%= Pretty.get(@challenge, :skill) %> (<%= Pretty.get(@challenge, :state) %>)
    </.tag>
    <.tag :if={!@challenge.ability && @challenge.skill} class="text-highlight-800 bg-highlight-50 ring-highlight-600/20">
      <%= Pretty.get(@challenge, :skill) %>
    </.tag>
    """
  end

  defp show_more?(lines, current_line) do
    length(lines) > current_line + 1
  end

  defp show_dialogue?(lines, current_line) do
    length(lines) <= current_line + 1
  end

  defp from_form(params) when is_map(params) do
    params
    |> Utilities.Map.migrate_lazy("last_scene", :last_scene, fn
      last_scene_id ->
        Core.Theater.get_scene(last_scene_id)
    end)
    |> Utilities.Map.migrate_lazy("characters", :characters, fn
      character_ids ->
        Core.Gameplay.get_characters(character_ids)
    end)
  end
end
