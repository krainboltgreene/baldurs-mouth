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
      |> Core.Repo.preload([
        levels: [:class],
        lineage: [:lineage_category],
        background: []
      ])

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
      |> Enum.group_by(fn
        %{lineage_category: nil} -> "Base"
        %{lineage_category: lineage_category} -> lineage_category.name
      end)
      |> Enum.map(fn {lineage_category_name, lineages} ->
        {lineage_category_name, Enum.map(lineages, fn lineage -> {lineage.name, lineage.id} end)}
      end)
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
      :character_form,
      %Core.Gameplay.Character{}
      |> Core.Repo.preload([levels: [:class], lineage: [:lineage_category], background: []])
      |> Core.Gameplay.new_character(%{
        account: current_account
      })
      |> to_form()
    )
    |> assign(
      :lineage_form,
      %Core.Gameplay.Level{}
      |> Core.Repo.preload([:class])
      |> Core.Gameplay.new_level(%{
        strength: 8,
        dexterity: 8,
        constitution: 8,
        intelligence: 8,
        wisdom: 8,
        charisma: 8
      })
      |> to_form()
    )
    |> assign(
      :background_form,
      %Core.Gameplay.Level{}
      |> Core.Repo.preload([:class])
      |> Core.Gameplay.new_level(%{
        strength: 2,
        wisdom: 1
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
  def handle_event(
        "validate",
        %{"character" => character_params},
        socket
      ) do
    socket
    |> assign(
      :character_form,
      %Core.Gameplay.Character{}
      |> Core.Repo.preload([levels: [:class], lineage: [:lineage_category], background: []])
      |> Core.Gameplay.change_character(from_character_form(character_params))
      |> Map.put(:action, :validate)
      |> then(fn changeset -> to_form(changeset, check_errors: !changeset.valid?) end)
    )
    |> (&{:noreply, &1}).()
  end

  def handle_event(
        "validate",
        %{"level" => level_params},
        socket
      ) do
    socket
    |> assign(
      :level_form,
      %Core.Gameplay.Level{}
      |> Core.Repo.preload([:class])
      |> Core.Gameplay.change_level(from_level_form(level_params))
      |> Map.put(:action, :validate)
      |> then(fn changeset -> to_form(changeset, check_errors: !changeset.valid?) end)
    )
    |> (&{:noreply, &1}).()
  end

  @impl true
  def handle_event(
        "save",
        %{"character" => character_params},
        socket
      ) do
    character_params
    |> from_character_form()
    |> Core.Gameplay.create_character()
    |> case do
      {:ok, character} ->
        socket
        |> push_navigate(to: ~p"/character/#{character.id}")
    end
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
    <div class="grid grid-col-1 gap-8">
      <.simple_form for={@character_form} phx-change="validate">
        <:title>Personal Details</:title>
        <.input field={@character_form[:name]} label="Name" type="text" />
        <div class="grid gap-2 grid-cols-2">
          <.input field={@character_form[:lineage]} label="Lineage" type="select" prompt="Select a lineage" value={@character_form[:lineage].value && @character_form[:lineage].value.data.id} options={@lineages} />
          <.input field={@character_form[:background]} label="Background" type="select" prompt="Select a background" value={@character_form[:background].value && @character_form[:background].value.data.id} options={@backgrounds} />
        </div>
      </.simple_form>
      <.simple_form :if={@character_form[:lineage].value} for={@lineage_form} phx-change="validate">
        <:title>Lineage</:title>
        <:subtitle><%= Pretty.get(@character_form[:lineage].value.data, :name) %></:subtitle>
        <:description><%= Pretty.get(@character_form[:lineage].value.data, :description) %></:description>
        <% dbg(@character_form.source.data.levels) %>
        <% dbg(@character_form.source.changes.lineage.data.slug) %>
        <div class="prose">
          <ul>
            <li :for={{choice, type, value} <- Core.Data.plan(@character_form.source, :lineage)}><%= value.name %></li>
          </ul>
        </div>
        <div>Ability Scores</div>
        <div class="grid gap-2 grid-cols-6 text-center">
          <.input :for={ability <- Core.Gameplay.abilities()} field={@lineage_form[ability]} label={Phoenix.Naming.humanize(ability)} type="number" min="8" max="15" />
        </div>
        ...
      </.simple_form>
      <.simple_form :if={@character_form[:background].value} for={@background_form} phx-change="validate">
        <:title>Background</:title>
        <:subtitle><%= Pretty.get(@character_form[:background].value.data, :name) %></:subtitle>
        <:description><%= Pretty.get(@character_form[:background].value.data, :description) %></:description>
        <h1>+2 Ability Score Bonus Choice</h1>
        <div class="grid gap-2 grid-cols-6 text-center">
          <.input :for={ability <- Core.Gameplay.abilities()} field={@background_form[ability]} label={Phoenix.Naming.humanize(ability)} type="radio" />
        </div>
        <h1>+1 Ability Score Bonus Choice</h1>
        <div class="grid gap-2 grid-cols-6 text-center">
          <.input :for={ability <- Core.Gameplay.abilities()} field={@background_form[ability]} label={Phoenix.Naming.humanize(ability)} type="radio" />
        </div>
      </.simple_form>
    </div>
    """
  end

  defp from_character_form(params) when is_map(params) do
    params
    |> Utilities.Map.atomize_keys()
    |> Map.replace_lazy(:lineage, fn
      "" ->
        nil

      lineage_id ->
        Core.Gameplay.get_lineage(lineage_id)
    end)
    |> Map.replace_lazy(:background, fn
      "" ->
        nil

      background_id ->
        Core.Gameplay.get_background(background_id)
    end)
  end

  defp from_level_form(params) when is_map(params) do
    params
    |> Utilities.Map.atomize_keys()
  end
end
