defmodule CoreWeb.CharacterLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
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
    |> (&{:ok, &1}).()
  end

  def mount(
        _params,
        _session,
        %{
          assigns: %{live_action: :new}
        } = socket
      ) do
    socket
    |> assign(
      :classes,
      Core.Gameplay.list_classes() |> Enum.map(fn class -> {class.name, class.id} end)
    )
    |> assign(
      :lineages,
      Core.Gameplay.list_lineages()
      |> Core.Repo.preload([:lineage_category])
      |> Enum.map(fn lineage -> {lineage.name, lineage.id} end)
    )
    |> assign(
      :backgrounds,
      Core.Gameplay.list_backgrounds()
      |> Enum.map(fn background -> {background.name, background.id} end)
    )
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

  def handle_params(_params, _url, %{assigns: %{live_action: :list}} = socket) do
    socket
    |> assign(:page_title, "List of Characters")
    |> (&{:noreply, &1}).()
  end

  def handle_params(%{"id" => character_id}, _url, %{assigns: %{live_action: :show}} = socket) do
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
    |> (&{:noreply, &1}).()
  end

  def handle_params(
        _params,
        _url,
        %{assigns: %{live_action: :new, current_account: current_account}} = socket
      ) do
    socket
    |> assign(
      :form,
      %Core.Gameplay.Character{}
      |> Core.Repo.preload(levels: [:class], lineage: [:lineage_category], background: [])
      |> Core.Gameplay.new_character(%{
        account: current_account
      })
      |> to_form()
    )
    |> assign(:page_title, "New Character")
    |> (&{:noreply, &1}).()
  end

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
    <.list>
      <:item icon={%{as: "user-plus"}}>
        <.link navigate={~p"/characters/new"}>Create New Character</.link>
      </:item>
      <:item :for={character <- @characters} icon={%{as: ""}}>
        <.link navigate={~p"/characters/#{character.id}"}><%= Pretty.get(character, :name) %></.link>
      </:item>
    </.list>
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <.sheet character={@character} />
    """
  end

  def render(%{live_action: :new} = assigns) do
    ~H"""
    <.simple_form for={@form} phx-change="validate" phx-submit="save">
      <.input field={@form[:name]} label="Name" type="text" />
      <div class="grid gap-2 grid-cols-2">
        <.input field={@form[:lineage]} label="Lineage" type="select" prompt="Select a lineage" value={@form[:lineage].value && @form[:lineage].value.data.id} options={@lineages} />
        <.input field={@form[:background]} label="Background" type="select" prompt="Select a background" value={@form[:background].value && @form[:background].value.data.id} options={@backgrounds} />
      </div>
      <div class="grid gap-2 grid-cols-6 text-center">
        <.input :for={ability <- Core.Gameplay.abilities()} field={@form[ability]} label={Phoenix.Naming.humanize(ability)} type="number" min="8" max="15" />
      </div>
      <div class="grid gap-2 grid-cols-6 text-center">
        <.input :for={skill <- Core.Gameplay.skills()} field={@form[skill]} label={Phoenix.Naming.humanize(skill)} type="number" min="8" max="15" />
      </div>
    </.simple_form>
    """
  end
end
