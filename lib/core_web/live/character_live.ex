defmodule CoreWeb.CharacterLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
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
    characters =
      Core.Gameplay.list_characters()
      |> Core.Repo.preload(
        levels: [:class],
        lineage: [:lineage_category],
        background: []
      )

    socket
    |> assign(:characters, characters)
    |> assign(:page_title, "List of Characters")
    |> (&{:ok, &1}).()
  end

  def mount(%{"id" => character_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    character =
      Core.Gameplay.get_character(character_id)
      |> Core.Repo.preload(
        levels: [:class],
        lineage: [:lineage_category],
        background: []
      )

    socket
    |> assign(:character, character)
    |> assign(:page_title, character.name)
    |> assign(:page_subtitle, "Character")
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
  def render(%{page_loading: true} = assigns) do
    ~H"""
    Loading...
    """
  end

  def render(%{live_action: :list} = assigns) do
    ~H"""
    <ul>
      <li :for={character <- @characters}><.link navigate={~p"/characters/#{character.id}"}><%= Pretty.get(character, :name) %></.link></li>
    </ul>
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <.sheet character={@character}/>
    """
  end
end
