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
    <div>
      <ul role="list">
        <li :for={save <- @account.saves}>
          <div>
            <%!-- TODO: Change to badge --%>
            <h4><%= Pretty.get(save.campaign, :name) %></h4>
            <p>
              <span :if={save.playing_state == :playing}>
                <%= Pretty.get(save, :playing_state) %>
              </span>
              <span :if={save.playing_state == :completed}>
                <%= Pretty.get(save, :playing_state) %>
              </span>
              <span :if={save.playing_state == :archived}>
                <%= Pretty.get(save, :playing_state) %>
              </span>
              Last played <.timestamp_in_words_ago at={save.updated_at} />
            </p>
            <p><%= save.characters |> Enum.map(&Pretty.get(&1, :name)) |> Utilities.List.to_sentence() %></p>
            <p><%= Pretty.get(save.last_scene, :name) %></p>
          </div>
          <div>
            <.button usable_icon="play" kind="primary" phx-click="play" phx-value-id={save.id}>Play</.button>
            <.button usable_icon="box" kind="light">Archive</.button>
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
    <ul>
      <li :for={character <- @save.characters}>
        <div>
        <%!-- TODO: Switch to actual character avatar --%>
          <img src="images/class-fighter.svg" alt="">
        </div>
        <div>
          <p><%= Pretty.get(character, :name) %></p>
          <p><%= Pretty.get(character.lineage, :name) %> <%= Pretty.get(character.background, :name) %></p>
          <p><%= Pretty.get(character, :classes) %></p>
        </div>
      </li>
    </ul>

    <article>
      <p :for={line <- @save.last_scene.lines}>
        <%= if line.speaker_npc.slug == "narrator" do %>
          <%= line.body %>
        <% else %>
          <%= Pretty.get(line.speaker_npc, :name) %>: "<%= line.body %>"
        <% end %>
      </p>
      <ol>
        <li :for={dialogue <- @save.last_scene.dialogues}>
          <p>
            "<%= dialogue.body %>" <.speaker character={Enum.random(@save.characters)} /> or
            <div>
              <div>
                <button type="button" id="menu-button" aria-expanded="true" aria-haspopup="true">
                  Someone else
                  <.icon as="chevron-down"/>
                </button>
              </div>
              <div role="menu" aria-orientation="vertical" aria-labelledby="menu-button" tabindex="-1">
                <div role="none">
                  <a href="#" role="menuitem" tabindex="-1" id="menu-item-0">
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
