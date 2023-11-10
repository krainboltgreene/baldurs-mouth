defmodule CoreWeb.DialogueLive do
  @moduledoc false
  use CoreWeb, :live_view

  @impl true
  def mount(
        _params,
        _session,
        %{assigns: %{current_account: %Core.Users.Account{username: username}}}
      )
      when username != "krainboltgreene",
      do: raise(CoreWeb.Exceptions.NotFoundException)

  def mount(_params, _session, %{transport_pid: nil} = socket),
    do:
      socket
      |> assign(:page_title, "Loading...")
      |> assign(:page_loading, true)
      |> (&{:ok, &1}).()

  def mount(%{"id" => dialogue_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    dialogue =
      Core.Theater.get_dialogue(dialogue_id)
      |> Core.Repo.preload([
        :for_scene,
        :next_scene,
        :failure_scene
      ])

    socket
    |> assign(:dialogue, dialogue)
    |> assign(:page_title, dialogue.body)
    |> assign(:page_subtitle, "Dialogue")
    |> (&{:ok, &1}).()
  end

  @impl true
  def handle_params(_params, _url, socket) do
    socket
    |> (&{:noreply, &1}).()
  end

  # @impl true
  # def handle_event(
  #       "...",
  #       %{},
  #       %{assigns: %{...}} = socket
  #     ) do
  #   socket
  #   |> (&{:noreply, &1}).()
  # end

  @impl true
  @spec render(%{:live_action => :list | :show, optional(any()) => any()}) ::
          Phoenix.LiveView.Rendered.t()
  def render(%{page_loading: true} = assigns) do
    ~H"""
    Loading...
    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""
    <.list>
      <:item title="For scene">
        <.link navigate={~p"/scenes/#{@dialogue.for_scene_id}"}><%= Pretty.get(@dialogue.for_scene, :name) %></.link>
      </:item>
      <:item :if={@dialogue.next_scene_id && @dialogue.failure_scene_id} title="Success scene">
        <.link navigate={~p"/scenes/#{@dialogue.next_scene_id}"}><%= Pretty.get(@dialogue.next_scene, :name) %></.link>
      </:item>
      <:item :if={@dialogue.next_scene_id && !@dialogue.failure_scene_id} title="Next scene">
        <.link navigate={~p"/scenes/#{@dialogue.next_scene_id}"}><%= Pretty.get(@dialogue.next_scene, :name) %></.link>
      </:item>
      <:item :if={@dialogue.failure_scene_id} title="Failure scene">
        <.link navigate={~p"/scenes/#{@dialogue.failure_scene_id}"}><%= Pretty.get(@dialogue.failure_scene, :name) %></.link>
      </:item>
    </.list>
    """
  end
end
