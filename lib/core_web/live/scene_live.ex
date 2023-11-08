defmodule CoreWeb.SceneLive do
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
  def mount(%{"id" => scene_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    scene =
      Core.Theater.get_scene(scene_id)
      |> Core.Repo.preload(
        dialogues: [:next_scene, :failure_scene],
        lines: [:speaker_npc]
      )

    socket
    |> assign(:scene, scene)
    |> assign(:page_title, scene.name)
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

  def render(%{live_action: :list} = assigns) do
    ~H"""

    """
  end

  def render(%{live_action: :show} = assigns) do
    ~H"""

    """
  end
end
