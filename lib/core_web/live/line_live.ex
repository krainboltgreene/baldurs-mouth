defmodule CoreWeb.LineLive do
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

  def mount(%{"id" => line_id}, _session, %{assigns: %{live_action: :show}} = socket) do
    line =
      Core.Theater.get_line(line_id)
      |> Core.Repo.preload([
        :speaker_npc,
        :scene
      ])

    socket
    |> assign(:line, line)
    |> assign(:page_title, line.body)
    |> assign(:page_subtitle, "Line")
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
      <:item title="Scene">
        <.link navigate={~p"/scenes/#{@line.scene_id}"}><%= Pretty.get(@line.scene, :name) %></.link>
      </:item>
      <:item title="NPC">
        <.link navigate={~p"/npcs/#{@line.speaker_npc_id}"}><%= Pretty.get(@line.speaker_npc, :name) %></.link>
      </:item>
    </.list>
    """
  end
end
